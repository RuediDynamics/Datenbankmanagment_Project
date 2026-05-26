# Assignment 02 – Exercise 2: Build the Conceptual Data Model

**Domain:** IFAA World Bowhunter Championships (WBHC) 2027, Bad Waldsee
**Notation:** UML Data Model Profile · **Tool:** PlantUML
**Method:** Connolly & Begg (2015), Chapter 16, Step 1.1–1.9

---

## Step 1.1 – Entity Types

| # | Entity | Description |
|---|---|---|
| 1 | Event | The WBHC 2027 itself. |
| 2 | Round | One of the four tournament rounds. |
| 3 | Range | A physical 28-target course. |
| 4 | TargetStation | One of the 28 targets on a range. |
| 5 | Participant | An individual archer. |
| 6 | Nation | The country a participant represents. |
| 7 | Club | A sport club a participant belongs to. |
| 8 | Official | A judge, target captain or director. |
| 9 | Registration | A participant's entry to the event. |
| 10 | CompetitionCategory | Style + Division + Class combination. |
| 11 | StartGroup | A group of 3–6 archers shooting together. |
| 12 | ScoreCard | A participant's card for one round. |
| 13 | ShotResult | A single arrow shot. |
| 14 | TournamentResult | A participant's aggregated total. |
| 15 | TieBreak | A shoot-off between tied participants. |
| 16 | Protest | A formal rule decision. |

---

## Step 1.2 – Relationship Types

| # | Relationship | Entity 1 | Entity 2 | Multiplicity |
|---|---|---|---|---|
| R1 | consistsOf | Event | Round | 1 : 1..4 |
| R2 | uses | Round | Range | 1..* : 1..* |
| R3 | contains | Range | TargetStation | 1 : 28 |
| R4 | submits | Participant | Registration | 1 : 0..* |
| R5 | forEvent | Registration | Event | * : 1 |
| R6 | categorisedAs | Registration | CompetitionCategory | * : 1 |
| R7 | representsNation | Participant | Nation | * : 1 |
| R8 | memberOf | Participant | Club | 0..* : 0..1 |
| R9 | forRound | StartGroup | Round | * : 1 |
| R10 | assignedToRange | StartGroup | Range | * : 1 |
| R11 | includes | StartGroup | Registration | 1 : 3..6 |
| R12 | recordsFor | ScoreCard | Registration | * : 1 |
| R13 | forRound | ScoreCard | Round | * : 1 |
| R14 | contains | ScoreCard | ShotResult | 1 : 28..84 |
| R15 | atTarget | ShotResult | TargetStation | * : 1 |
| R16 | signedBy | ScoreCard | Official | * : 1 |
| R17 | summarises | TournamentResult | Registration | 1 : 1 |
| R18 | resolvesTie | TieBreak | Registration | * : 2..* |
| R19 | uses | TieBreak | ShotResult | 1 : 1..* |
| R20 | assignedToRange | Official | Range | 1 : 0..* |
| R21 | decides | Official | Protest | 1 : 0..* |
| R22 | concerns | Protest | Registration | * : 1 |

---

## Step 1.3 – Attribute Classification

| Attribute | Entity | Type |
|---|---|---|
| age | Participant | derived (from birthDate) |
| pointValue | ShotResult | derived (roundType + hitZone + arrowNumber) |
| roundTotal | ScoreCard | derived (sum of pointValue) |
| totalPoints | TournamentResult | derived (sum of roundTotal) |
| rankPosition | TournamentResult | derived (rank in CompetitionCategory) |
| numberOfTargets | Range | derived (count of TargetStation) |
| firstName + lastName | Person | composite (atomic name parts) |

All other attributes are simple, single-valued and non-derived. No multi-valued attributes were identified.

---

## Step 1.4 – Attribute Domains

| Attribute | Domain |
|---|---|
| roundType | {UnmarkedAnimal_3Arrow, Standard3D_2Arrow, Hunting3D_1Arrow} |
| hitZone | {Kill, Vital, Wound, Miss} |
| targetNumber | Integer [1..28] |
| arrowNumber | Integer [1..3] |
| targetGroup | Integer [1..4] |
| style | {BB, BBR, BHR, BL, BU, FS, FSR, FU, LB, TR} |
| division | {Adult, Veteran, Senior, YoungAdult, Junior, Cub} |
| classLevel | {A, B, C} |
| nationCode | Text[3] (ISO 3-letter) |
| pointValue | Integer [0..20] |
| All dates | ISO 8601 (YYYY-MM-DD) |
| All Booleans | {true, false} |

---

## Step 1.5 – Keys

| Entity | Primary Key | Alternate Key | Type |
|---|---|---|---|
| Event | eventId | (name, startDate) | strong |
| Round | roundId | (eventId, roundNumber) | strong |
| Range | rangeId | rangeName | strong |
| TargetStation | (rangeId, targetNumber) | – | **weak** |
| Participant | participantId | – | strong |
| Nation | nationCode | nationName | strong |
| Club | clubId | clubName | strong |
| Official | officialId | – | strong |
| Registration | registrationId | (eventId, participantId) | strong |
| CompetitionCategory | categoryId | (style, division, classLevel) | strong |
| StartGroup | groupId | (roundId, groupNumber) | strong |
| ScoreCard | scoreCardId | (registrationId, roundId) | strong |
| ShotResult | (scoreCardId, targetNumber, arrowNumber) | – | **weak** |
| TournamentResult | resultId | registrationId | strong |
| TieBreak | tieBreakId | – | strong |
| Protest | protestId | – | strong |

---

## Step 1.6 – Enhanced Modeling

**Adopted:** Generalization `Person` over `Participant` and `Official` (shared attributes `firstName`, `lastName`).

**Rejected:** Subtypes per `roundType` — kept as enumerated attribute since the variation is data-driven (arrows per target), not structural.

---

## Step 1.7 – Redundancy Check

| # | Finding | Action |
|---|---|---|
| 1 | (style, division, class) duplicated across Registrations | Promoted to entity `CompetitionCategory` |
| 2 | `maxDistance` depended on category (would be multi-valued) | Moved to association class `TargetDistance` |
| 3 | No redundant relationships found | – |
| 4 | Time dimension on Nation/Club not required for single event | – |

---

## Step 1.8 – Validation Against Transactions

Initial trace of T1–T8 (from Exercise 1) revealed three gaps that triggered the revisions above. Full transaction-to-model matrix follows in Exercise 4.

| Transaction | Initial Model | Action |
|---|---|---|
| T1 – Create participant | ✓ | – |
| T2 – Verify classification | ✓ | – |
| T3 – Build start groups | gap | `CompetitionCategory` added |
| T4 – Capture scorecard | ✓ | – |
| T5 – Display ranking | gap | `CompetitionCategory` added |
| T6 – Record tie-break | ✓ | – |
| T7 – Document protest | gap | linked to Registration (not Participant) |
| T8 – Export results | gap | `TargetDistance` added |

After revision: **all 8 transactions supported by the final model.**

---

## Step 1.9 – User Review

Final model will be presented to the three Exercise 1 personas (Klaus Brenner, Maria Weiss, Sandra Klein). Open clarifications are listed in Exercise 5.

---

## Initial Conceptual Model

Source: [`assets/diagrams/conceptual-model-initial.puml`](assets/diagrams/conceptual-model-initial.puml)

![Initial Conceptual Model](assets/diagrams/conceptual-model-initial.svg)

---

## Final Conceptual Model

Source: [`assets/diagrams/conceptual-model-final.puml`](assets/diagrams/conceptual-model-final.puml)

![Final Conceptual Model](assets/diagrams/conceptual-model-final.svg)

---

## Changes Between Initial and Final Model

| # | Change | Reason | Step |
|---|---|---|---|
| 1 | Added `CompetitionCategory` | Removed redundancy of (style, division, class) | 1.7 |
| 2 | Added `TargetDistance` association class | Distance depends on (target, category) | 1.7 |
| 3 | Added `Person` supertype | Avoids duplicated name attributes | 1.6 |
| 4 | `Protest` now linked to Registration | A protest concerns a specific entry | 1.8 |
| 5 | Added `signedBy` relationship | Captures Target Captain signature | 1.8 |
| 6 | Set `28..84` on ScoreCard → ShotResult | Reflects round-type arrow count | 1.2 |
| 7 | Marked weak entities explicitly | Existence-dependent on parent | 1.5 |
