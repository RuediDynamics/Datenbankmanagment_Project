-- =====================================================================
--  IFAA WBHC 2027 - Constraints
--  Assignment 04 - Exercise 2, Step 3.1 (keys/FK) & Step 3.3 (general)
--  Target DBMS: PostgreSQL 16
--  Flyway migration: V0.2
-- ---------------------------------------------------------------------
--  Traceability:
--    Entity integrity / AKs (UNIQUE)  -> A03 constraint table C41-C70
--    Referential integrity (FK)       -> A03 referential-actions C71-C98
--    Domain constraints (CHECK)       -> A03 constraint table C25-C40
--    Business rules (CHECK/trigger)   -> A03 constraint table C99-C112
--  Constraint-name -> A03-ID mapping is recorded as inline comments and
--  in assets/reports/test-report.md (object inventory).
-- =====================================================================

SET search_path TO wbhc;

-- ---------------------------------------------------------------------
--  1) Alternate keys (UNIQUE) - A03 C42..C70
-- ---------------------------------------------------------------------
ALTER TABLE event
    ADD CONSTRAINT uq_event_name_start UNIQUE (name, start_date);              -- C42
ALTER TABLE round
    ADD CONSTRAINT uq_round_event_number UNIQUE (event_id, round_number);      -- C44
ALTER TABLE shooting_range
    ADD CONSTRAINT uq_range_name UNIQUE (range_name);                         -- C46
ALTER TABLE nation
    ADD CONSTRAINT uq_nation_name UNIQUE (nation_name);                       -- C49
ALTER TABLE club
    ADD CONSTRAINT uq_club_name UNIQUE (club_name);                          -- C51
ALTER TABLE competition_category
    ADD CONSTRAINT uq_category_triplet UNIQUE (style, division, class_level); -- C55
ALTER TABLE registration
    ADD CONSTRAINT uq_registration_participant_event
        UNIQUE (participant_id, event_id);                                   -- C57 / C102
ALTER TABLE start_group
    ADD CONSTRAINT uq_start_group_round_number UNIQUE (round_id, group_number); -- C59
ALTER TABLE score_card
    ADD CONSTRAINT uq_score_card_reg_round
        UNIQUE (registration_id, round_id);                                  -- C61 / C104
ALTER TABLE tournament_result
    ADD CONSTRAINT uq_tournament_result_registration
        UNIQUE (registration_id);                                            -- C64 (1:1)

-- ---------------------------------------------------------------------
--  2) Domain / business CHECK constraints - A03 C25..C40, C99..C112
-- ---------------------------------------------------------------------
ALTER TABLE event
    ADD CONSTRAINT ck_event_date_order CHECK (start_date <= end_date);        -- C25

ALTER TABLE round
    ADD CONSTRAINT ck_round_number CHECK (round_number BETWEEN 1 AND 4),      -- Round [1..4]
    ADD CONSTRAINT ck_round_type
        CHECK (round_type IN ('Field','3D','Target','Indoor','Shoot-off'));   -- C27

ALTER TABLE target_station
    ADD CONSTRAINT ck_target_number CHECK (target_number BETWEEN 1 AND 28),   -- targetNumber [1..28]
    ADD CONSTRAINT ck_target_group  CHECK (target_group  BETWEEN 1 AND 4);    -- C8

ALTER TABLE participant
    ADD CONSTRAINT ck_participant_birth_past CHECK (birth_date <= CURRENT_DATE); -- C99

ALTER TABLE competition_category
    ADD CONSTRAINT ck_category_style
        CHECK (style IN ('Freestyle','Bowhunter','Traditional','Recurve','Compound')), -- C28
    ADD CONSTRAINT ck_category_division
        CHECK (division IN ('Men','Women','Youth','Senior','Mixed')),         -- C29
    ADD CONSTRAINT ck_category_class
        CHECK (class_level IN ('Pro','Senior','Amateur','Beginner','Junior')); -- C30

ALTER TABLE registration
    ADD CONSTRAINT ck_registration_fee
        CHECK (entry_fee_status IN ('unpaid','paid','waived','refunded')),    -- C31
    ADD CONSTRAINT ck_registration_equipment
        CHECK (equipment_status IN ('unverified','verified','rejected')),     -- C32
    -- C101: if classification is verified, the verification date is required.
    ADD CONSTRAINT ck_registration_classification_date
        CHECK (classification_verified = FALSE OR classification_date IS NOT NULL);

ALTER TABLE start_group
    ADD CONSTRAINT ck_start_group_start_target
        CHECK (start_target BETWEEN 1 AND 28);                               -- C103 (range subset)

ALTER TABLE shot_result
    ADD CONSTRAINT ck_shot_arrow_number
        CHECK (arrow_number BETWEEN 1 AND 6),                               -- C36
    ADD CONSTRAINT ck_shot_target_number
        CHECK (target_number BETWEEN 1 AND 28),                             -- C7 / domain
    ADD CONSTRAINT ck_shot_hit_zone
        CHECK (hit_zone IN ('10','9','8','7','6','5','M','RM'));             -- C37 / C106

ALTER TABLE tournament_result
    ADD CONSTRAINT ck_tournament_tie_break_status
        CHECK (tie_break_status IS NULL
               OR tie_break_status IN ('not-needed','pending','completed','exempted')); -- C38

ALTER TABLE tie_break
    ADD CONSTRAINT ck_tie_break_round CHECK (tie_break_round BETWEEN 1 AND 4); -- domain

ALTER TABLE protest
    ADD CONSTRAINT ck_protest_decision
        CHECK (protest_decision IN ('pending','upheld','denied','appeal'));  -- C40 / C111

ALTER TABLE target_distance
    ADD CONSTRAINT ck_target_distance_positive CHECK (max_distance > 0);      -- domain

-- ---------------------------------------------------------------------
--  3) Foreign keys with referential actions - A03 C71..C98
--     ON UPDATE CASCADE throughout (A03: surrogate-id correction, rare).
--     ON DELETE per A03 referential-actions-table.md.
-- ---------------------------------------------------------------------

-- Round (C71)
ALTER TABLE round
    ADD CONSTRAINT fk_round_event FOREIGN KEY (event_id)
        REFERENCES event (event_id) ON DELETE NO ACTION ON UPDATE CASCADE;

-- shooting_range (C72) - optional official -> SET NULL
ALTER TABLE shooting_range
    ADD CONSTRAINT fk_range_official FOREIGN KEY (official_id)
        REFERENCES official (official_id) ON DELETE SET NULL ON UPDATE CASCADE;

-- target_station (C73) - weak entity
ALTER TABLE target_station
    ADD CONSTRAINT fk_target_station_range FOREIGN KEY (range_id)
        REFERENCES shooting_range (range_id) ON DELETE NO ACTION ON UPDATE CASCADE;

-- participant (C74, C75)
ALTER TABLE participant
    ADD CONSTRAINT fk_participant_nation FOREIGN KEY (nation_code)
        REFERENCES nation (nation_code) ON DELETE NO ACTION ON UPDATE CASCADE,
    ADD CONSTRAINT fk_participant_club FOREIGN KEY (club_id)
        REFERENCES club (club_id) ON DELETE SET NULL ON UPDATE CASCADE;

-- registration (C76, C77, C78)
ALTER TABLE registration
    ADD CONSTRAINT fk_registration_participant FOREIGN KEY (participant_id)
        REFERENCES participant (participant_id) ON DELETE NO ACTION ON UPDATE CASCADE,
    ADD CONSTRAINT fk_registration_event FOREIGN KEY (event_id)
        REFERENCES event (event_id) ON DELETE NO ACTION ON UPDATE CASCADE,
    ADD CONSTRAINT fk_registration_category FOREIGN KEY (category_id)
        REFERENCES competition_category (category_id) ON DELETE NO ACTION ON UPDATE CASCADE;

-- start_group (C79, C80)
ALTER TABLE start_group
    ADD CONSTRAINT fk_start_group_round FOREIGN KEY (round_id)
        REFERENCES round (round_id) ON DELETE NO ACTION ON UPDATE CASCADE,
    ADD CONSTRAINT fk_start_group_range FOREIGN KEY (range_id)
        REFERENCES shooting_range (range_id) ON DELETE NO ACTION ON UPDATE CASCADE;

-- score_card (C81, C82, C83, C84)
ALTER TABLE score_card
    ADD CONSTRAINT fk_score_card_registration FOREIGN KEY (registration_id)
        REFERENCES registration (registration_id) ON DELETE NO ACTION ON UPDATE CASCADE,
    ADD CONSTRAINT fk_score_card_round FOREIGN KEY (round_id)
        REFERENCES round (round_id) ON DELETE NO ACTION ON UPDATE CASCADE,
    ADD CONSTRAINT fk_score_card_official FOREIGN KEY (official_id)
        REFERENCES official (official_id) ON DELETE SET NULL ON UPDATE CASCADE,
    ADD CONSTRAINT fk_score_card_range FOREIGN KEY (range_id)
        REFERENCES shooting_range (range_id) ON DELETE NO ACTION ON UPDATE CASCADE;

-- shot_result (C85, C86, C87)
ALTER TABLE shot_result
    ADD CONSTRAINT fk_shot_result_score_card FOREIGN KEY (score_card_id)
        REFERENCES score_card (score_card_id) ON DELETE NO ACTION ON UPDATE CASCADE,
    ADD CONSTRAINT fk_shot_result_tie_break FOREIGN KEY (tie_break_id)
        REFERENCES tie_break (tie_break_id) ON DELETE SET NULL ON UPDATE CASCADE;
-- C86: composite atTarget FK (score_card.range_id, shot_result.target_number)
--      -> target_station. Enforced via a constraint trigger in V0.6 because
--      the parent key columns live in two tables (see reflection).

-- tournament_result (C88)
ALTER TABLE tournament_result
    ADD CONSTRAINT fk_tournament_result_registration FOREIGN KEY (registration_id)
        REFERENCES registration (registration_id) ON DELETE NO ACTION ON UPDATE CASCADE;

-- protest (C89, C90)
ALTER TABLE protest
    ADD CONSTRAINT fk_protest_official FOREIGN KEY (official_id)
        REFERENCES official (official_id) ON DELETE NO ACTION ON UPDATE CASCADE,
    ADD CONSTRAINT fk_protest_registration FOREIGN KEY (registration_id)
        REFERENCES registration (registration_id) ON DELETE NO ACTION ON UPDATE CASCADE;

-- bridge relations (C91..C96) - CASCADE both ways
ALTER TABLE round_range
    ADD CONSTRAINT fk_round_range_round FOREIGN KEY (round_id)
        REFERENCES round (round_id) ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_round_range_range FOREIGN KEY (range_id)
        REFERENCES shooting_range (range_id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE start_group_member
    ADD CONSTRAINT fk_sgm_group FOREIGN KEY (group_id)
        REFERENCES start_group (group_id) ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_sgm_registration FOREIGN KEY (registration_id)
        REFERENCES registration (registration_id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE tie_break_participant
    ADD CONSTRAINT fk_tbp_tie_break FOREIGN KEY (tie_break_id)
        REFERENCES tie_break (tie_break_id) ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_tbp_registration FOREIGN KEY (registration_id)
        REFERENCES registration (registration_id) ON DELETE CASCADE ON UPDATE CASCADE;

-- association relation (C97, C98)
ALTER TABLE target_distance
    ADD CONSTRAINT fk_target_distance_station FOREIGN KEY (range_id, target_number)
        REFERENCES target_station (range_id, target_number) ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_target_distance_category FOREIGN KEY (category_id)
        REFERENCES competition_category (category_id) ON DELETE NO ACTION ON UPDATE CASCADE;
