-- =====================================================================
--  IFAA WBHC 2027 - Indexes (File Organization & Access Paths)
--  Assignment 04 - Exercise 3, Step 4.2/4.3
--  Target DBMS: PostgreSQL 16
--  Flyway migration: V0.3
-- ---------------------------------------------------------------------
--  File organization (Step 4.2): PostgreSQL heap-organized tables with
--  default btree secondary indexes. Rationale in the documentation
--  (physical-access-path section) and assets/reports/index-catalog.md.
--
--  IMPORTANT: PostgreSQL auto-creates a btree index for every PRIMARY
--  KEY and UNIQUE constraint, but NOT for foreign-key columns. The
--  indexes below therefore cover (a) FK join/cascade columns and
--  (b) transaction-specific composite/filter paths (T1..T8).
--  Each index is justified in assets/reports/index-catalog.md.
-- =====================================================================

SET search_path TO wbhc;

-- ---- Foreign-key indexes (join + ON DELETE/UPDATE performance) -------
CREATE INDEX idx_round_event              ON round (event_id);                 -- T3,T8
CREATE INDEX idx_range_official           ON shooting_range (official_id);     -- cascade SET NULL
CREATE INDEX idx_participant_nation       ON participant (nation_code);        -- T5,T8 group by nation
CREATE INDEX idx_participant_club         ON participant (club_id);            -- cascade SET NULL
CREATE INDEX idx_registration_participant ON registration (participant_id);    -- T1,T5
CREATE INDEX idx_registration_event       ON registration (event_id);          -- T1,T8
CREATE INDEX idx_registration_category    ON registration (category_id);       -- T5,T8 ranking
CREATE INDEX idx_start_group_round        ON start_group (round_id);           -- T3
CREATE INDEX idx_start_group_range        ON start_group (range_id);           -- T3
CREATE INDEX idx_sgm_registration         ON start_group_member (registration_id); -- T3 reverse lookup
CREATE INDEX idx_score_card_round         ON score_card (round_id);            -- T4,T5,T8
CREATE INDEX idx_score_card_official      ON score_card (official_id);         -- cascade SET NULL
CREATE INDEX idx_score_card_range         ON score_card (range_id);            -- T4 target validation
CREATE INDEX idx_shot_result_tie_break    ON shot_result (tie_break_id);       -- T6
CREATE INDEX idx_protest_official         ON protest (official_id);            -- T7
CREATE INDEX idx_protest_registration     ON protest (registration_id);        -- T7
CREATE INDEX idx_tbp_registration         ON tie_break_participant (registration_id); -- T6
CREATE INDEX idx_target_distance_category ON target_distance (category_id);    -- config lookup

-- ---- Transaction-specific composite indexes --------------------------
-- T4 (highest write volume): raw shot rows are read back per score card
-- ordered by target/arrow. The PK (score_card_id,target_number,arrow_number)
-- already serves this, so no extra index is required for T4 reads.

-- T5/T8 ranking export: aggregate score_cards per registration; the
-- unique (registration_id, round_id) index already covers this join.
-- Add a covering composite to accelerate per-registration total scans:
CREATE INDEX idx_score_card_reg_round_incl
    ON score_card (registration_id, round_id) INCLUDE (range_id);            -- T5,T8

-- Ranking is produced per category; support ORDER-friendly scans:
CREATE INDEX idx_registration_event_category
    ON registration (event_id, category_id);                                -- T5,T8

-- T2 admission control: frequently filters registrations still pending
-- classification. Partial index keeps it tiny (only unverified rows).
CREATE INDEX idx_registration_unverified
    ON registration (event_id)
    WHERE classification_verified = FALSE;                                  -- T2

-- T7 protest triage: open protests only (small hot set).
CREATE INDEX idx_protest_open
    ON protest (registration_id)
    WHERE protest_decision = 'pending';                                     -- T7
