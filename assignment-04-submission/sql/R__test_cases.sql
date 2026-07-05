-- =====================================================================
--  IFAA WBHC 2027 - Physical Model Test Cases
--  Assignment 04 - Exercise 6 (functional, constraint, performance)
--  Target DBMS: PostgreSQL 16
--  Flyway repeatable migration: R__test_cases.sql
-- ---------------------------------------------------------------------
--  Run AFTER V0.1..V0.6 + seed. Self-checking via ASSERT; a failing test
--  raises and aborts. Negative (constraint) tests wrap the offending
--  statement in a sub-transaction and assert that it errors.
--  Test IDs map to assets/reports/test-report.md.
-- =====================================================================

SET search_path TO wbhc;

-- =====================================================================
--  FUNCTIONAL TESTS (T1..T8)
-- =====================================================================

-- ---- PT-01 (T1): create participant + registration --------------------
DO $$
DECLARE v_pid BIGINT; v_rid BIGINT;
BEGIN
    INSERT INTO participant (nation_code, club_id, first_name, last_name, birth_date)
    VALUES ('AUT', 1, 'Maria', 'Weiss', DATE '1990-05-04')
    RETURNING participant_id INTO v_pid;

    INSERT INTO registration (participant_id, event_id, category_id, entry_fee_status, equipment_status)
    VALUES (v_pid, 1, 2, 'paid', 'verified')
    RETURNING registration_id INTO v_rid;

    ASSERT (SELECT count(*) FROM registration WHERE registration_id = v_rid) = 1,
        'PT-01 failed: registration not created';
    RAISE NOTICE 'PT-01 PASS: participant % / registration % created', v_pid, v_rid;
END $$;

-- ---- PT-02 (T2): verify classification / grant admission --------------
DO $$
DECLARE v_rid BIGINT;
BEGIN
    SELECT registration_id INTO v_rid FROM registration
    WHERE classification_verified = FALSE LIMIT 1;

    UPDATE registration
    SET classification_verified = TRUE,
        classification_date = now()
    WHERE registration_id = v_rid;

    ASSERT (SELECT classification_verified AND classification_date IS NOT NULL
            FROM registration WHERE registration_id = v_rid),
        'PT-02 failed: classification not persisted';
    RAISE NOTICE 'PT-02 PASS: registration % admitted', v_rid;
END $$;

-- ---- PT-03 (T3): create start group + assign shooters -----------------
DO $$
DECLARE v_gid BIGINT;
BEGIN
    INSERT INTO start_group (round_id, range_id, group_number, start_target)
    VALUES (2, 1, 99, 5) RETURNING group_id INTO v_gid;

    INSERT INTO start_group_member (group_id, registration_id) VALUES (v_gid, 1), (v_gid, 2);

    ASSERT (SELECT count(*) FROM start_group_member WHERE group_id = v_gid) = 2,
        'PT-03 failed: members not assigned';
    RAISE NOTICE 'PT-03 PASS: start group % with 2 members', v_gid;
END $$;

-- ---- PT-04 (T4): record a score card + shots, points computed ---------
DO $$
DECLARE v_card BIGINT; v_total INTEGER;
BEGIN
    INSERT INTO score_card (registration_id, round_id, official_id, range_id)
    VALUES (2, 2, 2, 1) RETURNING score_card_id INTO v_card;

    INSERT INTO shot_result (score_card_id, target_number, arrow_number, hit_zone) VALUES
        (v_card, 1, 1, '10'),   -- 3D round: '10' -> 11 points
        (v_card, 1, 2, '9'),    -- '9' -> 10
        (v_card, 2, 1, '8');    -- '8' -> 8   => total 29
    SELECT round_total INTO v_total FROM score_card WHERE score_card_id = v_card;
    ASSERT v_total = 29,
        format('PT-04 failed: round_total = %s (expected 29)', v_total);
    RAISE NOTICE 'PT-04 PASS: score card % total = % (trigger-maintained)', v_card, v_total;
END $$;

-- ---- PT-05 (T5): daily / overall ranking via materialized view --------
DO $$
DECLARE v_rows INTEGER; v_top INTEGER;
BEGIN
    PERFORM fn_refresh_rankings();
    SELECT count(*) INTO v_rows FROM mv_tournament_ranking WHERE event_id = 1;
    SELECT min(rank_position) INTO v_top
    FROM mv_tournament_ranking WHERE event_id = 1;
    ASSERT v_rows > 0 AND v_top = 1,
        'PT-05 failed: ranking empty or no rank 1';
    RAISE NOTICE 'PT-05 PASS: ranking has % rows, top rank = %', v_rows, v_top;
END $$;

-- ---- PT-06 (T6): tie-break shoot-off + winner -------------------------
DO $$
DECLARE v_winner BIGINT;
BEGIN
    -- highest shoot-off shot among tie participants of tie_break 1
    SELECT vs.score_card_id INTO v_winner
    FROM   v_shot_score vs
    WHERE  vs.tie_break_id = 1
    ORDER  BY vs.point_value DESC
    LIMIT  1;
    ASSERT v_winner IS NOT NULL, 'PT-06 failed: no tie-break shots found';

    UPDATE tournament_result SET tie_break_status = 'completed'
    WHERE  registration_id IN (SELECT registration_id FROM tie_break_participant WHERE tie_break_id = 1);
    RAISE NOTICE 'PT-06 PASS: tie-break resolved, winning card = %', v_winner;
END $$;

-- ---- PT-07 (T7): document protest -------------------------------------
DO $$
DECLARE v_pid BIGINT;
BEGIN
    INSERT INTO protest (official_id, registration_id, protest_description)
    VALUES (4, 5, 'Equipment challenge at check-in.')
    RETURNING protest_id INTO v_pid;
    UPDATE protest SET protest_decision = 'denied' WHERE protest_id = v_pid;
    ASSERT (SELECT protest_decision FROM protest WHERE protest_id = v_pid) = 'denied',
        'PT-07 failed: decision not updated';
    RAISE NOTICE 'PT-07 PASS: protest % documented and decided', v_pid;
END $$;

-- ---- PT-08 (T8): IFAA export projection --------------------------------
DO $$
DECLARE v_rows INTEGER;
BEGIN
    SELECT count(*) INTO v_rows
    FROM   mv_tournament_ranking r
    JOIN   v_participant p ON p.participant_id = r.participant_id
    WHERE  r.event_id = 1;
    ASSERT v_rows > 0, 'PT-08 failed: export produced no rows';
    RAISE NOTICE 'PT-08 PASS: export projection returns % rows', v_rows;
END $$;

-- =====================================================================
--  CONSTRAINT TESTS  (entity / referential / domain / business)
--  Helper: assert that a statement raises. Uses nested block + EXCEPTION.
-- =====================================================================

-- ---- PT-09 (entity integrity): duplicate registration blocked (C57) ---
DO $$
BEGIN
    BEGIN
        INSERT INTO registration (participant_id, event_id, category_id)
        VALUES (1, 1, 1);   -- participant 1 already registered for event 1
        RAISE EXCEPTION 'PT-09 failed: duplicate registration was allowed';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'PT-09 PASS: duplicate (participant,event) rejected';
    END;
END $$;

-- ---- PT-10 (referential integrity): bad FK blocked (C76) --------------
DO $$
BEGIN
    BEGIN
        INSERT INTO registration (participant_id, event_id, category_id)
        VALUES (999999, 1, 1);
        RAISE EXCEPTION 'PT-10 failed: invalid participant FK accepted';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE 'PT-10 PASS: invalid participant_id rejected';
    END;
END $$;

-- ---- PT-11 (domain): invalid hit_zone blocked (C37/C106) --------------
DO $$
DECLARE v_card BIGINT;
BEGIN
    SELECT score_card_id INTO v_card FROM score_card LIMIT 1;
    BEGIN
        INSERT INTO shot_result (score_card_id, target_number, arrow_number, hit_zone)
        VALUES (v_card, 15, 5, 'X');
        RAISE EXCEPTION 'PT-11 failed: invalid hit_zone accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'PT-11 PASS: invalid hit_zone rejected';
    END;
END $$;

-- ---- PT-12 (business): classification_verified requires date (C101) ---
DO $$
DECLARE v_pid BIGINT;
BEGIN
    -- fresh participant so the failure is the C101 CHECK, not the C57 unique key
    INSERT INTO participant (nation_code, first_name, last_name, birth_date)
    VALUES ('GER','Check','Case', DATE '1992-02-02') RETURNING participant_id INTO v_pid;
    BEGIN
        INSERT INTO registration
            (participant_id, event_id, category_id, classification_verified, classification_date)
        VALUES (v_pid, 1, 3, TRUE, NULL);   -- verified but no date
        RAISE EXCEPTION 'PT-12 failed: verified w/o date accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'PT-12 PASS: verified-without-date rejected';
    END;
END $$;

-- ---- PT-13 (referential action): SET NULL on official delete (C83) ----
DO $$
DECLARE v_off BIGINT; v_nulls INTEGER;
BEGIN
    INSERT INTO official (first_name, last_name, official_function)
    VALUES ('Temp','Signer','Range Officer') RETURNING official_id INTO v_off;
    UPDATE score_card SET official_id = v_off WHERE score_card_id =
        (SELECT score_card_id FROM score_card LIMIT 1);
    DELETE FROM official WHERE official_id = v_off;
    SELECT count(*) INTO v_nulls FROM score_card WHERE official_id = v_off;
    ASSERT v_nulls = 0, 'PT-13 failed: SET NULL did not apply';
    RAISE NOTICE 'PT-13 PASS: official delete set score_card.official_id NULL';
END $$;

-- ---- PT-14 (business): atTarget trigger blocks bad target (C86) -------
DO $$
DECLARE v_card BIGINT;
BEGIN
    -- score card on range 1 (targets 1..28); target 99 is invalid
    SELECT score_card_id INTO v_card FROM score_card WHERE range_id = 1 LIMIT 1;
    BEGIN
        INSERT INTO shot_result (score_card_id, target_number, arrow_number, hit_zone)
        VALUES (v_card, 99, 1, '8');
        RAISE EXCEPTION 'PT-14 failed: out-of-range target accepted';
    EXCEPTION
        WHEN foreign_key_violation OR check_violation THEN
        RAISE NOTICE 'PT-14 PASS: out-of-range target rejected by atTarget check';
    END;
END $$;

-- =====================================================================
--  PERFORMANCE PROBES (Step 4 evidence) - inspect plans manually.
--  Run these interactively and capture the output into
--  assets/plans/query-plan-evidence/.
-- =====================================================================
-- P1: ranking read should use the materialized view + category index.
--   EXPLAIN (ANALYZE, BUFFERS)
--   SELECT * FROM mv_tournament_ranking
--   WHERE event_id = 1 AND category_id = 1 ORDER BY rank_position;
--
-- P2: T2 admission scan should use the partial index idx_registration_unverified.
--   EXPLAIN (ANALYZE, BUFFERS)
--   SELECT registration_id FROM registration
--   WHERE event_id = 1 AND classification_verified = FALSE;
--
-- P3: T4 shot read-back should use the score_card PK (index scan, no sort).
--   EXPLAIN (ANALYZE, BUFFERS)
--   SELECT * FROM shot_result WHERE score_card_id = 1
--   ORDER BY target_number, arrow_number;
