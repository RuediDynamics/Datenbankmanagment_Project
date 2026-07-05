-- =====================================================================
--  IFAA WBHC 2027 - Seed / Representative Test Data
--  Assignment 04 - Exercise 5
--  Target DBMS: PostgreSQL 16
--  Flyway migration: V0.5  (repeatable content, but versioned for order)
-- ---------------------------------------------------------------------
--  Goal: a small-but-complete dataset that exercises every relation and
--  every core transaction (T1..T8) without seeding the full 1,200-shooter
--  production volume. Generated deterministically (no random()) so tests
--  are reproducible. Scale here: 1 event, 4 rounds, 4 ranges x 28 targets,
--  ~40 participants, 40 registrations, score cards + shots for round 1.
-- =====================================================================

SET search_path TO wbhc;

-- ---- Reference data --------------------------------------------------
INSERT INTO nation (nation_code, nation_name) VALUES
    ('AUT','Austria'), ('GER','Germany'), ('USA','United States'),
    ('GBR','Great Britain'), ('SWE','Sweden'), ('FRA','France');

INSERT INTO club (club_name) VALUES
    ('AFBH-C Vienna'), ('BSC Bad Waldsee'), ('Nordic Bowhunters'),
    ('London Field Archers');

INSERT INTO official (first_name, last_name, official_function) VALUES
    ('Klaus','Brenner','Tournament Director'),
    ('Sandra','Klein','Results Officer'),
    ('Tom','Meier','Range Officer'),
    ('Judge','Halvorsen','Judge');

INSERT INTO competition_category (style, division, class_level) VALUES
    ('Bowhunter','Men','Pro'),        -- 1
    ('Bowhunter','Women','Pro'),      -- 2
    ('Freestyle','Men','Amateur'),    -- 3
    ('Traditional','Men','Senior'),   -- 4
    ('Freestyle','Women','Amateur');  -- 5

-- ---- Event + rounds --------------------------------------------------
INSERT INTO event (name, start_date, end_date, location, organizer, ifaa_reference) VALUES
    ('IFAA WBHC 2027','2027-08-16','2027-08-21','Bad Waldsee','IFAA','WBHC-2027');

INSERT INTO round (event_id, round_number, round_type, round_date) VALUES
    (1,1,'3D','2027-08-17'),
    (1,2,'3D','2027-08-18'),
    (1,3,'Field','2027-08-19'),
    (1,4,'Field','2027-08-20');

-- ---- Ranges + officials + target stations ----------------------------
INSERT INTO shooting_range (official_id, range_name) VALUES
    (3,'Range A'), (3,'Range B'), (NULL,'Range C'), (4,'Range D');

-- 28 target stations per range, target_group cycling 1..4
DO $$
DECLARE r INT; t INT;
BEGIN
    FOR r IN 1..4 LOOP
        FOR t IN 1..28 LOOP
            INSERT INTO target_station (range_id, target_number, target_group)
            VALUES (r, t, ((t - 1) % 4) + 1);
        END LOOP;
    END LOOP;
END $$;

-- round_range: every round uses all four ranges
INSERT INTO round_range (round_id, range_id)
SELECT rd.round_id, rg.range_id FROM round rd CROSS JOIN shooting_range rg;

-- target_distance: category-specific max distance per station
INSERT INTO target_distance (range_id, target_number, category_id, max_distance)
SELECT ts.range_id, ts.target_number, cc.category_id,
       20 + ts.target_number                      -- deterministic distance
FROM   target_station ts
CROSS  JOIN competition_category cc
WHERE  ts.range_id = 1 AND cc.category_id IN (1,2);  -- keep seed compact

-- ---- Participants (40) -----------------------------------------------
DO $$
DECLARE i INT;
        nations CHAR(3)[] := ARRAY['AUT','GER','USA','GBR','SWE','FRA'];
BEGIN
    FOR i IN 1..40 LOOP
        INSERT INTO participant (nation_code, club_id, first_name, last_name, birth_date)
        VALUES (nations[((i - 1) % 6) + 1],
                CASE WHEN i % 5 = 0 THEN NULL ELSE ((i - 1) % 4) + 1 END,
                'First' || i,
                'Last'  || i,
                DATE '1985-01-01' + (i * 40));
    END LOOP;
END $$;

-- ---- Registrations (T1) : each participant to a category -------------
DO $$
DECLARE i INT;
BEGIN
    FOR i IN 1..40 LOOP
        INSERT INTO registration
            (participant_id, event_id, category_id, entry_fee_status, equipment_status,
             classification_verified, classification_date)
        VALUES (i, 1, ((i - 1) % 5) + 1,
                'paid', 'verified',
                (i % 3 <> 0),                       -- ~2/3 verified (T2 test surface)
                CASE WHEN (i % 3 <> 0) THEN TIMESTAMPTZ '2027-08-15 10:00+00' ELSE NULL END);
    END LOOP;
END $$;

-- ---- Start groups (T3) : round 1, 8 groups of 5 over 4 ranges --------
DO $$
DECLARE g INT;
BEGIN
    FOR g IN 1..8 LOOP
        INSERT INTO start_group (round_id, range_id, group_number, start_target)
        VALUES (1, ((g - 1) % 4) + 1, g, ((g - 1) % 28) + 1);
    END LOOP;
END $$;

-- assign registrations 1..40 to the 8 groups (5 each)
INSERT INTO start_group_member (group_id, registration_id)
SELECT ((reg.registration_id - 1) / 5) + 1, reg.registration_id
FROM   registration reg
WHERE  reg.registration_id BETWEEN 1 AND 40;

-- ---- Score cards + shot results (T4) : round 1, all 40 shooters ------
--  3D round -> 1 arrow per target in bow-hunter practice; we seed 2 arrows
--  per target (56 shots/card) to give the aggregates something to sum.
DO $$
DECLARE reg RECORD;
        card_id BIGINT;
        grp_range INT;
        tnum INT;
        anum INT;
        zones VARCHAR(2)[] := ARRAY['10','9','8','7','6','M'];
        z VARCHAR(2);
BEGIN
    FOR reg IN
        SELECT sgm.registration_id, sg.range_id
        FROM   start_group_member sgm
        JOIN   start_group sg ON sg.group_id = sgm.group_id
        WHERE  sg.round_id = 1
    LOOP
        INSERT INTO score_card (registration_id, round_id, official_id, range_id)
        VALUES (reg.registration_id, 1, 2, reg.range_id)
        RETURNING score_card_id INTO card_id;

        FOR tnum IN 1..28 LOOP
            FOR anum IN 1..2 LOOP
                -- deterministic zone spread
                z := zones[(((reg.registration_id + tnum + anum) % 6) + 1)];
                INSERT INTO shot_result
                    (score_card_id, target_number, arrow_number, tie_break_id, hit_zone)
                VALUES (card_id, tnum, anum, NULL, z);
            END LOOP;
        END LOOP;
    END LOOP;
END $$;

-- ---- Tournament results (T5/T8) --------------------------------------
INSERT INTO tournament_result (registration_id, tie_break_status)
SELECT registration_id, 'not-needed'
FROM   registration
WHERE  registration_id BETWEEN 1 AND 40;

-- ---- Tie-break (T6) : force a tie for two registrations --------------
INSERT INTO tie_break (tie_break_round) VALUES (4);   -- tie_break_id = 1
INSERT INTO tie_break_participant (tie_break_id, registration_id) VALUES (1,1),(1,6);
UPDATE tournament_result SET tie_break_status = 'pending'
WHERE  registration_id IN (1,6);

-- one shoot-off shot per tie participant (score card for round 4)
DO $$
DECLARE reg INT; card_id BIGINT;
BEGIN
    FOREACH reg IN ARRAY ARRAY[1,6] LOOP
        INSERT INTO score_card (registration_id, round_id, official_id, range_id)
        VALUES (reg, 4, 2, 1) RETURNING score_card_id INTO card_id;
        INSERT INTO shot_result (score_card_id, target_number, arrow_number, tie_break_id, hit_zone)
        VALUES (card_id, 1, 1, 1, CASE WHEN reg = 1 THEN '10' ELSE '8' END);
    END LOOP;
END $$;

-- ---- Protest (T7) ----------------------------------------------------
INSERT INTO protest (official_id, registration_id, protest_date, protest_description, protest_decision)
VALUES (1, 3, TIMESTAMPTZ '2027-08-19 15:30+00',
        'Disputed scoring on target 12, round 3.', 'pending');

-- ---- Build initial rankings ------------------------------------------
SELECT fn_refresh_rankings();
