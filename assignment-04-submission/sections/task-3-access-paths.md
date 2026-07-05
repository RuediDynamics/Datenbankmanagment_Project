## Task 3: Transaction Analysis & Access Path Design (Step 4.1–4.3) {#sec-task3-access-paths}

**Exercise 3 – Transaction Analysis, File Organization, and Indexing**
(Connolly & Begg, Kap. 18, Step 4.1–4.3)

Diese Sektion analysiert die Kern-Transaktionen T1–T8 (Assignment 02/03) hinsichtlich
ihrer physischen Zugriffspfade und leitet daraus die Datei-Organisation und das
Indexkonzept ab. Der Index-Katalog liegt zusätzlich in
[`assets/reports/index-catalog.md`](../assets/reports/index-catalog.md), die
Umsetzung in [`sql/V0.3_indexes.sql`](../sql/V0.3_indexes.sql).

### Step 4.1 – Analyze Transactions {#sec-t3p-step41}

**Transaktions-Frequenz und -Kritikalität** (aus A02 Typ-Klassifikation und A03
Volumen). Zugriffsart: R = Read, I = Insert, U = Update, D = Delete.

| Transaction | Relation(s) touched | Access type (R/I/U/D) | Frequency/criticality | Notes |
|---|---|---|---|---|
| `T1: Teilnehmer anlegen` | `participant`, `registration`, `nation`, `club`, `competition_category`, `event` | I, R | Mittel (~1.200×, Anmeldephase) | Insert-Pfad; FK-Lookups auf Nation/Club/Category. |
| `T2: Klassifizierung prüfen` | `registration`, `participant`, `competition_category` | R, U | Mittel (~1.200×) | Filter auf `classification_verified = FALSE`; Punkt-Update. |
| `T3: Startgruppen erstellen` | `start_group`, `start_group_member`, `registration`, `round`, `shooting_range`, `target_station`, `round_range` | I, R | Mittel (pro Runde ×4) | Join Round↔Range↔Group; Bulk-Insert Mitglieder. |
| `T4: Scorekarte erfassen` | `score_card`, `shot_result`, `round`, `scoring_rule`, `target_station` | **I** (Massen), R | **Hoch/kritisch** (~4.800 Karten, ~270.000 Schüsse) | Volumen-Treiber; PK-geordnete Inserts; Trigger-Aggregation. |
| `T5: Rangliste anzeigen` | `mv_tournament_ranking`, `registration`, `competition_category`, `participant`, `nation`, `score_card` | R (aggregiert) | **Hoch** (Live, alle Rollen) | Aggregat/RANK; über Matview bedient. |
| `T6: Tie-Break erfassen` | `tie_break`, `tie_break_participant`, `shot_result`, `registration`, `tournament_result` | I, R, U | Niedrig (Ausnahmefall) | Kleine Datenmengen; Filter `tie_break_id`. |
| `T7: Protest dokumentieren` | `protest`, `official`, `registration` | I, U, R | Niedrig | Insert + State-Update; Filter offene Proteste. |
| `T8: Ergebnisliste exportieren` | `mv_tournament_ranking`, `registration`, `competition_category`, `participant`, `nation`, `score_card`, `round`, `event` | R (Report) | Mittel (mehrmals/Tag) | Wie T5, zusätzlich Round/Event-Projektion. |

: Transaction workload analysis {#tbl-transaction-workload}

**Transaction-to-Relation Cross-Reference Matrix** (physisch). Zeigt je Transaktion
die berührten *physischen* Tabellen und die dominante Zugriffsart.

| Transaction | Relation(s) touched | Access type (R/I/U/D) | Frequency/criticality | Notes |
|---|---|---|---|---|
| `T1` | `participant`, `registration` (I); `nation`, `club`, `competition_category`, `event` (R) | I, R | High vol. (1.2k) | FK-Validierung bei jedem Insert. |
| `T2` | `registration` (U); `participant`, `competition_category` (R) | U, R | Medium | Partieller Index auf unverifizierte Rows. |
| `T3` | `start_group`, `start_group_member` (I); `round`, `shooting_range`, `target_station`, `round_range` (R) | I, R | Medium | FK-Indizes Round/Range. |
| `T4` | `score_card`, `shot_result` (I); `round`, `scoring_rule`, `target_station` (R) | I, R | **Critical** | Höchstes Insert-Volumen; PK-Cluster-Ordnung. |
| `T5` | `mv_tournament_ranking` (R); `registration`, `competition_category`, `participant`, `nation` (R) | R | **High** | Matview-Index nach (event, category, rank). |
| `T6` | `tie_break`, `tie_break_participant` (I); `shot_result`, `tournament_result` (R/U) | I, R, U | Low | `idx_shot_result_tie_break`. |
| `T7` | `protest` (I/U); `official`, `registration` (R) | I, U, R | Low | `idx_protest_*`, partieller Index offene Proteste. |
| `T8` | `mv_tournament_ranking`, `score_card` (R); `registration`, `participant`, `nation`, `round`, `event` (R) | R | Medium | Report-Projektion über Matview + v_participant. |

: Transaction-to-relation matrix (physical design) {#tbl-transaction-relation-physical}

### Step 4.2 – Choose File Organizations {#sec-t3p-step42}

PostgreSQL bietet keine wählbare Primär-Datei-Organisation (keine index-organized
tables wie Oracle IOT); alle Tabellen sind **heap-organisiert** mit
btree-Sekundärindizes. Die Entwurfsentscheidung liegt daher bei den Indizes
(Step 4.3). Zwei bewusste Konsequenzen:

- **`shot_result` (Volumen-Tabelle).** Der zusammengesetzte Primärschlüssel
  `(score_card_id, target_number, arrow_number)` liefert bereits die dominante
  Lesereihenfolge (alle Schüsse einer Karte, sortiert) — ein zusätzlicher Index für
  T4-Rückleseoperationen ist nicht nötig. Die Insert-Reihenfolge folgt dem
  Karten-Kontext, wodurch Einfügungen weitgehend append-artig bleiben (geringe
  Index-Fragmentierung).
- **`mv_tournament_ranking` (Aggregat).** Statt die teure Aggregation bei jedem
  Lesezugriff (T5/T8) zu wiederholen, wird sie als *materialisierte* Relation
  gehalten (eine Form der abgeleiteten Datei-Organisation) und indexiert.

### Step 4.3 – Choose Indexes {#sec-t3p-step43}

**Grundsatz.** PostgreSQL legt für jeden `PRIMARY KEY` und jede `UNIQUE`-Bedingung
automatisch einen btree-Index an, **nicht** aber für Fremdschlüsselspalten. Das
Indexkonzept ergänzt daher (a) FK-Join-/Cascade-Spalten und (b)
transaktionsspezifische Komposit-/Partial-Indizes. Jeder Index ist an eine
Transaktion rückgebunden.

| Index name | Table | Column(s) | Type | Supporting transaction(s) | Expected benefit | Trade-off |
|---|---|---|---|---|---|---|
| `idx_round_event` | `round` | `event_id` | btree | T3, T8 | Join Event→Round | +Write/Storage |
| `idx_participant_nation` | `participant` | `nation_code` | btree | T5, T8 | GROUP BY Nation, Join | gering |
| `idx_participant_club` | `participant` | `club_id` | btree | Cascade SET NULL | schnelle Cascade | gering |
| `idx_registration_participant` | `registration` | `participant_id` | btree | T1, T5 | Join Reg→Participant | gering |
| `idx_registration_event` | `registration` | `event_id` | btree | T1, T8 | Filter je Event | gering |
| `idx_registration_category` | `registration` | `category_id` | btree | T5, T8 | Ranking je Kategorie | gering |
| `idx_registration_event_category` | `registration` | `(event_id, category_id)` | btree (composite) | T5, T8 | Kategorie-Scan für Rangbildung | +Write |
| `idx_registration_unverified` | `registration` | `event_id` WHERE `NOT classification_verified` | **partial** | T2 | winziger Hot-Set (Startzulassung) | nur Nutzen bei Filter |
| `idx_start_group_round` | `start_group` | `round_id` | btree | T3 | Gruppen je Runde | gering |
| `idx_start_group_range` | `start_group` | `range_id` | btree | T3 | Gruppen je Range | gering |
| `idx_sgm_registration` | `start_group_member` | `registration_id` | btree | T3 | Reverse-Lookup Schütze→Gruppe | gering |
| `idx_score_card_round` | `score_card` | `round_id` | btree | T4, T5, T8 | Karten je Runde | +Write |
| `idx_score_card_range` | `score_card` | `range_id` | btree | T4 | Ziel-Validierung | +Write |
| `idx_score_card_reg_round_incl` | `score_card` | `(registration_id, round_id) INCLUDE (range_id)` | covering | T5, T8 | Index-Only-Scan je Anmeldung | +Storage |
| `idx_shot_result_tie_break` | `shot_result` | `tie_break_id` | btree | T6 | Stechen-Schüsse | +Write (270k Rows) |
| `idx_protest_official` | `protest` | `official_id` | btree | T7 | Proteste je Offiziellem | gering |
| `idx_protest_registration` | `protest` | `registration_id` | btree | T7 | Proteste je Anmeldung | gering |
| `idx_protest_open` | `protest` | `registration_id` WHERE `decision='pending'` | **partial** | T7 | offene Proteste (klein) | gering |
| `idx_tbp_registration` | `tie_break_participant` | `registration_id` | btree | T6 | Reverse-Lookup | gering |
| `idx_target_distance_category` | `target_distance` | `category_id` | btree | T3-Setup | Konfig-Lookup | gering |
| `idx_mv_ranking_registration` | `mv_tournament_ranking` | `registration_id` | **unique** | T5, T8 (+CONCURRENTLY) | Voraussetzung für concurrent refresh | – |
| `idx_mv_ranking_category` | `mv_tournament_ranking` | `(event_id, category_id, rank_position)` | btree | T5, T8 | sortierte Rangliste je Kategorie | +Storage |

: Index catalog {#tbl-index-catalog}

**Bewusst weggelassene Indizes (no silent caps).** Für `shot_result` wird **kein**
Index auf `hit_zone` oder `(target_number)` angelegt — diese Spalten werden nie
selektiv gefiltert, und ein zusätzlicher Index auf der 270.000-Zeilen-Tabelle würde
T4 (den kritischen Insert-Pfad) verteuern, ohne Lese-Nutzen. `idx_shot_result_tie_break`
ist der einzige Sekundärindex auf dieser Tabelle und nur wegen T6 gerechtfertigt;
seine Schreibkosten sind der dokumentierte Trade-off.

**Read-/Write-Abwägung (Zusammenfassung).** Die schreibkritische T4 erhält bewusst
nur minimale Sekundärindizes; die leseintensiven T5/T8 werden über die
materialisierte Rangliste plus einen sortierten Kategorie-Index bedient, sodass die
teure Aggregation aus dem Lesepfad verschwindet. Partielle Indizes (T2, T7) halten
den Hot-Set klein und die Schreiblast niedrig.
