## Task 2: Physical Schema Specification (Step 3) {#sec-task2-physical-schema}

**Exercise 2 – Translate Logical Data Model for Target DBMS**
(Connolly & Begg, Kap. 18, Step 3.1–3.3)

Diese Sektion überführt das **revidierte logische Modell aus Assignment 03** (20
Relationen inkl. `ScoreCard.rangeId`-Iteration) in ein PostgreSQL-16-spezifisches
physisches Schema. Die Umsetzung liegt in
[`sql/V0.1_initial_database_schema.sql`](../sql/V0.1_initial_database_schema.sql)
(Basisrelationen) und
[`sql/V0.2_constraints.sql`](../sql/V0.2_constraints.sql) (Schlüssel, FKs, Checks).

Das initiale physische Modell ist @fig-physical-initial, das revidierte (nach den
Test-Iterationen in @sec-task6-test-report) ist @fig-physical-revised.

![Initiales physisches Datenmodell (PostgreSQL 16). Quelle: `assets/diagrams/physical-model-initial.puml`](./assets/diagrams/physical-model-initial.png){#fig-physical-initial}

### Step 3.1 – Design Base Relations {#sec-t2p-step31}

**Typwahl-Grundsätze.** Surrogatschlüssel sind `BIGINT GENERATED ALWAYS AS
IDENTITY` (Standard-konform, kein Sequenz-Handling, keine manuelle ID-Vergabe,
zukunftssicher gegen Wertebereichs-Erschöpfung). Kleine bounded-Ganzzahlen
(`round_number`, `target_number`, `hit_zone`-Werte) nutzen `SMALLINT`.
Aufzählungs-Domänen aus Assignment 03 (ENUM im logischen Modell) werden als
`VARCHAR(n) + CHECK` realisiert statt als PostgreSQL-`ENUM`-Typ — das erhält die
Erweiterbarkeit der Wertelisten ohne Typ-Migration und hält die Regel sichtbar im
Constraint (Trade-off: minimal höherer Speicher). Zeitstempel für Audit-Zwecke
sind `TIMESTAMPTZ`.

Die vollständige Abbildung jeder Relation zeigt @tbl-physical-relation-specification.

| Logical relation | Physical table | Columns (type, null/default) | PK | AK | FK(s) | Notes/rationale |
|---|---|---|---|---|---|---|
| `Event` | `event` | `event_id bigint identity; name varchar(100) NN; start_date date NN; end_date date NN; location varchar(100); organizer varchar(100); ifaa_reference varchar(20)` | `event_id` | `(name, start_date)` | – | Aggregat-Root. |
| `Round` | `round` | `round_id bigint identity; event_id bigint NN; round_number smallint NN; round_type varchar(20) NN; round_date date NN` | `round_id` | `(event_id, round_number)` | `event_id → event` | `round_number` als SMALLINT (1..4). |
| `Range` | `shooting_range` | `range_id bigint identity; official_id bigint NULL; range_name varchar(50) NN` | `range_id` | `range_name` | `official_id → official` | Umbenannt (reserviertes Wort `RANGE`). |
| `TargetStation` | `target_station` | `range_id bigint NN; target_number smallint NN; target_group smallint NN` | `(range_id, target_number)` | – | `range_id → shooting_range` | Schwache Entität, composite PK. |
| `Nation` | `nation` | `nation_code char(3) NN; nation_name varchar(100) NN` | `nation_code` | `nation_name` | – | Natürlicher Schlüssel (ISO-3166 alpha-3). |
| `Club` | `club` | `club_id bigint identity; club_name varchar(100) NN` | `club_id` | `club_name` | – | – |
| `Participant` | `participant` | `participant_id bigint identity; nation_code char(3) NN; club_id bigint NULL; first_name varchar(50) NN; last_name varchar(50) NN; birth_date date NN` | `participant_id` | – | `nation_code → nation`; `club_id → club` | Subtyp von Person (Namen kopiert, A03 R1). |
| `Official` | `official` | `official_id bigint identity; first_name varchar(50) NN; last_name varchar(50) NN; official_function varchar(30) NN` | `official_id` | – | – | Subtyp von Person. |
| `CompetitionCategory` | `competition_category` | `category_id bigint identity; style varchar(20) NN; division varchar(20) NN; class_level varchar(20) NN` | `category_id` | `(style, division, class_level)` | – | – |
| `Registration` | `registration` | `registration_id bigint identity; participant_id bigint NN; event_id bigint NN; category_id bigint NN; entry_fee_status varchar(15) NN default 'unpaid'; equipment_status varchar(15) NN default 'unverified'; classification_verified boolean NN default false; classification_date timestamptz NULL` | `registration_id` | `(participant_id, event_id)` | `participant_id → participant`; `event_id → event`; `category_id → competition_category` | Defaults spiegeln Initialzustand des Workflows (T1/T2). |
| `StartGroup` | `start_group` | `group_id bigint identity; round_id bigint NN; range_id bigint NN; group_number smallint NN; start_target smallint NN` | `group_id` | `(round_id, group_number)` | `round_id → round`; `range_id → shooting_range` | – |
| `ScoreCard` | `score_card` | `score_card_id bigint identity; registration_id bigint NN; round_id bigint NN; official_id bigint NULL; range_id bigint NN` | `score_card_id` | `(registration_id, round_id)` | `registration_id → registration`; `round_id → round`; `official_id → official`; `range_id → shooting_range` | `range_id` = A03-Iteration (kontrollierte Denormalisierung). `round_total` erst im revidierten Modell (Step 3.2). |
| `ShotResult` | `shot_result` | `score_card_id bigint NN; target_number smallint NN; arrow_number smallint NN; tie_break_id bigint NULL; hit_zone varchar(2) NN` | `(score_card_id, target_number, arrow_number)` | – | `score_card_id → score_card`; `tie_break_id → tie_break`; *(atTarget: Trigger, s. Step 3.3)* | Schwache Entität, volumenintensiv. |
| `TournamentResult` | `tournament_result` | `result_id bigint identity; registration_id bigint NN; tie_break_status varchar(15) NULL` | `result_id` | `registration_id` | `registration_id → registration` | 1:1 via UNIQUE. |
| `TieBreak` | `tie_break` | `tie_break_id bigint identity; tie_break_round smallint NN` | `tie_break_id` | – | – | – |
| `Protest` | `protest` | `protest_id bigint identity; official_id bigint NN; registration_id bigint NN; protest_date timestamptz NN default now(); protest_description text NN; protest_decision varchar(15) NN default 'pending'` | `protest_id` | – | `official_id → official`; `registration_id → registration` | `protest_decision` State Machine. |
| `RoundRange` | `round_range` | `round_id bigint NN; range_id bigint NN` | `(round_id, range_id)` | – | beide → parents (CASCADE) | Brückenrelation. |
| `StartGroupMember` | `start_group_member` | `group_id bigint NN; registration_id bigint NN` | `(group_id, registration_id)` | – | beide → parents (CASCADE) | Brückenrelation. |
| `TieBreakParticipant` | `tie_break_participant` | `tie_break_id bigint NN; registration_id bigint NN` | `(tie_break_id, registration_id)` | – | beide → parents (CASCADE) | Brückenrelation. |
| `TargetDistance` | `target_distance` | `range_id bigint NN; target_number smallint NN; category_id bigint NN; max_distance smallint NN` | `(range_id, target_number, category_id)` | – | `(range_id, target_number) → target_station` (CASCADE); `category_id → competition_category` | Assoziationsrelation (Assoziationsklasse). |

: Physical relation specification {#tbl-physical-relation-specification}

**Nicht-triviale Mapping-Entscheidungen (Rationale):**

- **`shooting_range`** statt `range`: Vermeidung des reservierten Worts; ein
  einziges DBMS-spezifisches Rename, konsistent in allen FKs.
- **`BIGINT`-Surrogate** trotz erwarteter kleiner Zeilenzahlen: Uniformität und
  Zukunftssicherheit (Mehr-Event-Serie, A03 Task 5) überwiegen die 4 Byte
  Mehrverbrauch gegenüber `INTEGER`.
- **`nation_code CHAR(3)`** als natürlicher PK: ISO-3166 alpha-3 ist stabil und
  fachlich aussagekräftig; kein Surrogat nötig (A03 C48).
- **`VARCHAR + CHECK` statt `ENUM`-Typ**: Werteliste bleibt datennah und leicht
  erweiterbar (z. B. neue `round_type`), ohne `ALTER TYPE`-Migration.

### Step 3.2 – Design Representation of Derived Data {#sec-t2p-step32}

Assignment 03 (Task 1 (l)) markiert `age`, `pointValue`, `roundTotal`,
`totalPoints`, `rankPosition`, `numberOfTargets` als abgeleitet. Für jedes Attribut
wird zwischen *computed on demand* und *materialized/stored* entschieden. Die
Umsetzung liegt in
[`sql/V0.4_derived_objects.sql`](../sql/V0.4_derived_objects.sql) bzw. — für die
gespeicherte Variante — in
[`sql/V0.6_revised_physical_model.sql`](../sql/V0.6_revised_physical_model.sql).

| Derived attribute | Source relation(s) | Representation (computed/stored) | Implementation (view/column/trigger/etc.) | Consistency strategy | Rationale |
|---|---|---|---|---|---|
| `age` | `participant` | computed | `fn_participant_age()` + view `v_participant` | immer berechnet | Ändert sich täglich; Speicherung wäre sofort veraltet. Kein `CHECK`-Bedarf. |
| `numberOfTargets` | `target_station` | computed | view `v_range_config` (COUNT) | immer berechnet | Selten gelesen (nur T3-Setup); billig. |
| `pointValue` | `shot_result`, `round`, `scoring_rule` | computed (datengetrieben) | view `v_shot_score` ⋈ `scoring_rule` | Lookup-Tabelle; Regeländerung = 1 Row-Update | Regelwerk als Daten (A03 Future Growth); keine Logik im Code. |
| `roundTotal` | `score_card`, `shot_result` | **iteriert: computed → stored** | *initial:* view `v_score_card_total`; *revised:* Spalte `score_card.round_total` + Trigger `trg_shot_result_total` | Trigger pflegt inkrementell bei INSERT/UPDATE/DELETE | Lese-/Schreib-Trade-off (siehe @sec-task6-test-report Iteration A). |
| `totalPoints` | `score_card` (round_total) | materialized | `mv_tournament_ranking` (SUM) | Batch-`REFRESH` via `fn_refresh_rankings()` nach Scoring-Fenster | Aggregat über viele Zeilen; leseintensiv (T5/T8), selten aktualisiert. |
| `rankPosition` | `mv_tournament_ranking` | materialized | `RANK() OVER (PARTITION BY event, category …)` | mit `total_points` gemeinsam aktualisiert | Rang ist relativ; nur im Kontext aller Ergebnisse berechenbar. |

: Derived data design {#tbl-derived-data-design}

**Konsistenz der materialisierten Rangliste.** `mv_tournament_ranking` wird nicht
bei jedem Schuss aktualisiert (das würde T4 ausbremsen), sondern kontrolliert per
`REFRESH MATERIALIZED VIEW CONCURRENTLY` nach Abschluss eines Erfassungsfensters.
Der `CONCURRENTLY`-Modus setzt einen `UNIQUE`-Index (`idx_mv_ranking_registration`)
voraus und blockiert konkurrierende Lesezugriffe nicht — passend zu den
Live-Ranglisten der Stakeholder (T5).

### Step 3.3 – Design General Constraints {#sec-t2p-step33}

Über Schlüssel und Domänen-`CHECK`s hinaus (vollständig in
[`V0.2_constraints.sql`](../sql/V0.2_constraints.sql), abgeleitet aus A03 C1–C112)
verbleiben Geschäftsregeln, die eine erweiterte Durchsetzung erfordern:

| A03-Regel | Inhalt | DBMS-Mechanismus | Umsetzung / Fallback |
|---|---|---|---|
| C25 | `start_date ≤ end_date` | `CHECK` | `ck_event_date_order` (in-row) |
| C31/C32/C40 | Status-Wertelisten | `CHECK` | `ck_registration_fee`, `ck_registration_equipment`, `ck_protest_decision` |
| C37/C106 | IFAA Hit-Zones | `CHECK` | `ck_shot_hit_zone` |
| C57/C61/C64 | Alternate Keys / 1:1 | `UNIQUE` | `uq_registration_participant_event`, `uq_score_card_reg_round`, `uq_tournament_result_registration` |
| C99 | Geburtsdatum ≤ heute | `CHECK (birth_date <= CURRENT_DATE)` | `ck_participant_birth_past` (write-time) |
| C101 | verified ⇒ Datum gesetzt | `CHECK` (intra-row Implikation) | `ck_registration_classification_date` |
| **C86** | atTarget: `(score_card.range_id, target_number)` gültige Station | **Trigger** (parent-key über 2 Tabellen) | `trg_shot_result_target_check` (Iteration B, V0.6) |
| C26 | `round_date` im Event-Fenster | Trigger *(Fallback)* | Dokumentiert; Trigger optional, hier Anwendungsschicht (niedriges Risiko: 4 feste Runden). |
| C103 | `start_target ≤ numberOfTargets(range)` | Trigger *(Fallback)* | `CHECK (start_target BETWEEN 1 AND 28)` deckt den Wertebereich ab; range-genaue Prüfung in Anwendungsschicht. |
| C105 | Pfeil-Sequenz 1..n | `CHECK` + Anwendungslogik | `ck_shot_arrow_number` (Bereich); lückenlose Sequenz app-seitig. |
| C110 | Protest-Fenster ≤ Event-Ende | Anwendungsschicht *(Fallback)* | Zeitfenster ist prozessual; `protest_date` default `now()`. |
| C112 | Schuss regulär XOR Stechen | Semantik über `tie_break_id IS NULL` | In `v_score_card_total` / Trigger-Aggregation berücksichtigt. |

**Fallback-Prinzip.** Wo PostgreSQL eine Regel nicht als deklarative in-row-
Bedingung erzwingen kann, gilt die dokumentierte Reihenfolge: (1) Trigger, wenn die
Regel dateninduziert und kritisch ist (C86); (2) Wertebereichs-`CHECK` als
Teilabsicherung plus Anwendungslogik, wenn eine zeilenübergreifende Prüfung nur
selten verletzt werden kann (C103, C105); (3) reine Anwendungsschicht bei rein
prozessualen Regeln (C110). Diese Zuordnung ist eine bewusste, dokumentierte
Design-Entscheidung im Sinne der Assignment-Vorgabe „If your DBMS does not support
a specific mechanism directly, document your fallback strategy."
