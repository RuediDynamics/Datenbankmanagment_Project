# Assignment 03 – Data Dictionary: WBHC 2027 Domain Model

**Domäne:** IFAA World Bowhunter Championships (WBHC) 2027, Bad Waldsee  
**Notation:** UML Data Model Profile · **Werkzeug:** PlantUML  
**Basiert auf:** Assignment 02 – Conceptual Data Model  

---

## Entity Dictionary

| Entity name | Aliases | Description | Expected no. of occurrences |
|---|---|---|---|
| `Event` | Veranstaltung, Tournament | Die WBHC 2027 selbst – ein einmaliges Turniermeisterschaftsevent nach IFAA-Regeln | ~1 |
| `Round` | Runde, Competition Round | Eine der vier Turnierrunden mit eigenem Punktesystem (Unmarked Animal 3-Pfeil, Standard 3D 2-Pfeil, Hunting 3D 1-Pfeil) | 4 |
| `Range` | Strecke, Course | Eine physische Strecke mit standardmäßig 28 Zielen, die in einer oder mehreren Runden verwendet wird | ~4–8 |
| `TargetStation` | Ziel, Target, Goal Post | Ein einzelnes Ziel (1–28) auf einer Range mit Zielgruppe (1–4) und rundentyp-abhängiger maximaler Schussdistanz | ~112–224 |
| `Participant` | Schütze, Archer, Competitor | Ein einzelner Bogenschütze, der sich zum Event anmeldet; mit Profildaten wie Name, Geburtsdatum, Nationalität, Verein | ~1.200 |
| `Nation` | Land, Country | Das Land, das ein Teilnehmer vertritt (IFAA-Zugehörigkeit nach Ländercode ISO-3) | ~60 |
| `Club` | Verein, Organization | Verein oder Sportorganisation, dem ein Teilnehmer angehört (optional) | ~150–200 |
| `Official` | Offizieller, Schiedsrichter, Turnierdirektor | Person mit Funktion im Turnier (Turnierdirektor, Target Captain, Ranger); kann mehrere Ranges betreuen | ~30–50 |
| `Registration` | Anmeldung, Entry | Die formale Anmeldung eines Teilnehmers zum Event; bindet Teilnehmer an Style/Division/Class und erfasst Gebührenstatus und Ausrüstungsprüfung | ~1.200 |
| `CompetitionCategory` | Wettkampfkategorie, Score Category | Eindeutige Kombination aus Style (z. B. BB, FSR, LB), Division (Adult, Veteran, Junior), und Class (A, B, C); definiert Regeln und Scoring | ~60–80 |
| `StartGroup` | Startgruppe, Flight, Group | Eine Gruppe von 3–6 Schützen, die an einer Runde gemeinsam eine Range schießen; mit eindeutiger Gruppe-Nummer pro Runde | ~200–400 |
| `ScoreCard` | Scorekarte, Score Sheet | Die Ergebniskarte eines Teilnehmers für eine Runde; erfasst alle 28 Ziele × Pfeile und wird vom Target Captain unterschrieben | ~4.800 |
| `ShotResult` | Schussergebnis, Arrow Result | Das Ergebnis eines einzelnen Pfeils (Trefferzone, Punktwert) an einem bestimmten Ziel; 28–84 pro Scorekarte je nach Rundentyp | ~86.400–201.600 |
| `TournamentResult` | Turnierergebnis, Final Result | Aggregiertes Gesamtergebnis eines Teilnehmers über alle Runden; enthält Gesamtpunkte, Rangposition je Category und Tiebreak-Status | ~1.200 |
| `TieBreak` | Stechen, Shoot-off | Entscheidungsrunde zwischen zwei oder mehr punktgleichen Teilnehmern über 3D-Zielgruppe mit je 3 Pfeilen pro Teilnehmer | ~20–100 |
| `Protest` | Regelentscheid, Dispute | Formelle Einspruchsdokumentation gegen Entscheidung oder Regelauslegung; mit Entscheidung und verantwortlichem Offiziellen | ~5–50 |
| `Person` | – | **Supertyp** für gemeinsame Attribute (`firstName`, `lastName`) von Participant und Official | – |

: Entity dictionary {#tbl-entity-dictionary}

---

## Relationship Dictionary

| Relationship name | Entity 1 | Entity 2 | Multiplicity | Mandatory? | Description |
|---|---|---|---|---|---|
| `consistsOf` | Event | Round | 1 : 1..4 | Yes | Ein Event besteht aus 1–4 Runden (WBHC: genau 4 Runden) |
| `uses` | Round | Range | 1..* : 1..* | Yes | Eine Runde nutzt eine oder mehrere Ranges (z. B. zwei Tage, zwei Ranges parallel) |
| `contains` | Range | TargetStation | 1 : 28 | Yes | Eine Range enthält genau 28 standardisierte Zielstationen (TargetStations 1–28) |
| `submits` | Participant | Registration | 1 : 0..* | No | Ein Teilnehmer reicht 0–* Anmeldungen ein (Mehrfachstart in verschiedenen Events möglich, aber für WBHC: 0–1) |
| `forEvent` | Registration | Event | * : 1 | Yes | Jede Anmeldung bezieht sich auf genau ein Event |
| `categorisedAs` | Registration | CompetitionCategory | * : 1 | Yes | Jede Anmeldung wird in genau eine CompetitionCategory (Style/Division/Class) eingeordnet |
| `representsNation` | Participant | Nation | * : 1 | Yes | Jeder Teilnehmer repräsentiert genau eine Nation |
| `memberOf` | Participant | Club | 0..* : 0..1 | No | Ein Teilnehmer kann optional Mitglied eines Clubs sein; ein Club kann viele Mitglieder haben |
| `forRound` | StartGroup | Round | * : 1 | Yes | Jede StartGroup gehört zu genau einer Runde |
| `assignedToRange` (StartGroup–Range) | StartGroup | Range | * : 1 | Yes | Jede StartGroup wird genau einer Range zugewiesen |
| `includes` | StartGroup | Registration | 1 : 3..6 | Yes | Eine StartGroup umfasst 3–6 Anmeldungen (Registrations) |
| `recordsFor` | ScoreCard | Registration | * : 1 | Yes | Eine ScoreCard dokumentiert die Ergebnisse genau einer Anmeldung (Registration) |
| `forRound` (ScoreCard–Round) | ScoreCard | Round | * : 1 | Yes | Eine ScoreCard gehört zu genau einer Runde |
| `contains` (ScoreCard–ShotResult) | ScoreCard | ShotResult | 1 : 28..84 | Yes | Eine ScoreCard enthält 28–84 ShotResults je nach Rundentyp (3 Pfeile pro Ziel oder weniger) |
| `atTarget` | ShotResult | TargetStation | * : 1 | Yes | Jedes ShotResult bezieht sich auf genau ein TargetStation |
| `signedBy` | ScoreCard | Official | * : 1 | No | Eine ScoreCard wird (optional) vom Target Captain (Official) unterzeichnet/validiert |
| `summarises` | TournamentResult | Registration | 1 : 1 | Yes | Jedes TournamentResult fasst die Ergebnisse genau einer Registration zusammen (1:1 Assoziation) |
| `resolvesTie` | TieBreak | Registration | * : 2..* | Yes | Ein TieBreak bezieht 2–* Anmeldungen (punktgleiche Kandidaten) ein |
| `uses` (TieBreak–ShotResult) | TieBreak | ShotResult | 1 : 1..* | Yes | Ein TieBreak referenziert 1–* ShotResults (Ergebnisse der Shoot-off-Pfeile) |
| `assignedToRange` (Official–Range) | Official | Range | 1 : 0..* | No | Ein Official ist optionally einer oder mehreren Ranges zugewiesen |
| `decides` | Official | Protest | 1 : 0..* | No | Ein Official trifft optionally 0–* Protestentscheidungen |
| `concerns` | Protest | Registration | * : 1 | Yes | Ein Protest betrifft genau eine Anmeldung (Registration) |
| `isA` (Person–Participant) | Person | Participant | 1 : 1 | Yes | **Generalisierung:** Participant ist eine Spezialisierung von Person |
| `isA` (Person–Official) | Person | Official | 1 : 1 | Yes | **Generalisierung:** Official ist eine Spezialisierung von Person |

: Relationship dictionary {#tbl-relationship-dictionary}

---

## Attribute Dictionary

| Attribute name | Entity / Relationship | Description | Domain / Data type | Composite? | Multi-valued? | Derived? | Required? |
|---|---|---|---|---|---|---|---|
| `eventId` | Event | Eindeutige Event-ID | UUID/Integer | No | No | No | Yes |
| `name` | Event | Name der Veranstaltung (z. B. "IFAA WBHC 2027") | varchar(100) | No | No | No | Yes |
| `startDate` | Event | Turnier-Startdatum | ISO 8601 (YYYY-MM-DD) | No | No | No | Yes |
| `endDate` | Event | Turnier-Enddatum | ISO 8601 (YYYY-MM-DD) | No | No | No | Yes |
| `location` | Event | Austragungsort | varchar(100) | No | No | No | Yes |
| `organizer` | Event | Veranstalter (z. B. DFBV) | varchar(100) | No | No | No | No |
| `ifaaReference` | Event | IFAA-Referenznummer oder Lizenz | varchar(20) | No | No | No | No |
| `roundId` | Round | Eindeutige Runden-ID | UUID/Integer | No | No | No | Yes |
| `roundNumber` | Round | Sequenz-Nummer der Runde (1, 2, 3, 4) | Integer [1..4] | No | No | No | Yes |
| `roundType` | Round | Rundentyp mit eigenem Pfeilvorgabe-Schema | Enum: {UnmarkedAnimal_3Arrow, Standard3D_2Arrow, Hunting3D_1Arrow} | No | No | No | Yes |
| `roundDate` | Round | Datum der Runde | ISO 8601 (YYYY-MM-DD) | No | No | No | Yes |
| `rangeId` | Range | Eindeutige Range-ID | UUID/Integer | No | No | No | Yes |
| `rangeName` | Range | Bezeichnung der Strecke (z. B. "Range A", "Wiese Nord") | varchar(50) | No | No | No | Yes |
| `numberOfTargets` | Range | Anzahl der Ziele auf dieser Range | Integer = 28 | No | No | Yes: COUNT(TargetStation) | Yes |
| `targetNumber` | TargetStation | Ziel-Nummer im Bereich 1–28 | Integer [1..28] | No | No | No | Yes |
| `targetGroup` | TargetStation | Zielgruppe-Nummer (1–4) für Tie-Break-Shoot-off | Integer [1..4] | No | No | No | Yes |
| `participantId` | Participant | Eindeutige Teilnehmer-ID | UUID/Integer | No | No | No | Yes |
| `firstName` | Person | Vorname (geerbt von Supertyp Person) | varchar(50) | No | No | No | Yes |
| `lastName` | Person | Nachname (geerbt von Supertyp Person) | varchar(50) | No | No | No | Yes |
| `birthDate` | Participant | Geburtsdatum für Altersklassen-Validierung | ISO 8601 (YYYY-MM-DD) | No | No | No | Yes |
| `age` | Participant | Berechnetes Alter des Schützen | Integer | No | No | Yes: YEAR(NOW()) - YEAR(birthDate) | No |
| `nationCode` | Nation | ISO-3-Ländercode (z. B. "AUT", "GER") | varchar(3) | No | No | No | Yes |
| `nationName` | Nation | Vollständiger Name des Landes | varchar(100) | No | No | No | Yes |
| `clubId` | Club | Eindeutige Club-ID | UUID/Integer | No | No | No | Yes |
| `clubName` | Club | Name des Clubs/Verbands | varchar(100) | No | No | No | Yes |
| `officialId` | Official | Eindeutige Offizielle-ID | UUID/Integer | No | No | No | Yes |
| `officialFunction` | Official | Funktion im Turnier | Enum: {TournamentDirector, TargetCaptain, Ranger, ...} | No | No | No | Yes |
| `registrationId` | Registration | Eindeutige Anmelde-ID | UUID/Integer | No | No | No | Yes |
| `entryFeeStatus` | Registration | Gebührenstatus | Enum: {Paid, Unpaid, Exempted} | No | No | No | Yes |
| `equipmentStatus` | Registration | Ausrüstungsprüfung | Enum: {Checked, NotChecked, Failed} | No | No | No | Yes |
| `categoryId` | CompetitionCategory | Eindeutige Kategorie-ID | UUID/Integer | No | No | No | Yes |
| `style` | CompetitionCategory | Schießstil (z. B. BB, FSR, LB, BU, FS, TR, ...) | Enum: {BB, BBR, BHR, BL, BU, FS, FSR, FU, LB, TR} | No | No | No | Yes |
| `division` | CompetitionCategory | Altersklasse | Enum: {Adult, Veteran, Senior, YoungAdult, Junior, Cub} | No | No | No | Yes |
| `classLevel` | CompetitionCategory | Leistungsklasse | Enum: {A, B, C} | No | No | No | Yes |
| `groupId` | StartGroup | Eindeutige StartGroup-ID | UUID/Integer | No | No | No | Yes |
| `groupNumber` | StartGroup | Gruppen-Nummer pro Runde (1, 2, 3, ...) | Integer [1..n] | No | No | No | Yes |
| `startTarget` | StartGroup | Erstes zu schießendes Ziel (1–28) | Integer [1..28] | No | No | No | Yes |
| `scoreCardId` | ScoreCard | Eindeutige ScoreCard-ID | UUID/Integer | No | No | No | Yes |
| `roundTotal` | ScoreCard | Gesamtpunkte dieser Runde | Integer [0..20*28] | No | No | Yes: SUM(pointValue) | Yes |
| `shotResultId` | ShotResult | Eindeutige Schussergebnis-ID (Composite: scoreCardId + targetNumber + arrowNumber) | UUID/Integer | No | No | No | Yes |
| `arrowNumber` | ShotResult | Pfeilvorgabe pro Ziel (1, 2, oder 3) | Integer [1..3] | No | No | No | Yes |
| `hitZone` | ShotResult | Trefferzone des Pfeils | Enum: {Kill, Vital, Wound, Miss} | No | No | No | Yes |
| `pointValue` | ShotResult | Punktwert des Pfeils abhängig von Ziel, Zone und Rundentyp | Integer [0..20] | No | No | Yes: LOOKUP(roundType, hitZone, arrowNumber) | Yes |
| `resultId` | TournamentResult | Eindeutige Ergebnis-ID | UUID/Integer | No | No | No | Yes |
| `totalPoints` | TournamentResult | Summe aller Rundenpunkte | Integer [0..20*28*4] | No | No | Yes: SUM(roundTotal) | Yes |
| `rankPosition` | TournamentResult | Rangplatzierung in der Kategorie | Integer [1..n] | No | No | Yes: RANK() OVER (PARTITION BY categoryId ORDER BY totalPoints DESC) | Yes |
| `tieBreakStatus` | TournamentResult | Status im Falle von Punktegleichstand | Enum: {NotApplicable, Pending, Resolved, Winner} | No | No | No | No |
| `tieBreakId` | TieBreak | Eindeutige TieBreak-ID | UUID/Integer | No | No | No | Yes |
| `tieBreakRound` | TieBreak | Welche Zielgruppe wurde zum Stechen genutzt | Integer [1..4] | No | No | No | Yes |
| `protestId` | Protest | Eindeutige Protest-ID | UUID/Integer | No | No | No | Yes |
| `protestDate` | Protest | Datum des Protests | ISO 8601 (YYYY-MM-DD) | No | No | No | Yes |
| `protestDescription` | Protest | Beschreibung des Regelkonfikts | Text | No | No | No | Yes |
| `protestDecision` | Protest | Entscheidung des Officials | Text (oder strukturiertes Enum) | No | No | No | Yes |

: Attribute dictionary {#tbl-attribute-dictionary}

---

## Key Documentation

| Entity name | Candidate key(s) | Selected identifier | Alternate keys | Key type |
|---|---|---|---|---|
| `Event` | `eventId`, `(name, startDate)` | `eventId` | `(name, startDate)` | Strong |
| `Round` | `roundId`, `(eventId, roundNumber)` | `roundId` | `(eventId, roundNumber)` | Strong |
| `Range` | `rangeId`, `rangeName` | `rangeId` | `rangeName` | Strong |
| `TargetStation` | `(rangeId, targetNumber)` | `(rangeId, targetNumber)` | – | **Weak** (existential dependency on Range) |
| `Participant` | `participantId` | `participantId` | – | Strong |
| `Nation` | `nationCode`, `nationName` | `nationCode` | `nationName` | Strong |
| `Club` | `clubId`, `clubName` | `clubId` | `clubName` | Strong |
| `Official` | `officialId` | `officialId` | – | Strong |
| `Registration` | `registrationId`, `(eventId, participantId)` | `registrationId` | `(eventId, participantId)` | Strong |
| `CompetitionCategory` | `categoryId`, `(style, division, classLevel)` | `categoryId` | `(style, division, classLevel)` | Strong |
| `StartGroup` | `groupId`, `(roundId, groupNumber)` | `groupId` | `(roundId, groupNumber)` | Strong |
| `ScoreCard` | `scoreCardId`, `(registrationId, roundId)` | `scoreCardId` | `(registrationId, roundId)` | Strong |
| `ShotResult` | `(scoreCardId, targetNumber, arrowNumber)` | `(scoreCardId, targetNumber, arrowNumber)` | – | **Weak** (existential dependency on ScoreCard) |
| `TournamentResult` | `resultId`, `registrationId` | `resultId` | `registrationId` | Strong (1:1 with Registration) |
| `TieBreak` | `tieBreakId` | `tieBreakId` | – | Strong |
| `Protest` | `protestId` | `protestId` | – | Strong |
| `Person` | – | – | – | **Supertyp** (Abstract) |

: Key documentation {#tbl-key-documentation}

---

## Normalisierungsanmerkungen

### Prüfung auf Redundanzen

| # | Befund | Maßnahme | Normalform |
|---|---|---|---|
| 1 | `(style, division, classLevel)` redundant über Registrations | Zu Entität `CompetitionCategory` erhoben | 3NF |
| 2 | `age` aus `birthDate` ableitbar | Attribut als *derived* markiert; wird bei Bedarf berechnet | 2NF |
| 3 | `roundTotal` aus `ShotResult.pointValue` summierbar | Attribut als *derived* markiert; wird bei Bedarf berechnet | 2NF |
| 4 | `totalPoints` aus `ScoreCard.roundTotal` summierbar | Attribut als *derived* markiert; wird bei Bedarf berechnet | 2NF |
| 5 | `rankPosition` aus Ranking-Funktion ableitbar | Attribut als *derived* markiert; wird bei Bedarf berechnet | 2NF |
| 6 | `numberOfTargets` immer 28 (konstant) | Redundanzfreie Modellierung über Constraint | 3NF |

---

## Kardinalitätsüberblick

| Entity | Estimated count | Basis |
|---|---|---|
| Event | ~1 | WBHC 2027 (Einzelveranstaltung) |
| Round | 4 | IFAA-Regeln (2× Unmarked Animal, 1× Standard 3D, 1× Hunting 3D) |
| Range | ~4–8 | Austragungsort Bad Waldsee; 2–4 Ranges parallel pro Runde |
| TargetStation | ~112–224 | 28 Targets × 4–8 Ranges |
| Participant | ~1.200 | Tyische WBHC-Teilnehmerzahl |
| Nation | ~60 | IFAA-Mitgliedsländer |
| Club | ~150–200 | Grobe Schätzung; Deutschland + Ausland |
| Official | ~30–50 | Turnierdirektor + TCOs pro Range + Ranger |
| Registration | ~1.200 | 1 pro Participant (Mehrfach-Starts unwahrscheinlich in WBHC) |
| CompetitionCategory | ~60–80 | Styles (10) × Divisions (6) × Classes (3) = 180 theoretisch, aber viele Kombinationen nicht besetzt |
| StartGroup | ~200–400 | Abhängig von Ranges und Schützen pro Gruppe (3–6) |
| ScoreCard | ~4.800 | Participants (1.200) × Rounds (4) |
| ShotResult | ~86.400–201.600 | 28 Targets × 3 Pfeile pro ScoreCard × 4.800 ScoreCards = 403.200 (maximal 3 Pfeile bei Hunting/Standard, 1 bei Animal) |
| TournamentResult | ~1.200 | 1 pro Registration |
| TieBreak | ~20–100 | Grobe Schätzung; stark abhängig von Punkteverteilung |
| Protest | ~5–50 | Gering (Annahme: <1% aller Schützen) |

---

## Datenschutz und Integritätszwänge

### Referenzielle Integrität

- Alle Foreign Keys müssen auf existierende Parent Entities verweisen (z. B. `registrationId` in `ScoreCard` muss existierende `Registration.registrationId` referenzieren)
- Löschen von Parent-Entitäten (z. B. `Registration`) erfordert Löschen oder Neupositionierung abhängiger Child-Entitäten (z. B. `ScoreCard`)

### Domain-Constraints

- `pointValue` in `ShotResult`: Integer [0..20] je nach IFAA-Regeln für hitZone und arrowNumber
- `targetNumber` in `TargetStation` und `ShotResult`: Integer [1..28]
- `arrowNumber` in `ShotResult`: Integer [1..3] (maximal 3 Pfeile pro Ziel)
- `roundNumber` in `Round`: Integer [1..4] (genau 4 Runden in WBHC)
- `roundType` in `Round`: Enum {UnmarkedAnimal_3Arrow, Standard3D_2Arrow, Hunting3D_1Arrow} – bestimmt Pfeilzahl pro Ziel

### Sperren gegen doppelte Einträge

- Eindeutigkeit von `(eventId, participantId)` in `Registration` verhindert Mehrfach-Anmeldung
- Eindeutigkeit von `(registrationId, roundId)` in `ScoreCard` verhindert mehrfache Scorekaerträge pro Teilnehmer und Runde

---

## Glossar und Domain-spezifische Begriffe

| Term | Definition |
|---|---|
| **WBHC** | World Bowhunter Championships – internationales 3D-Bogenschießen-Turnier |
| **IFAA** | International Field Archery Association – Regelwerk und Mitgliedsorganisationen |
| **3D-Bogenschießen** | Disziplin mit 3D-Tierfiguren als Ziele (im Gegensatz zu Standard-Scheibenschießen) |
| **Roundtype** | Rundentyp bestimmt Pfeilzahl pro Ziel und Punktesystem (Unmarked Animal 3, Standard 3D 2, Hunting 3D 1) |
| **Division** | Altersklasse (Adult, Veteran, Senior, YoungAdult, Junior, Cub) |
| **Style** | Ausrüstungskategorie (z. B. BB = Bare Bow, FS = Freie Schussweise, LB = Langbogen, ...) |
| **Class** | Leistungsklasse (A = Anfänger, B = Mittelstufe, C = Fortgeschrittene); oft auch Handicap-System |
| **Startgruppe** | 3–6 Schützen, die gemeinsam eine Range schießen |
| **StartTarget** | Erstes Ziel, bei dem eine Startgruppe beginnt |
| **Target Captain (TCO)** | Offizieller auf der Range, der Scorekaarten unterzeichnet und Regeln durchsetzt |
| **Scorekarte** | Erfassungsdokument für 28 Ziele × max. 3 Pfeile pro Ziel |
| **Tie-Break / Shoot-off** | Entscheidungsrunde zwischen punktgleichen Schützen über eine 3D-Zielgruppe |
| **Protest** | Formale Regelentscheid-Anfrage gegen eine Entscheidung durch den Turnierdirektor |



