## Task 1: Derive Relations from the Conceptual Model {#sec-task1-derive-relations}

**Step 2.1 – Derive Relations for the Logical Data Model** (Connolly & Begg, Kap. 17)

Diese Sektion überführt das **finale konzeptuelle Datenmodell aus Assignment 02**
(16 Entitätstypen + Supertyp `Person`, 22 Beziehungstypen, Assoziationsklasse
`TargetDistance`) systematisch in ein logisches relationales Datenmodell. Jede
Mapping-Entscheidung ist auf ein konkretes Artefakt aus Assignment 02 rückführbar
(Entity Dictionary, Relationship Dictionary, Attribute Dictionary, Key
Documentation sowie die Transaktions-Validierung in Task 4).

### Notation und Konventionen {#sec-t1-notation}

Das logische Modell verwendet das **UML Data Model Profile** (Klassen =
Relationen). Im Diagramm und in den Schemata gelten folgende Marker:

| Marker | Bedeutung |
|---|---|
| `<<PK>>` / **fett** | Primärschlüssel (Primary Key) |
| `<<FK>>` / *kursiv* `→ Parent` | Fremdschlüssel mit referenzierter Eltern-Relation |
| `<<PFK>>` | Attribut ist gleichzeitig Primär- **und** Fremdschlüssel (schwache Entität, Brücken-/Assoziationsrelation) |
| `<<AK>>` | Alternativschlüssel (Candidate Key, nicht gewählter Identifier) |
| `/attr` | abgeleitetes Attribut – im logischen Modell **nicht gespeichert**, sondern bei Bedarf berechnet (siehe Normalisierungsanmerkungen, Assignment 02) |

: Notations-Legende des logischen Datenmodells {#tbl-t1-notation}

### Resultierendes Relationenschema {#sec-t1-schema}

Das vollständige abgeleitete Schema umfasst **20 Relationen**: 14 Basisrelationen
(starke und schwache Entitäten), 3 Brückenrelationen aus aufgelösten
*:*-Beziehungen, 1 Assoziationsrelation sowie die in die Subtypen aufgelöste
Generalisierung `Person`. Primärschlüssel sind **fett**, Fremdschlüssel *kursiv*
mit Verweis auf die Eltern-Relation.

```text
Event(eventId, name, startDate, endDate, location, organizer, ifaaReference)
Round(roundId, eventId→Event, roundNumber, roundType, roundDate)
Range(rangeId, officialId→Official [NULL], rangeName)
TargetStation(rangeId→Range, targetNumber, targetGroup)
Nation(nationCode, nationName)
Club(clubId, clubName)
Participant(participantId, nationCode→Nation, clubId→Club [NULL],
            firstName, lastName, birthDate)
Official(officialId, firstName, lastName, officialFunction)
CompetitionCategory(categoryId, style, division, classLevel)
Registration(registrationId, participantId→Participant, eventId→Event,
             categoryId→CompetitionCategory, entryFeeStatus, equipmentStatus,
             classificationVerified, classificationDate)
StartGroup(groupId, roundId→Round, rangeId→Range, groupNumber, startTarget)
ScoreCard(scoreCardId, registrationId→Registration, roundId→Round,
          officialId→Official [NULL])
ShotResult(scoreCardId→ScoreCard, targetNumber, arrowNumber,
           rangeId→TargetStation, tieBreakId→TieBreak [NULL], hitZone)
TournamentResult(resultId, registrationId→Registration, tieBreakStatus)
TieBreak(tieBreakId, tieBreakRound)
Protest(protestId, officialId→Official, registrationId→Registration,
        protestDate, protestDescription, protestDecision)

-- Brückenrelationen (aufgelöste *:*-Beziehungen) --
RoundRange(roundId→Round, rangeId→Range)
StartGroupMember(groupId→StartGroup, registrationId→Registration)
TieBreakParticipant(tieBreakId→TieBreak, registrationId→Registration)

-- Assoziationsrelation (Assoziationsklasse TargetDistance) --
TargetDistance(rangeId→TargetStation, targetNumber→TargetStation,
               categoryId→CompetitionCategory, maxDistance)
```

### UML-Diagramm: Initiales logisches Datenmodell {#sec-t1-diagram}

![Initiales logisches (relationales) Datenmodell – IFAA WBHC 2027. PlantUML-Quelle: `assets/diagrams/logical-model-initial.puml`](/assignment-03-submission/assets/diagrams/logical-model-initial.svg){#fig-logical-initial}

### Mapping-Strategie je Mapping-Fall {#sec-t1-cases}

Die folgende Übersicht dokumentiert die angewandten **Mapping-Regeln** je Fall.
Die fallweisen Detailentscheidungen mit Schlüsseln und FKs stehen in
@tbl-t1-mapping.

**(a) Starke Entitäten.** Jede starke Entität (z. B. `Event`, `Participant`,
`CompetitionCategory`) wird auf genau eine Relation abgebildet; alle einfachen,
einwertigen, nicht abgeleiteten Attribute werden übernommen, der gewählte
Identifier wird Primärschlüssel, weitere Candidate Keys werden als
Alternativschlüssel (`<<AK>>`) geführt (Quelle: Key Documentation, Assignment 02).

**(b) Schwache Entitäten.** `TargetStation` (existenzabhängig von `Range`) und
`ShotResult` (existenzabhängig von `ScoreCard`) erhalten einen zusammengesetzten
Primärschlüssel aus dem **Fremdschlüssel der Eltern-Relation plus partiellem
Diskriminator**: `TargetStation(rangeId, targetNumber)` und
`ShotResult(scoreCardId, targetNumber, arrowNumber)`. Beide Fälle sind in
Assignment 02 ausdrücklich als *Weak* markiert.

**(c) 1:* Beziehungen.** Der Primärschlüssel der „1"-Seite wandert als
Fremdschlüssel auf die „*"-Seite (Foreign-Key-Posting). Beispiele: `consistsOf`
(`Event` 1 : `Round` 1..4 → `eventId` in `Round`), `submits`
(`Participant` 1 : `Registration` 0..* → `participantId` in `Registration`),
`forRound`, `categorisedAs`, `representsNation`, `recordsFor`, `concerns`,
`decides`, `assignedToRange` (StartGroup–Range).

**(d) 1:1 Beziehungen.** `summarises` (`TournamentResult` 1 : `Registration` 1)
wird durch Fremdschlüssel `registrationId` in `TournamentResult` mit zusätzlicher
**UNIQUE-Eigenschaft** abgebildet. Die FK-Platzierung auf der `TournamentResult`-
Seite folgt der totalen Partizipation: jedes Ergebnis benötigt zwingend eine
Anmeldung, eine Anmeldung jedoch nicht zwingend ein Ergebnis (vgl. Step 1.2).

**(e) *:* Beziehungen.** Many-to-many-Beziehungen können nicht direkt
relational dargestellt werden und werden in **Brückenrelationen** aufgelöst,
deren Primärschlüssel aus den beiden Fremdschlüsseln besteht:

- `uses` (`Round` 1..* : `Range` 1..*) → **`RoundRange`**
- `includes` (`StartGroup` : `Registration`) → **`StartGroupMember`** *(nicht-triviale Entscheidung, siehe @sec-t1-rationale)*
- `resolvesTie` (`TieBreak` * : `Registration` 2..*) → **`TieBreakParticipant`**

**(f) Superclass/Subclass (Generalisierung).** Der abstrakte Supertyp `Person`
(nur `firstName`, `lastName`) generalisiert `Participant` und `Official`
({mandatory, disjoint}). Gewählte Strategie: **„one relation per subclass"** –
der Supertyp erhält **keine** eigene Relation, die geerbten Attribute
`firstName`/`lastName` werden in beide Subtyp-Relationen kopiert. Begründung in
@sec-t1-rationale.

**(g) Assoziationsklasse / abhängige Werte.** Die in Step 1.7 eingeführte
Assoziationsklasse `TargetDistance` (maximale Schussdistanz hängt von *Ziel* **und**
*Kategorie* ab) entspricht einer *:*-Beziehung zwischen `TargetStation` und
`CompetitionCategory` mit Eigenschaftsattribut. Sie wird auf die
Assoziationsrelation **`TargetDistance(rangeId, targetNumber, categoryId,
maxDistance)`** abgebildet.

**(h) Zusammengesetzte (composite) Attribute.** Das einzige zusammengesetzte
Attribut aus Assignment 02 ist der Personenname (`firstName` + `lastName`). Es
wird in seine **atomaren Komponenten** zerlegt und als zwei separate Spalten je
Subtyp-Relation geführt (1NF-konform).

**(i) Mehrwertige Attribute.** In Assignment 02 wurden **keine** mehrwertigen
Attribute identifiziert (Step 1.3); ein Auslagern in separate Relationen entfällt
daher. Der einzige ursprünglich mehrwertige Kandidat (`maxDistance` je Kategorie)
war bereits konzeptuell in `TargetDistance` ausgelagert worden.

**(j) Rekursive Beziehungen.** Im Domänenmodell existieren **keine** rekursiven
(unären) Beziehungen; dieser Mapping-Fall ist nicht anwendbar.

**(k) Mandatory/Optional Participation.** Optionale Partizipation wird über
**NULL-zulässige Fremdschlüssel** abgebildet: `Participant.clubId` (`memberOf`
optional), `ScoreCard.officialId` (`signedBy` optional), `Range.officialId`
(`assignedToRange` Official–Range optional). Verpflichtende Partizipation
(`representsNation`, `forEvent`, `recordsFor` …) ergibt NOT-NULL-Fremdschlüssel.
Die referenziellen Aktionen (`ON DELETE`/`ON UPDATE`) werden in Task 4
spezifiziert.

**(l) Abgeleitete Attribute.** `age`, `pointValue`, `roundTotal`, `totalPoints`,
`rankPosition`, `numberOfTargets` sind laut Assignment 02 abgeleitet und werden im
logischen Modell **nicht persistiert** (Notation `/attr`), sondern bei Bedarf
berechnet. Dies wahrt Redundanzfreiheit (vgl. Normalisierungsanmerkungen 2NF/3NF).

### Mapping-Dokumentation je Quellobjekt {#sec-t1-mapping-table}

| Quell-Element (A02) | Typ | Gewählte Relation(en) | Candidate Key(s) | Foreign Keys → Parent | Mapping-Fall |
|---|---|---|---|---|---|
| `Event` | starke E. | `Event` | `eventId`; `(name, startDate)` | – | (a) |
| `Round` | starke E. | `Round` | `roundId`; `(eventId, roundNumber)` | `eventId → Event` | (a),(c) |
| `Range` | starke E. | `Range` | `rangeId`; `rangeName` | `officialId → Official` [NULL] | (a),(c),(k) |
| `TargetStation` | schwache E. | `TargetStation` | `(rangeId, targetNumber)` | `rangeId → Range` | (b) |
| `Participant` | starke E. / Subtyp | `Participant` | `participantId` | `nationCode → Nation`; `clubId → Club` [NULL] | (a),(c),(f),(k) |
| `Nation` | starke E. | `Nation` | `nationCode`; `nationName` | – | (a) |
| `Club` | starke E. | `Club` | `clubId`; `clubName` | – | (a) |
| `Official` | starke E. / Subtyp | `Official` | `officialId` | – | (a),(f) |
| `CompetitionCategory` | starke E. | `CompetitionCategory` | `categoryId`; `(style, division, classLevel)` | – | (a) |
| `Registration` | starke E. | `Registration` | `registrationId`; `(eventId, participantId)` | `participantId → Participant`; `eventId → Event`; `categoryId → CompetitionCategory` | (a),(c) |
| `StartGroup` | starke E. | `StartGroup` | `groupId`; `(roundId, groupNumber)` | `roundId → Round`; `rangeId → Range` | (a),(c) |
| `ScoreCard` | starke E. | `ScoreCard` | `scoreCardId`; `(registrationId, roundId)` | `registrationId → Registration`; `roundId → Round`; `officialId → Official` [NULL] | (a),(c),(k) |
| `ShotResult` | schwache E. | `ShotResult` | `(scoreCardId, targetNumber, arrowNumber)` | `scoreCardId → ScoreCard`; `(rangeId, targetNumber) → TargetStation`; `tieBreakId → TieBreak` [NULL] | (b),(c) |
| `TournamentResult` | starke E. | `TournamentResult` | `resultId`; `registrationId` | `registrationId → Registration` (UNIQUE) | (a),(d) |
| `TieBreak` | starke E. | `TieBreak` | `tieBreakId` | – | (a) |
| `Protest` | starke E. | `Protest` | `protestId` | `officialId → Official`; `registrationId → Registration` | (a),(c) |
| `Person` | Supertyp | *(keine eigene Relation)* | – | – | (f) |
| `consistsOf` | 1:1..4 | → FK in `Round` | s. `Round` | `eventId → Event` | (c) |
| `uses` (Round–Range) | *:* | `RoundRange` | `(roundId, rangeId)` | `roundId → Round`; `rangeId → Range` | (e) |
| `includes` (SG–Reg) | *:* | `StartGroupMember` | `(groupId, registrationId)` | `groupId → StartGroup`; `registrationId → Registration` | (e) |
| `resolvesTie` | *:* | `TieBreakParticipant` | `(tieBreakId, registrationId)` | `tieBreakId → TieBreak`; `registrationId → Registration` | (e) |
| `TargetDistance` | Assoz.-Klasse (*:*) | `TargetDistance` | `(rangeId, targetNumber, categoryId)` | `(rangeId, targetNumber) → TargetStation`; `categoryId → CompetitionCategory` | (e),(g) |
| `usesShot` (TieBreak–SR) | 1:1..* | → FK in `ShotResult` | s. `ShotResult` | `tieBreakId → TieBreak` [NULL] | (c),(k) |
| Name (composite) | comp. Attr. | Spalten `firstName`,`lastName` | – | – | (h) |

: Mapping-Dokumentation: konzeptuelles Element → logische Relation {#tbl-t1-mapping}

### Begründung nicht-trivialer Entscheidungen {#sec-t1-rationale}

**R1 – Generalisierung `Person` in Subtypen aufgelöst.** Da `Person` nur zwei
gemeinsame Attribute trägt und die Subtypen sehr unterschiedlich verwendet werden
(`Participant`: Anmeldung/Scoring; `Official`: Signatur/Protest), und die
Spezialisierung {mandatory, disjoint} ist, wird die Strategie *one relation per
subclass* gewählt. Das vermeidet eine sonst nötige Verbund-Operation für nahezu
jeden Lese-Zugriff auf Namen und erzeugt keine NULL-lastige Supertyp-Tabelle.
Trade-off: `firstName`/`lastName` existieren zweifach – akzeptabel, da getrennte
Wertebereiche und keine gemeinsame Identität über Subtypen hinweg benötigt werden.

**R2 – `includes` als *:* (Brückenrelation `StartGroupMember`).** Konzeptuell
notiert Assignment 02 `StartGroup 1 : 3..6 Registration`. Diese 1:*-Lesart gilt
jedoch nur **innerhalb einer Runde**: Da Startgruppen rundenbezogen sind
(`forRound`) und jeder Schütze 4 Runden absolviert, gehört eine `Registration`
über das Event hinweg zu **mehreren** Startgruppen. Logisch korrekt ist daher eine
*:*-Beziehung, die in `StartGroupMember` aufgelöst wird. Diese Präzisierung ist
ein erster Iterationspunkt und wird in Task 3 transaktional bestätigt.

**R3 – `ShotResult.atTarget` benötigt `rangeId`.** `ShotResult` führt
`targetNumber` bereits als Teil seines Schlüssels, der Fremdschlüssel auf
`TargetStation` ist jedoch zusammengesetzt `(rangeId, targetNumber)`. Da es
keinen direkten Pfad `ScoreCard → Range` gibt (die Range ergibt sich erst über
`StartGroup`), wird `rangeId` explizit in `ShotResult` ergänzt, um den
Fremdschlüssel `atTarget` durchsetzbar zu machen. Der zugehörige Join-Pfad wird
in Task 3 validiert.

**R4 – `usesShot` (`TieBreak`–`ShotResult`) als optionaler 1:* FK.** Die
Shoot-off-Pfeile sind reguläre `ShotResult`-Einträge; ein nullbarer FK
`tieBreakId` in `ShotResult` ordnet sie dem jeweiligen Stechen zu, ohne eine
zusätzliche Relation zu erzwingen.

### Aufgenommene Ergänzungen gegenüber Assignment 02 {#sec-t1-deltas}

Aus der Transaktionsvalidierung (Task 4, Assignment 02) wurden zwei Attribut-Gaps
direkt in das **initiale** logische Modell übernommen, damit es nicht von Beginn an
hinter dem konzeptuellen Stand zurückfällt:

| # | Ergänzung | Relation | Quelle (A02) |
|---|---|---|---|
| 1 | `classificationVerified`, `classificationDate` | `Registration` | T2-Gap, Update 1 |
| 2 | `startTarget` explizit modelliert | `StartGroup` | T3-Gap, Update 2 |

: Aus Assignment 02 übernommene Modell-Updates {#tbl-t1-deltas}

Strukturelle Iterationen, die sich **erst** aus der logischen Transaktionsprüfung
ergeben (z. B. Bestätigung der Brückenrelationen, Join-Pfade), werden in Task 3
als „initial → revised" dokumentiert.