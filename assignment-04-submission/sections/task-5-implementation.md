## Task 5: Implementation Package & Object Inventory {#sec-task5-implementation}

**Exercise 5 – Implement Physical Model in the Target DBMS**

Das physische Modell ist als versionierte, ausführbare SQL-Skripte im
Flyway-Namensschema umgesetzt (Verzeichnis [`sql/`](../sql/)). Die Skripte sind in
strikter Reihenfolge anzuwenden.

### Ausführungsreihenfolge {#sec-t5p-order}

```text
V0.1_initial_database_schema.sql   -- CREATE SCHEMA + 21 Basistabellen, PKs, Defaults
V0.2_constraints.sql               -- AKs (UNIQUE), CHECKs, 28 FKs mit ON DELETE/UPDATE
V0.3_indexes.sql                   -- FK-Indizes + transaktionsspezifische/partielle Indizes
V0.4_derived_objects.sql           -- scoring_rule, Views, Materialized View, Funktionen
V0.5_seed_data.sql                 -- repräsentative Testdaten (deterministisch)
V0.6_revised_physical_model.sql    -- ITERATION: stored round_total + Trigger, atTarget-Trigger
R__test_cases.sql                  -- wiederholbare Funktions-/Constraint-/Performance-Tests
```

**Reproduzierbare Anwendung (psql):**

```bash
createdb wbhc2027
for f in sql/V0.1_* sql/V0.2_* sql/V0.3_* sql/V0.4_* sql/V0.5_* sql/V0.6_*; do
  psql -d wbhc2027 -v ON_ERROR_STOP=1 -f "$f"
done
psql -d wbhc2027 -v ON_ERROR_STOP=1 -f sql/R__test_cases.sql
```

Alternativ per Flyway: `flyway migrate` (die `V`-Skripte laufen einmalig
versioniert, `R__test_cases.sql` bei jeder Migration erneut).

### Object Inventory {#sec-t5p-inventory}

Vollständiges Manifest aller implementierten Objekte (eine Zeile je Objekt).
FK-/CHECK-Constraints sind nach Tabelle gruppiert zusammengefasst; die
Einzel-Constraint-IDs (C1–C112) stehen als Inline-Kommentare in
[`V0.2_constraints.sql`](../sql/V0.2_constraints.sql).

| Object name | Type | Script | Linked design artifact | Purpose / notes |
|---|---|---|---|---|
| `event` … `target_distance` (21 Tabellen) | table | `V0.1` | @tbl-physical-relation-specification | Basis-, Brücken-, Assoziationsrelationen. |
| `scoring_rule` | table (lookup) | `V0.4` | @tbl-derived-data-design | Datengetriebenes IFAA-Punkte-Regelwerk. |
| `pk_event` … `pk_target_distance` (21 PKs) | primary key | `V0.1` | @tbl-physical-relation-specification | Entity Integrity (A03 C41–C70). |
| `uq_event_name_start` | unique (AK) | `V0.2` | Step 3.1 | Alternate Key (C42). |
| `uq_round_event_number` | unique (AK) | `V0.2` | Step 3.1 | C44. |
| `uq_range_name` | unique (AK) | `V0.2` | Step 3.1 | C46. |
| `uq_nation_name` | unique (AK) | `V0.2` | Step 3.1 | C49. |
| `uq_club_name` | unique (AK) | `V0.2` | Step 3.1 | C51. |
| `uq_category_triplet` | unique (AK) | `V0.2` | Step 3.1 | C55. |
| `uq_registration_participant_event` | unique (AK) | `V0.2` | Step 3.1 / C57 | Doppelanmeldungssperre. |
| `uq_start_group_round_number` | unique (AK) | `V0.2` | Step 3.1 | C59. |
| `uq_score_card_reg_round` | unique (AK) | `V0.2` | Step 3.1 / C61 | 1 Karte je Anmeldung/Runde. |
| `uq_tournament_result_registration` | unique (1:1) | `V0.2` | Step 3.1 / C64 | 1:1 Ergebnis. |
| `fk_round_event` … `fk_target_distance_category` (28 FKs) | foreign key | `V0.2` | referential-actions (A03 C71–C98) | Referential Integrity mit ON DELETE/UPDATE. |
| `ck_event_date_order` | check | `V0.2` | Step 3.3 | C25. |
| `ck_round_type`, `ck_round_number` | check | `V0.2` | Step 3.3 | C27 / Domäne. |
| `ck_target_number`, `ck_target_group` | check | `V0.2` | Step 3.3 | C7/C8. |
| `ck_participant_birth_past` | check | `V0.2` | Step 3.3 | C99. |
| `ck_category_style/division/class` | check | `V0.2` | Step 3.3 | C28–C30. |
| `ck_registration_fee/equipment` | check | `V0.2` | Step 3.3 | C31/C32. |
| `ck_registration_classification_date` | check | `V0.2` | Step 3.3 | C101 (intra-row Implikation). |
| `ck_start_group_start_target` | check | `V0.2` | Step 3.3 | C103 (Wertebereich). |
| `ck_shot_arrow_number`, `ck_shot_target_number`, `ck_shot_hit_zone` | check | `V0.2` | Step 3.3 | C36/C37/C106. |
| `ck_tournament_tie_break_status` | check | `V0.2` | Step 3.3 | C38. |
| `ck_tie_break_round` | check | `V0.2` | Step 3.3 | Domäne. |
| `ck_protest_decision` | check | `V0.2` | Step 3.3 | C40/C111. |
| `ck_target_distance_positive` | check | `V0.2` | Step 3.3 | Domäne. |
| `ck_score_card_round_total` | check | `V0.6` | Iteration A | round_total ≥ 0. |
| `idx_*` (21 Indizes) | index | `V0.3` | @tbl-index-catalog | FK-/Transaktions-/Partial-Indizes. |
| `idx_mv_ranking_registration` | unique index | `V0.4` | @tbl-index-catalog | Voraussetzung REFRESH CONCURRENTLY. |
| `idx_mv_ranking_category` | index | `V0.4` | @tbl-index-catalog | sortierte Rangliste. |
| `v_participant` | view | `V0.4` | @tbl-derived-data-design | age-Ableitung. |
| `v_range_config` | view | `V0.4` | @tbl-derived-data-design | numberOfTargets. |
| `v_shot_score` | view | `V0.4` | @tbl-derived-data-design | pointValue via scoring_rule. |
| `v_score_card_total` | view | `V0.4` | @tbl-derived-data-design | roundTotal (initial, computed). |
| `mv_tournament_ranking` | materialized view | `V0.4`/`V0.6` | @tbl-derived-data-design | totalPoints + rankPosition. |
| `fn_participant_age` | function | `V0.4` | @tbl-derived-data-design | age-Helfer. |
| `fn_refresh_rankings` | function | `V0.4` | @tbl-derived-data-design | Matview-Refresh (Konsistenz). |
| `fn_shot_point_value` | function | `V0.6` | Iteration A | Punktwert je Schuss. |
| `fn_shot_result_maintain_total` | function | `V0.6` | Iteration A | inkrementelle round_total-Pflege. |
| `trg_shot_result_total` | trigger | `V0.6` | Iteration A | pflegt score_card.round_total. |
| `fn_shot_result_target_check` | function | `V0.6` | Iteration B | atTarget-Prüfung (C86). |
| `trg_shot_result_target_check` | trigger | `V0.6` | Iteration B | erzwingt gültige (range,target). |

: Object inventory {#tbl-object-inventory}
