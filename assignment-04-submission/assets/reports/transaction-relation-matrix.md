# Transaction-to-Relation Cross-Reference Matrix (Physical Design)

**Assignment 04 – Exercise 3, Step 4.1**
Detailmatrix je Transaktion → physische Tabellen, Zugriffsart und genutzte Indizes.
Zugriffsart: R = Read, I = Insert, U = Update, D = Delete. `x` = berührt.

## Volle Berührungsmatrix (Transaktion × Tabelle)

| Table | T1 | T2 | T3 | T4 | T5 | T6 | T7 | T8 |
|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| `event` | R | – | – | – | – | – | – | R |
| `round` | – | – | R | R | – | – | – | R |
| `shooting_range` | – | – | R | R | – | – | – | – |
| `target_station` | – | – | R | R | – | R | – | – |
| `nation` | R | – | – | – | R | – | – | R |
| `club` | R | – | – | – | – | – | – | – |
| `participant` | I | R | – | – | R | – | – | R |
| `official` | – | – | – | R | – | – | R | – |
| `competition_category` | R | R | – | – | R | – | – | R |
| `registration` | I | U | R | R | R | R | R | R |
| `start_group` | – | – | I | – | – | – | – | – |
| `start_group_member` | – | – | I | – | – | – | – | – |
| `score_card` | – | – | – | I | R | R | – | R |
| `shot_result` | – | – | – | I | – | R | – | – |
| `tournament_result` | – | – | – | – | R | U | – | R |
| `tie_break` | – | – | – | – | – | I | – | – |
| `tie_break_participant` | – | – | – | – | – | I | – | – |
| `protest` | – | – | – | – | – | – | I/U | – |
| `round_range` | – | – | R | – | – | – | – | – |
| `target_distance` | – | – | R | – | – | – | – | – |
| `scoring_rule` | – | – | – | R | R* | R | – | R* |
| `mv_tournament_ranking` | – | – | – | – | R | – | – | R |

\* via gespeicherte/materialisierte Ableitung (nach Iteration A liest T5/T8 primär `mv_tournament_ranking`).

## Zugriffspfade und unterstützende Indizes je Transaktion

| Transaction | Dominant access | Kritischer Join-/Filter-Pfad | Unterstützende Indizes |
|---|---|---|---|
| T1 Teilnehmer anlegen | I (participant, registration) | FK-Validierung nation/club/category/event | `pk_*`, `uq_registration_participant_event` |
| T2 Klassifizierung prüfen | U (registration) | Filter `classification_verified = FALSE` je Event | `idx_registration_unverified` (partial) |
| T3 Startgruppen | I (start_group, member) | round⋈range⋈group, round_range | `idx_start_group_round/range`, `idx_sgm_registration` |
| T4 Scorekarte erfassen | I (score_card, shot_result) | PK-geordnete Inserts; scoring_rule-Lookup; atTarget-Trigger | `pk_shot_result`, `idx_score_card_range`, `pk_target_station` |
| T5 Rangliste | R (aggregiert) | mv_tournament_ranking je (event, category) | `idx_mv_ranking_category` |
| T6 Tie-Break | I/R/U | Filter `tie_break_id`; tie_break_participant | `idx_shot_result_tie_break`, `idx_tbp_registration` |
| T7 Protest | I/U | offene Proteste je Registration/Official | `idx_protest_open` (partial), `idx_protest_official` |
| T8 Export | R (Report) | mv_tournament_ranking ⋈ v_participant ⋈ round/event | `idx_mv_ranking_category`, `idx_score_card_reg_round_incl` |

## Traceability

- Transaktionsdefinitionen: Assignment 02 §Transaktionen (T1–T8).
- Logische Validierung / Join-Pfade: Assignment 03 Task 3 (initial & revised matrix).
- Index-Begründung: [`index-catalog.md`](index-catalog.md) und
  Hauptdokument @tbl-index-catalog.
