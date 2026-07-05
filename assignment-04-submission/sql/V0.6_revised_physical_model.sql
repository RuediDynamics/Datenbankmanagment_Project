-- =====================================================================
--  IFAA WBHC 2027 - Revised Physical Model (Design Iteration)
--  Assignment 04 - Exercise 6, iteration evidence (initial -> revised)
--  Target DBMS: PostgreSQL 16
--  Flyway migration: V0.6
-- ---------------------------------------------------------------------
--  This migration encodes the two physical-design refinement cycles that
--  emerged from testing (see assets/reports/test-report.md):
--
--  Iteration A (derived-data representation):
--    roundTotal changes from COMPUTED-on-demand (v_score_card_total) to
--    a STORED column score_card.round_total maintained incrementally by
--    an AFTER trigger on shot_result. Rationale: T5/T8 ranking re-reads
--    round totals far more often than raw shots change; the on-demand
--    SUM over ~270k shot rows dominated ranking latency. Trade-off:
--    O(1) extra write cost per shot vs. removing a large aggregate read.
--
--  Iteration B (general constraint):
--    the composite "atTarget" reference (A03 C86) whose parent key spans
--    two tables (score_card.range_id + shot_result.target_number ->
--    target_station) is now DBMS-enforced by a BEFORE trigger, replacing
--    the earlier application-level fallback.
-- =====================================================================

SET search_path TO wbhc;

-- ---------------------------------------------------------------------
--  Iteration A - stored derived round_total
-- ---------------------------------------------------------------------
ALTER TABLE score_card
    ADD COLUMN round_total INTEGER NOT NULL DEFAULT 0
    CONSTRAINT ck_score_card_round_total CHECK (round_total >= 0);

-- point value of a single shot given its score card's round type
CREATE OR REPLACE FUNCTION fn_shot_point_value(p_score_card_id BIGINT, p_hit_zone VARCHAR)
RETURNS INTEGER
LANGUAGE sql STABLE AS
$$
    SELECT COALESCE(sr.point_value, 0)
    FROM   score_card sc
    JOIN   round rd ON rd.round_id = sc.round_id
    LEFT   JOIN scoring_rule sr
           ON sr.round_type = rd.round_type AND sr.hit_zone = p_hit_zone
    WHERE  sc.score_card_id = p_score_card_id
$$;

-- incremental maintenance: only regular shots (tie_break_id IS NULL, C112)
-- contribute to the round total.
CREATE OR REPLACE FUNCTION fn_shot_result_maintain_total()
RETURNS trigger
LANGUAGE plpgsql AS
$$
DECLARE
    v_delta INTEGER := 0;
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.tie_break_id IS NULL THEN
            v_delta := fn_shot_point_value(NEW.score_card_id, NEW.hit_zone);
            UPDATE score_card SET round_total = round_total + v_delta
            WHERE score_card_id = NEW.score_card_id;
        END IF;
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        IF OLD.tie_break_id IS NULL THEN
            v_delta := fn_shot_point_value(OLD.score_card_id, OLD.hit_zone);
            UPDATE score_card SET round_total = round_total - v_delta
            WHERE score_card_id = OLD.score_card_id;
        END IF;
        RETURN OLD;

    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.tie_break_id IS NULL THEN
            UPDATE score_card SET round_total = round_total
                   - fn_shot_point_value(OLD.score_card_id, OLD.hit_zone)
            WHERE score_card_id = OLD.score_card_id;
        END IF;
        IF NEW.tie_break_id IS NULL THEN
            UPDATE score_card SET round_total = round_total
                   + fn_shot_point_value(NEW.score_card_id, NEW.hit_zone)
            WHERE score_card_id = NEW.score_card_id;
        END IF;
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$;

CREATE TRIGGER trg_shot_result_total
    AFTER INSERT OR UPDATE OR DELETE ON shot_result
    FOR EACH ROW EXECUTE FUNCTION fn_shot_result_maintain_total();

-- one-off backfill for rows seeded before the trigger existed
UPDATE score_card sc
SET    round_total = COALESCE(t.total, 0)
FROM  (SELECT score_card_id, round_total AS total FROM v_score_card_total) t
WHERE  t.score_card_id = sc.score_card_id;

-- ---------------------------------------------------------------------
--  Iteration B - trigger-enforced atTarget referential integrity (C86)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_shot_result_target_check()
RETURNS trigger
LANGUAGE plpgsql AS
$$
DECLARE
    v_range_id BIGINT;
BEGIN
    SELECT range_id INTO v_range_id
    FROM   score_card WHERE score_card_id = NEW.score_card_id;

    IF NOT EXISTS (
        SELECT 1 FROM target_station
        WHERE range_id = v_range_id AND target_number = NEW.target_number
    ) THEN
        RAISE EXCEPTION
          'shot_result.target_number % not valid for range % (score_card %)',
          NEW.target_number, v_range_id, NEW.score_card_id
          USING ERRCODE = 'foreign_key_violation';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_shot_result_target_check
    BEFORE INSERT OR UPDATE OF target_number, score_card_id ON shot_result
    FOR EACH ROW EXECUTE FUNCTION fn_shot_result_target_check();

-- ---------------------------------------------------------------------
--  Rebuild ranking matview to read the stored round_total (Iteration A)
-- ---------------------------------------------------------------------
DROP MATERIALIZED VIEW mv_tournament_ranking;

CREATE MATERIALIZED VIEW mv_tournament_ranking AS
SELECT reg.registration_id,
       reg.event_id,
       reg.category_id,
       cc.style,
       cc.division,
       cc.class_level,
       reg.participant_id,
       COALESCE(SUM(sc.round_total), 0) AS total_points,
       RANK() OVER (
            PARTITION BY reg.event_id, reg.category_id
            ORDER BY COALESCE(SUM(sc.round_total), 0) DESC
       ) AS rank_position,
       tr.tie_break_status
FROM   registration reg
JOIN   competition_category cc ON cc.category_id = reg.category_id
LEFT   JOIN score_card sc ON sc.registration_id = reg.registration_id
LEFT   JOIN tournament_result tr ON tr.registration_id = reg.registration_id
GROUP  BY reg.registration_id, reg.event_id, reg.category_id,
         cc.style, cc.division, cc.class_level, reg.participant_id,
         tr.tie_break_status;

CREATE UNIQUE INDEX idx_mv_ranking_registration
    ON mv_tournament_ranking (registration_id);
CREATE INDEX idx_mv_ranking_category
    ON mv_tournament_ranking (event_id, category_id, rank_position);

SELECT fn_refresh_rankings();
