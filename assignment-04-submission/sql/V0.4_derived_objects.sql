-- =====================================================================
--  IFAA WBHC 2027 - Derived Data Objects
--  Assignment 04 - Exercise 2, Step 3.2 (representation of derived data)
--  Target DBMS: PostgreSQL 16
--  Flyway migration: V0.4
-- ---------------------------------------------------------------------
--  Derived attributes (A03 Task 1 (l)): age, pointValue, roundTotal,
--  totalPoints, rankPosition, numberOfTargets.
--  Representation decisions (see derived-data table in documentation):
--    age             -> computed  : v_participant
--    pointValue      -> computed  : scoring_rule lookup + v_shot_score
--    roundTotal      -> computed  : v_score_card_total  (INITIAL model;
--                                   materialized in V0.6 as a trade-off)
--    numberOfTargets -> computed  : v_range_config
--    totalPoints     -> materialized : mv_tournament_ranking
--    rankPosition    -> materialized : mv_tournament_ranking (RANK())
-- =====================================================================

SET search_path TO wbhc;

-- ---------------------------------------------------------------------
--  scoring_rule: data-driven IFAA point table (realizes A03 future
--  growth "ScoringRule"). Keyed by (round_type, hit_zone) because 3D
--  rounds score the same zone differently from target-face rounds.
-- ---------------------------------------------------------------------
CREATE TABLE scoring_rule (
    round_type  VARCHAR(20) NOT NULL,
    hit_zone    VARCHAR(2)  NOT NULL,
    point_value SMALLINT    NOT NULL,
    CONSTRAINT pk_scoring_rule PRIMARY KEY (round_type, hit_zone),
    CONSTRAINT ck_scoring_rule_zone
        CHECK (hit_zone IN ('10','9','8','7','6','5','M','RM')),
    CONSTRAINT ck_scoring_rule_value CHECK (point_value >= 0)
);

INSERT INTO scoring_rule (round_type, hit_zone, point_value) VALUES
    -- target-face style rounds: zone number = points, misses = 0
    ('Field','10',10),('Field','9',9),('Field','8',8),('Field','7',7),
    ('Field','6',6),('Field','5',5),('Field','M',0),('Field','RM',0),
    ('Target','10',10),('Target','9',9),('Target','8',8),('Target','7',7),
    ('Target','6',6),('Target','5',5),('Target','M',0),('Target','RM',0),
    ('Indoor','10',10),('Indoor','9',9),('Indoor','8',8),('Indoor','7',7),
    ('Indoor','6',6),('Indoor','5',5),('Indoor','M',0),('Indoor','RM',0),
    -- 3D rounds: bonus centre ring, otherwise reduced kill/vital scoring
    ('3D','10',11),('3D','9',10),('3D','8',8),('3D','7',6),
    ('3D','6',5),('3D','5',4),('3D','M',0),('3D','RM',0),
    -- shoot-off: same face as target rounds
    ('Shoot-off','10',10),('Shoot-off','9',9),('Shoot-off','8',8),('Shoot-off','7',7),
    ('Shoot-off','6',6),('Shoot-off','5',5),('Shoot-off','M',0),('Shoot-off','RM',0);

-- ---------------------------------------------------------------------
--  Helper function: participant age (IMMUTABLE-unsafe -> STABLE, so it
--  cannot back a CHECK; used only for read-time derivation).
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_participant_age(p_birth_date DATE)
RETURNS INTEGER
LANGUAGE sql STABLE AS
$$ SELECT EXTRACT(YEAR FROM age(CURRENT_DATE, p_birth_date))::INTEGER $$;

-- ---------------------------------------------------------------------
--  v_participant : participant master data + derived age (T1, T5, T8)
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_participant AS
SELECT p.participant_id,
       p.first_name,
       p.last_name,
       p.birth_date,
       fn_participant_age(p.birth_date) AS age,
       p.nation_code,
       n.nation_name,
       p.club_id,
       c.club_name
FROM   participant p
JOIN   nation n ON n.nation_code = p.nation_code
LEFT   JOIN club c ON c.club_id = p.club_id;

-- ---------------------------------------------------------------------
--  v_range_config : numberOfTargets per range (T3)
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_range_config AS
SELECT r.range_id,
       r.range_name,
       count(ts.target_number) AS number_of_targets
FROM   shooting_range r
LEFT   JOIN target_station ts ON ts.range_id = r.range_id
GROUP  BY r.range_id, r.range_name;

-- ---------------------------------------------------------------------
--  v_shot_score : each shot with its derived pointValue (T4, T5, T6, T8)
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_shot_score AS
SELECT sr.score_card_id,
       sr.target_number,
       sr.arrow_number,
       sr.hit_zone,
       sr.tie_break_id,
       rd.round_type,
       COALESCE(sc_rule.point_value, 0) AS point_value
FROM   shot_result sr
JOIN   score_card  sctd ON sctd.score_card_id = sr.score_card_id
JOIN   round       rd   ON rd.round_id = sctd.round_id
LEFT   JOIN scoring_rule sc_rule
       ON sc_rule.round_type = rd.round_type
      AND sc_rule.hit_zone   = sr.hit_zone;

-- ---------------------------------------------------------------------
--  v_score_card_total : derived roundTotal per score card (INITIAL
--  representation - computed on demand; V0.6 materializes it).
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_score_card_total AS
SELECT sc.score_card_id,
       sc.registration_id,
       sc.round_id,
       COALESCE(SUM(vs.point_value), 0) AS round_total
FROM   score_card sc
LEFT   JOIN v_shot_score vs
       ON vs.score_card_id = sc.score_card_id
      AND vs.tie_break_id IS NULL          -- regular shots only (C112)
GROUP  BY sc.score_card_id, sc.registration_id, sc.round_id;

-- ---------------------------------------------------------------------
--  mv_tournament_ranking : totalPoints + rankPosition per registration
--  (T5, T8). Materialized because it aggregates ~270k shot rows and is
--  read far more often than the underlying scores change (batch refresh
--  after each scoring session -> see fn_refresh_rankings).
-- ---------------------------------------------------------------------
CREATE MATERIALIZED VIEW mv_tournament_ranking AS
SELECT reg.registration_id,
       reg.event_id,
       reg.category_id,
       cc.style,
       cc.division,
       cc.class_level,
       reg.participant_id,
       COALESCE(SUM(sct.round_total), 0) AS total_points,
       RANK() OVER (
            PARTITION BY reg.event_id, reg.category_id
            ORDER BY COALESCE(SUM(sct.round_total), 0) DESC
       ) AS rank_position,
       tr.tie_break_status
FROM   registration reg
JOIN   competition_category cc ON cc.category_id = reg.category_id
LEFT   JOIN v_score_card_total sct ON sct.registration_id = reg.registration_id
LEFT   JOIN tournament_result tr ON tr.registration_id = reg.registration_id
GROUP  BY reg.registration_id, reg.event_id, reg.category_id,
         cc.style, cc.division, cc.class_level, reg.participant_id,
         tr.tie_break_status;

-- Unique index required for REFRESH ... CONCURRENTLY.
CREATE UNIQUE INDEX idx_mv_ranking_registration
    ON mv_tournament_ranking (registration_id);
CREATE INDEX idx_mv_ranking_category
    ON mv_tournament_ranking (event_id, category_id, rank_position);

-- ---------------------------------------------------------------------
--  fn_refresh_rankings : consistency strategy for materialized totals.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_refresh_rankings()
RETURNS void
LANGUAGE plpgsql AS
$$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_tournament_ranking;
END;
$$;
