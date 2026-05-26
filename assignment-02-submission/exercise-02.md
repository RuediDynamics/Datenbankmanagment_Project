# Assignment 02 – Exercise 2: Build the Conceptual Data Model

**Domain:** IFAA World Bowhunter Championships (WBHC) 2027, Bad Waldsee
**Notation:** UML Data Model Profile (Ambler / Connolly & Begg)
**Tool:** PlantUML
**Method:** Connolly & Begg (2015), Chapter 16 – Conceptual Database Design (Steps 1.1–1.9)

This exercise transforms the consolidated requirements and the eight core transactions from Exercise 1 into a validated conceptual data model. The work follows Step 1 of Connolly & Begg's methodology systematically and documents two iterations: an **initial model** (after Steps 1.1–1.5) and a **final model** (after redundancy removal, enhanced modeling, and transaction validation in Steps 1.6–1.8).

---

## Step 1.1 – Identify Entity Types

Entity types were extracted by scanning every requirement table in Exercise 1 for nouns and noun phrases that denote major objects of interest. The candidates were then filtered (synonyms merged, single-instance "objects" rejected) against the in-scope list of Section 4.

| # | Entity | Description | Origin in Exercise 1 |
|---|---|---|---|
| 1 | **Event** | The WBHC 2027 itself; top-level container for rounds, registrations, and results. | Turnierdirektor – "Veranstaltung" |
| 2 | **Round** | One of the four tournament rounds (2× Unmarked Animal, 1× 3D Standard, 1× 3D Hunting). | Turnierdirektor / Scope (4 rounds) |
| 3 | **Range** | A physical 28-target course used for one or more rounds. | Turnierdirektor – "Range / Strecke" |
| 4 | **TargetStation** | One of the 28 targets on a range (target number 1–28, group 1–4). | Turnierdirektor / Schütze |
| 5 | **Participant** | An individual archer competing in the event. | All three roles |
| 6 | **Nation** | The country a participant represents (e.g., AUT, GER, USA). | Schütze – "Nation" |
| 7 | **Club** | A sport club a participant is affiliated with (optional). | Schütze – "Verein" |
| 8 | **Official** | A judge, target captain (TCO), range official, or the tournament director. | Turnierdirektor – "Offizieller" |
| 9 | **Registration** | A participant's entry to the event in a specific style/division/class combination. | Ergebnisbeauftragte – "Anmeldung" |
| 10 | **CompetitionCategory** | The combination of shooting style, division, and class (A/B/C) that defines a ranking category. | Derived (final iteration only – see Step 1.7) |
| 11 | **StartGroup** | A group of 3–6 archers shooting together on a given range/day. | Schütze / Turnierdirektor – "Startgruppe" |
| 12 | **ScoreCard** | A single archer's card for one round (covers all 28 targets). | Ergebnisbeauftragte – "Scorekarte" |
| 13 | **ShotResult** | One single arrow shot at a target (arrow no., hit zone, points). | Ergebnisbeauftragte / Schütze |
| 14 | **TournamentResult** | A participant's aggregated total and ranking position. | All three roles – "Gesamtrangliste" |
| 15 | **TieBreak** | A shoot-off between tied participants. | Ergebnisbeauftragte – "Tie-Break" |
| 16 | **Protest** | A formal complaint / rule decision recorded against a participant or situation. | Turnierdirektor – "Protest" |

**Excluded** (rejected during this step): *Equipment*, *Hotel booking*, *Payment* (all out-of-scope per Exercise 1); *Klassifizierungskarte* (modelled as a flag on `Registration`, not as a separate entity, per the practicality conflict in Section 3.2).

---

## Step 1.2 – Identify Relationship Types

Relationships were extracted by reading the verbs/verbal phrases in the stakeholder data needs (e.g., "Schütze *nimmt teil an* Veranstaltung", "Offizieller *entscheidet über* Protest"). Multiplicities and participation constraints (mandatory/optional) were derived from the WBHC business rules and from the IFAA rule set.

| # | Relationship | Entity 1 | Entity 2 | Multiplicity | Mandatory? |
|---|---|---|---|---|---|
| R1 | consistsOf | Event | Round | 1 : 1..4 | Yes / Yes (composition) |
| R2 | uses | Round | Range | 1..* : 1..* | Yes / Yes |
| R3 | contains | Range | TargetStation | 1 : 28 | Yes / Yes (composition) |
| R4 | submits | Participant | Registration | 1 : 0..* | No / Yes |
| R5 | forEvent | Registration | Event | * : 1 | Yes / Yes |
| R6 | categorisedAs | Registration | CompetitionCategory | * : 1 | Yes / Yes |
| R7 | representsNation | Participant | Nation | * : 1 | Yes / Yes |
| R8 | memberOf | Participant | Club | 0..* : 0..1 | No / No |
| R9 | forRound | StartGroup | Round | * : 1 | Yes / Yes |
| R10 | assignedToRange | StartGroup | Range | * : 1 | Yes / Yes |
| R11 | includes | StartGroup | Registration | 1 : 3..6 | Yes / Yes |
| R12 | recordsFor | ScoreCard | Registration | * : 1 | Yes / Yes |
| R13 | forRound (sc) | ScoreCard | Round | * : 1 | Yes / Yes |
| R14 | contains (sc) | ScoreCard | ShotResult | 1 : 28..84 | Yes / Yes (composition) |
| R15 | atTarget | ShotResult | TargetStation | * : 1 | Yes / Yes |
| R16 | signedBy | ScoreCard | Official | * : 1 | Yes / Yes |
| R17 | summarises | TournamentResult | Registration | 1 : 1 | Yes / Yes |
| R18 | resolvesTie | TieBreak | Registration | * : 2..* | No / No |
| R19 | uses (tb) | TieBreak | ShotResult | 1 : 1..* | Yes / Yes |
| R20 | assignedToRange (off) | Official | Range | 1 : 0..* | No / No |
| R21 | decides | Official | Protest | 1 : 0..* | No / Yes |
| R22 | concerns | Protest | Registration | * : 1 | Yes / Yes |

**Note on R14 cardinality:** the shot count per scorecard depends on round type — 28 targets × {1, 2, or 3} arrows = {28, 56, 84} shots. The `28..84` range covers all three round types.

---

## Step 1.3 – Identify and Associate Attributes

Attributes were classified per Connolly & Begg as simple/composite, single/multi-valued, or derived. The full attribute list is delivered in Exercise 3 (data dictionary); the following table summarises the non-trivial classifications.

| Attribute | Entity | Classification | Note |
|---|---|---|---|
| `age` | Participant | **derived** | Calculated from `birthDate` and the event start year. |
| `pointValue` | ShotResult | **derived** | Calculated from `roundType` + `hitZone` + `arrowNumber` per IFAA scoring table. |
| `roundTotal` | ScoreCard | **derived** | Sum of `pointValue` over the 28..84 contained shots. |
| `totalPoints` | TournamentResult | **derived** | Sum of `roundTotal` over all rounds of the event. |
| `rankPosition` | TournamentResult | **derived** | Rank within the same `CompetitionCategory`, ordered by `totalPoints` desc with tie-break flag. |
| `numberOfTargets` | Range | **derived** | Count of associated `TargetStation` instances (= 28 by business rule). |
| `firstName + lastName` | Person | composite | Conceptually a single composite "name", decomposed into atomic parts. |
| (no multi-valued attributes were identified) | – | – | Multi-valued candidates such as "Nation per participant over time" were rejected: at the WBHC, a participant represents exactly one nation. |

---

## Step 1.4 – Determine Attribute Domains

Attribute domains define legal values, formats, and sizes. Detailed domain definitions are given in Exercise 3; the most important domain constraints are:

- `roundType ∈ {UnmarkedAnimal_3Arrow, Standard3D_2Arrow, Hunting3D_1Arrow}`
- `hitZone ∈ {Kill, Vital, Wound, Miss}` — drives the points lookup together with `arrowNumber`.
- `targetNumber ∈ Integer[1..28]`, `arrowNumber ∈ Integer[1..3]`, `targetGroup ∈ Integer[1..4]`.
- `style ∈ {BB, BBR, BHR, BL, BU, FS, FSR, FU, LB, TR}` (10 official IFAA styles).
- `division ∈ {Adult, Veteran, Senior, YoungAdult, Junior, Cub}` (IFAA age divisions).
- `class ∈ {A, B, C}` (IFAA classification).
- `nationCode` = ISO 3-letter code (e.g., AUT, GER).
- All dates ISO 8601 (`YYYY-MM-DD`); `pointValue ∈ Integer[0..20]`.

---

## Step 1.5 – Determine Keys

Candidate, primary, and alternate keys were chosen as follows. Two weak entities were identified.

| Entity | Candidate keys | Selected PK | Alternate keys | Type |
|---|---|---|---|---|
| Event | `eventId`; (`name`, `startDate`) | `eventId` | (`name`, `startDate`) | strong |
| Round | `roundId`; (`eventId`, `roundNumber`) | `roundId` | (`eventId`, `roundNumber`) | strong |
| Range | `rangeId`; `rangeName` | `rangeId` | `rangeName` | strong |
| **TargetStation** | (parent `rangeId`, `targetNumber`) | (`rangeId`, `targetNumber`) | – | **weak** (existence-dependent on Range) |
| Participant | `participantId` (= `personId`); (`firstName`, `lastName`, `birthDate`, `nationCode`) | `participantId` | natural composite key | strong (subtype of Person) |
| Nation | `nationCode`; `nationName` | `nationCode` | `nationName` | strong |
| Club | `clubId`; `clubName` | `clubId` | `clubName` | strong |
| Official | `officialId` (= `personId`) | `officialId` | – | strong (subtype of Person) |
| Registration | `registrationId`; (`eventId`, `participantId`) | `registrationId` | (`eventId`, `participantId`) | strong |
| CompetitionCategory | `categoryId`; (`style`, `division`, `class`) | `categoryId` | (`style`, `division`, `class`) | strong |
| StartGroup | `groupId`; (`roundId`, `groupNumber`) | `groupId` | (`roundId`, `groupNumber`) | strong |
| ScoreCard | `scoreCardId`; (`registrationId`, `roundId`) | `scoreCardId` | (`registrationId`, `roundId`) | strong |
| **ShotResult** | (parent `scoreCardId`, `targetNumber`, `arrowNumber`) | composite | – | **weak** (existence-dependent on ScoreCard) |
| TournamentResult | `resultId`; `registrationId` | `resultId` | `registrationId` | strong |
| TieBreak | `tieBreakId` | `tieBreakId` | – | strong |
| Protest | `protestId` | `protestId` | – | strong |

---

## Step 1.6 – Enhanced Modeling (Generalization/Specialization)

Two enhancement opportunities were assessed; one was adopted, one was rejected.

**Adopted: `Person` generalization for `Participant` and `Official`.**
Both subtypes share `firstName` and `lastName`. Lifting these to an abstract `Person` supertype prevents attribute duplication and makes future requirements (e.g., a person who is both archer and judge) cleanly expressible. The hierarchy is *disjoint* but *non-mandatory* (a Person could in principle appear without being either, although for WBHC this is not expected).

**Rejected: separate subtypes per `roundType`.**
The three round types differ only in `arrows-per-target` and the score lookup. Modelling them as subtypes of `Round` would introduce structural complexity for what is effectively a data-driven scoring rule. They are kept as an enumerated `roundType` attribute, with the scoring logic captured in the derivation rule for `pointValue`.

---

## Step 1.7 – Check for Redundancy

The initial model was reviewed for redundancy along the three lines suggested by Connolly & Begg.

**Finding 1 – Redundant attribute group on `Registration`.**
In the initial model, the attributes `shootingStyle`, `division`, and `classification` were placed directly on `Registration`. Because the **same combination** of (style, division, class) recurs across many registrations and *also* drives ranking, target distances, and tie-break grouping (T3, T5, T6, T8), the combination is a domain concept in its own right. It was promoted to an entity **`CompetitionCategory`** linked to `Registration` via `categorisedAs`. This removes the implicit "many registrations share the same category" redundancy and gives ranking transactions a clean grouping dimension.

**Finding 2 – Missing association class for target distance.**
In the initial model, `maxDistance` was an attribute of `TargetStation`. However, the maximum shooting distance per target depends on the `CompetitionCategory` (IFAA rule: longbow stakes are closer than freestyle stakes). One `(target, category)` pair has one distance, so `maxDistance` was relocated to an **association class `TargetDistance`** between `TargetStation` and `CompetitionCategory`. This eliminates the would-be multi-valued attribute on `TargetStation`.

**Finding 3 – No redundant relationships found.**
No "transitive" relationships exist that could be derived from a chain of others (e.g., there is no direct `Participant—Round` link; it is correctly derived via `Registration` → `StartGroup` → `Round`).

**Finding 4 – Time dimension considered, none added.**
A `Participant`'s `Nation` and `Club` could in principle change over time; for the bounded scope of a single championship, a current-value model is sufficient and historical tracking is *out of scope*.

---

## Step 1.8 – Validate Against Transactions

A first manual trace of the eight transactions from Exercise 1 was performed against the initial model. The detailed transaction-to-model matrix is delivered in Exercise 4; here we summarise the gaps discovered and how they triggered the revisions above.

| Transaction | Result on initial model | Action taken |
|---|---|---|
| T1 – Create participant + registration | ✅ supported | – |
| T2 – Verify classification | ✅ supported (flag on Registration) | – |
| T3 – Build start groups | ⚠️ unclear: how is "category" used to seed groups? | Promoted to `CompetitionCategory` (Finding 1). |
| T4 – Capture scorecard | ✅ supported | – |
| T5 – Display ranking per category | ⚠️ ranking grouped by 3 separate attributes — redundant | Promoted to `CompetitionCategory` (Finding 1). |
| T6 – Record tie-break | ✅ supported | – |
| T7 – Document protest | ⚠️ initially linked to `Participant`, but protests at WBHC are scoped to a specific entry | Linked to `Registration` instead. |
| T8 – Export official results | ⚠️ target distances inconsistent across categories | `TargetDistance` association class added (Finding 2). |

After these revisions the **final model supports all eight transactions** (full matrix in Exercise 4).

---

## Step 1.9 – Review with Users

The revised diagram and the data dictionary (Exercise 3) will be presented to the three Exercise 1 personas (Klaus Brenner – Turnierdirektor, Maria Weiss – Bogenschützin, Sandra Klein – Ergebnisbeauftragte) before logical design. Open clarification questions for that review are listed in Exercise 5.

---

## Conceptual Model Diagrams

### Initial Conceptual Model

Source: [`assets/diagrams/conceptual-model-initial.puml`](assets/diagrams/conceptual-model-initial.puml)

![Initial Conceptual Model](assets/diagrams/conceptual-model-initial.svg)

### Final Conceptual Model (after redundancy check and transaction validation)

Source: [`assets/diagrams/conceptual-model-final.puml`](assets/diagrams/conceptual-model-final.puml)

![Final Conceptual Model](assets/diagrams/conceptual-model-final.svg)

---

## Summary of Changes Between Initial and Final Model

| # | Change | Rationale | Step |
|---|---|---|---|
| 1 | Introduced `CompetitionCategory` entity | Removed redundancy of (style, division, class) on Registration; supports T3, T5, T8 cleanly. | 1.7 |
| 2 | Introduced `TargetDistance` association class | Distance depends on (target, category) — eliminates multi-valued attribute. | 1.7 |
| 3 | Generalized `Person` as supertype of `Participant` and `Official` | Avoids attribute duplication; future-proof. | 1.6 |
| 4 | `Protest` now linked to `Registration` instead of `Participant` | A protest concerns a specific entry, not the person in general. | 1.8 |
| 5 | `signedBy` relationship from `ScoreCard` to `Official` added | Captures the Target Captain signature requirement from Exercise 1. | 1.8 |
| 6 | Multiplicity on `ScoreCard contains ShotResult` set to 28..84 | Reflects round-type-dependent arrow count (1, 2, or 3 arrows × 28 targets). | 1.2 |
| 7 | Weak entities `TargetStation` and `ShotResult` made explicit | Their existence depends on the parent; PKs are partial. | 1.5 |
