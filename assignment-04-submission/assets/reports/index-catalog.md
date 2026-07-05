# Index Catalog (Detailed)

**Assignment 04 – Exercise 3, Step 4.3**
Vollständiger Katalog aller explizit angelegten Indizes plus der von PostgreSQL
implizit erzeugten PK-/UNIQUE-Indizes. Umsetzung:
[`../../sql/V0.3_indexes.sql`](../../sql/V0.3_indexes.sql) und
[`../../sql/V0.4_derived_objects.sql`](../../sql/V0.4_derived_objects.sql).

## Implizite Indizes (automatisch durch PostgreSQL)

PostgreSQL legt für jeden `PRIMARY KEY` und jede `UNIQUE`-Bedingung einen
btree-Index an. Diese decken viele Join-/Lookup-Pfade bereits ab:

| Constraint | Index (implizit) | Deckt Pfad |
|---|---|---|
| 21× `pk_*` | PK-btree | Entity-Lookup, Weak-Entity-Ordnung (`pk_shot_result`, `pk_target_station`) |
| `uq_registration_participant_event` | UNIQUE-btree | T1 Doppelanmeldungsprüfung |
| `uq_score_card_reg_round` | UNIQUE-btree | T5/T8 Karten je Anmeldung (Join) |
| `uq_tournament_result_registration` | UNIQUE-btree | 1:1 Ergebnis-Join |
| `uq_category_triplet`, `uq_nation_name`, … | UNIQUE-btree | Lookups / AK-Zugriffe |

## Explizite Indizes (dieser Entwurf)

| Index name | Table | Column(s) | Type | Supporting transaction(s) | Expected benefit | Trade-off |
|---|---|---|---|---|---|---|
| `idx_round_event` | `round` | `event_id` | btree (FK) | T3, T8 | Join Event→Round ohne Seq-Scan | +Write, +~8 KB |
| `idx_range_official` | `shooting_range` | `official_id` | btree (FK) | Cascade SET NULL | schnelle Cascade | gering |
| `idx_participant_nation` | `participant` | `nation_code` | btree (FK) | T5, T8 | GROUP BY/Join Nation | gering |
| `idx_participant_club` | `participant` | `club_id` | btree (FK) | Cascade SET NULL | Cascade-Performance | gering |
| `idx_registration_participant` | `registration` | `participant_id` | btree (FK) | T1, T5 | Join Reg→Participant | gering |
| `idx_registration_event` | `registration` | `event_id` | btree (FK) | T1, T8 | Filter je Event | gering |
| `idx_registration_category` | `registration` | `category_id` | btree (FK) | T5, T8 | Ranking je Kategorie | gering |
| `idx_registration_event_category` | `registration` | `(event_id, category_id)` | composite btree | T5, T8 | Kategorie-Scan Rangbildung | +Write |
| `idx_registration_unverified` | `registration` | `event_id` WHERE `NOT classification_verified` | partial btree | T2 | winziger Hot-Set Startzulassung | Nutzen nur bei passendem Filter |
| `idx_start_group_round` | `start_group` | `round_id` | btree (FK) | T3 | Gruppen je Runde | gering |
| `idx_start_group_range` | `start_group` | `range_id` | btree (FK) | T3 | Gruppen je Range | gering |
| `idx_sgm_registration` | `start_group_member` | `registration_id` | btree (FK) | T3 | Reverse-Lookup Schütze→Gruppe | gering |
| `idx_score_card_round` | `score_card` | `round_id` | btree (FK) | T4, T5, T8 | Karten je Runde | +Write (4.800) |
| `idx_score_card_official` | `score_card` | `official_id` | btree (FK) | Cascade SET NULL | Cascade | gering |
| `idx_score_card_range` | `score_card` | `range_id` | btree (FK) | T4 | atTarget-Validierung | +Write |
| `idx_score_card_reg_round_incl` | `score_card` | `(registration_id, round_id) INCLUDE (range_id)` | covering btree | T5, T8 | Index-Only-Scan je Anmeldung | +Storage |
| `idx_shot_result_tie_break` | `shot_result` | `tie_break_id` | btree (FK) | T6 | Stechen-Schüsse finden | **+Write auf 201.600 Rows** |
| `idx_protest_official` | `protest` | `official_id` | btree (FK) | T7 | Proteste je Offiziellem | gering |
| `idx_protest_registration` | `protest` | `registration_id` | btree (FK) | T7 | Proteste je Anmeldung | gering |
| `idx_protest_open` | `protest` | `registration_id` WHERE `decision='pending'` | partial btree | T7 | offene Proteste (klein) | gering |
| `idx_tbp_registration` | `tie_break_participant` | `registration_id` | btree (FK) | T6 | Reverse-Lookup | gering |
| `idx_target_distance_category` | `target_distance` | `category_id` | btree (FK) | T3-Setup | Konfig-Lookup | gering |
| `idx_mv_ranking_registration` | `mv_tournament_ranking` | `registration_id` | unique btree | T5, T8 | Voraussetzung REFRESH CONCURRENTLY | – |
| `idx_mv_ranking_category` | `mv_tournament_ranking` | `(event_id, category_id, rank_position)` | btree | T5, T8 | sortierte Rangliste je Kategorie | +Storage |

## Entwurfsprinzipien

1. **Jeder FK erhält einen Index** — PostgreSQL indiziert FK-Spalten nicht
   automatisch; ohne Index würden Joins und `ON DELETE/UPDATE`-Aktionen zu
   Seq-Scans (relevant bei Cascade auf große Kinder).
2. **Partielle Indizes für Hot-Sets** (T2 unverifizierte Anmeldungen, T7 offene
   Proteste) — minimaler Speicher, minimale Schreiblast, maximale Selektivität.
3. **Covering-Index für Report-Pfade** (`INCLUDE (range_id)`) — ermöglicht
   Index-Only-Scans ohne Heap-Zugriff bei T5/T8.
4. **Kein Index auf `shot_result` außer `tie_break_id`** — Schutz des kritischen
   T4-Insert-Pfades; Lesereihenfolge liefert bereits der zusammengesetzte PK.
5. **Materialized-View-Indizes** — der Unique-Index ist funktional zwingend für
   `REFRESH … CONCURRENTLY`; der Kategorie-Index bedient die sortierte Rangausgabe.
