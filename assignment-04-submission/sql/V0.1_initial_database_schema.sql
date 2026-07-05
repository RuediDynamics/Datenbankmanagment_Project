-- =====================================================================
--  IFAA WBHC 2027 - Physical Database Schema (Base Relations)
--  Assignment 04 - Exercise 2, Step 3.1: Design Base Relations
--  Target DBMS: PostgreSQL 16
--  Flyway migration: V0.1  (initial physical model)
-- ---------------------------------------------------------------------
--  Traceability:
--    - Logical relations & keys  -> Assignment 03, Task 1 (@tbl-t1-mapping)
--    - Normalization (>= 3NF)     -> Assignment 03, Task 2
--    - Revised FK ScoreCard.range -> Assignment 03, Task 3 (iteration 1)
--  Naming conventions (see Exercise 1 context):
--    tables            : singular snake_case
--    surrogate PK      : <table>_id BIGINT GENERATED ALWAYS AS IDENTITY
--    constraint prefix : pk_ uq_ fk_ ck_  |  idx_ trg_ fn_ v_ mv_
--  NOTE: only columns, defaults, NOT NULL and PRIMARY KEYs are defined
--        here. Foreign keys, CHECK/UNIQUE and triggers live in V0.2;
--        indexes in V0.3; derived objects (views/matview/functions) in
--        V0.4. This initial model stores ScoreCard WITHOUT round_total
--        (derived on demand); the stored/materialized variant is the
--        documented iteration in V0.6.
-- =====================================================================

CREATE SCHEMA IF NOT EXISTS wbhc;
SET search_path TO wbhc;

-- ---------------------------------------------------------------------
--  Reference / lookup relations (no FK dependencies)
-- ---------------------------------------------------------------------

-- Nation: ISO 3166-1 alpha-3 natural key (e.g. 'GBR', 'AUT').
CREATE TABLE nation (
    nation_code   CHAR(3)       NOT NULL,
    nation_name   VARCHAR(100)  NOT NULL,
    CONSTRAINT pk_nation PRIMARY KEY (nation_code)
);

CREATE TABLE club (
    club_id       BIGINT        GENERATED ALWAYS AS IDENTITY,
    club_name     VARCHAR(100)  NOT NULL,
    CONSTRAINT pk_club PRIMARY KEY (club_id)
);

CREATE TABLE competition_category (
    category_id   BIGINT        GENERATED ALWAYS AS IDENTITY,
    style         VARCHAR(20)   NOT NULL,
    division      VARCHAR(20)   NOT NULL,
    class_level   VARCHAR(20)   NOT NULL,
    CONSTRAINT pk_competition_category PRIMARY KEY (category_id)
);

CREATE TABLE official (
    official_id       BIGINT        GENERATED ALWAYS AS IDENTITY,
    first_name        VARCHAR(50)   NOT NULL,
    last_name         VARCHAR(50)   NOT NULL,
    official_function VARCHAR(30)   NOT NULL,
    CONSTRAINT pk_official PRIMARY KEY (official_id)
);

-- ---------------------------------------------------------------------
--  Event / competition structure
-- ---------------------------------------------------------------------

CREATE TABLE event (
    event_id        BIGINT        GENERATED ALWAYS AS IDENTITY,
    name            VARCHAR(100)  NOT NULL,
    start_date      DATE          NOT NULL,
    end_date        DATE          NOT NULL,
    location        VARCHAR(100),
    organizer       VARCHAR(100),
    ifaa_reference  VARCHAR(20),
    CONSTRAINT pk_event PRIMARY KEY (event_id)
);

CREATE TABLE round (
    round_id      BIGINT        GENERATED ALWAYS AS IDENTITY,
    event_id      BIGINT        NOT NULL,
    round_number  SMALLINT      NOT NULL,
    round_type    VARCHAR(20)   NOT NULL,
    round_date    DATE          NOT NULL,
    CONSTRAINT pk_round PRIMARY KEY (round_id)
);

-- "range" is a reserved word in SQL/PostgreSQL -> physical name shooting_range.
CREATE TABLE shooting_range (
    range_id      BIGINT        GENERATED ALWAYS AS IDENTITY,
    official_id   BIGINT,                         -- optional (assignedToRange)
    range_name    VARCHAR(50)   NOT NULL,
    CONSTRAINT pk_shooting_range PRIMARY KEY (range_id)
);

-- Weak entity: existence-dependent on shooting_range; composite PK.
CREATE TABLE target_station (
    range_id      BIGINT        NOT NULL,
    target_number SMALLINT      NOT NULL,
    target_group  SMALLINT      NOT NULL,
    CONSTRAINT pk_target_station PRIMARY KEY (range_id, target_number)
);

-- ---------------------------------------------------------------------
--  People and registrations
-- ---------------------------------------------------------------------

CREATE TABLE participant (
    participant_id BIGINT       GENERATED ALWAYS AS IDENTITY,
    nation_code    CHAR(3)      NOT NULL,
    club_id        BIGINT,                        -- optional (memberOf)
    first_name     VARCHAR(50)  NOT NULL,
    last_name      VARCHAR(50)  NOT NULL,
    birth_date     DATE         NOT NULL,
    CONSTRAINT pk_participant PRIMARY KEY (participant_id)
);

CREATE TABLE registration (
    registration_id        BIGINT      GENERATED ALWAYS AS IDENTITY,
    participant_id         BIGINT      NOT NULL,
    event_id               BIGINT      NOT NULL,
    category_id            BIGINT      NOT NULL,
    entry_fee_status       VARCHAR(15) NOT NULL DEFAULT 'unpaid',
    equipment_status       VARCHAR(15) NOT NULL DEFAULT 'unverified',
    classification_verified BOOLEAN    NOT NULL DEFAULT FALSE,
    classification_date    TIMESTAMPTZ,
    CONSTRAINT pk_registration PRIMARY KEY (registration_id)
);

-- ---------------------------------------------------------------------
--  Scheduling: start groups
-- ---------------------------------------------------------------------

CREATE TABLE start_group (
    group_id      BIGINT        GENERATED ALWAYS AS IDENTITY,
    round_id      BIGINT        NOT NULL,
    range_id      BIGINT        NOT NULL,
    group_number  SMALLINT      NOT NULL,
    start_target  SMALLINT      NOT NULL,
    CONSTRAINT pk_start_group PRIMARY KEY (group_id)
);

-- ---------------------------------------------------------------------
--  Scoring: score cards and raw shot results
--  (INITIAL model: no stored round_total -> derived in V0.4 view)
-- ---------------------------------------------------------------------

CREATE TABLE score_card (
    score_card_id  BIGINT       GENERATED ALWAYS AS IDENTITY,
    registration_id BIGINT      NOT NULL,
    round_id       BIGINT       NOT NULL,
    official_id    BIGINT,                        -- optional signature (signedBy)
    range_id       BIGINT       NOT NULL,         -- A03 Task-3 iteration (denormalized FK)
    CONSTRAINT pk_score_card PRIMARY KEY (score_card_id)
);

-- Weak entity: existence-dependent on score_card; composite PK.
CREATE TABLE shot_result (
    score_card_id BIGINT        NOT NULL,
    target_number SMALLINT      NOT NULL,
    arrow_number  SMALLINT      NOT NULL,
    tie_break_id  BIGINT,                         -- optional (usesShot)
    hit_zone      VARCHAR(2)    NOT NULL,
    CONSTRAINT pk_shot_result PRIMARY KEY (score_card_id, target_number, arrow_number)
);

-- ---------------------------------------------------------------------
--  Results, tie-breaks, protests
-- ---------------------------------------------------------------------

CREATE TABLE tie_break (
    tie_break_id    BIGINT      GENERATED ALWAYS AS IDENTITY,
    tie_break_round SMALLINT    NOT NULL,
    CONSTRAINT pk_tie_break PRIMARY KEY (tie_break_id)
);

CREATE TABLE tournament_result (
    result_id       BIGINT      GENERATED ALWAYS AS IDENTITY,
    registration_id BIGINT      NOT NULL,
    tie_break_status VARCHAR(15),
    CONSTRAINT pk_tournament_result PRIMARY KEY (result_id)
);

CREATE TABLE protest (
    protest_id          BIGINT      GENERATED ALWAYS AS IDENTITY,
    official_id         BIGINT      NOT NULL,
    registration_id     BIGINT      NOT NULL,
    protest_date        TIMESTAMPTZ NOT NULL DEFAULT now(),
    protest_description TEXT        NOT NULL,
    protest_decision    VARCHAR(15) NOT NULL DEFAULT 'pending',
    CONSTRAINT pk_protest PRIMARY KEY (protest_id)
);

-- ---------------------------------------------------------------------
--  Bridge relations (resolved *:* relationships) - all-key
-- ---------------------------------------------------------------------

CREATE TABLE round_range (
    round_id  BIGINT NOT NULL,
    range_id  BIGINT NOT NULL,
    CONSTRAINT pk_round_range PRIMARY KEY (round_id, range_id)
);

CREATE TABLE start_group_member (
    group_id        BIGINT NOT NULL,
    registration_id BIGINT NOT NULL,
    CONSTRAINT pk_start_group_member PRIMARY KEY (group_id, registration_id)
);

CREATE TABLE tie_break_participant (
    tie_break_id    BIGINT NOT NULL,
    registration_id BIGINT NOT NULL,
    CONSTRAINT pk_tie_break_participant PRIMARY KEY (tie_break_id, registration_id)
);

-- ---------------------------------------------------------------------
--  Association relation (association class TargetDistance)
-- ---------------------------------------------------------------------

CREATE TABLE target_distance (
    range_id      BIGINT   NOT NULL,
    target_number SMALLINT NOT NULL,
    category_id   BIGINT   NOT NULL,
    max_distance  SMALLINT NOT NULL,
    CONSTRAINT pk_target_distance PRIMARY KEY (range_id, target_number, category_id)
);
