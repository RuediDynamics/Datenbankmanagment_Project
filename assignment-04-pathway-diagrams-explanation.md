# Transaction Pathway Diagrams – Explanation and Summary

**Datei:** `assignment-04-transaction-validation.md`  
**Visualisierungen:** PlantUML Transaction Pathway Diagramme (4 Dateien)

---

## Übersicht der Transaction Pathway Diagramme

Diese 4 PlantUML-Diagramme visualisieren, wie jede Transaktion durch das konzeptuelle Datenmodell navigiert. Sie zeigen:

- **Sequenzen von Entity-Lookups und Inserts**
- **Beziehungen (Relationships) zwischen Entities**
- **Abgeleitete Attribute** (mit ✅-Markierung)
- **Neue Attribute nach Model Revision** (mit NEW-Label)
- **Bereiche, wo Lücken behoben wurden**

---

## Diagram 1: T1_T2_Pathways.puml

**Transaktionen:** T1 (Teilnehmer anlegen) + T2 (Klassifizierung prüfen)

### T1: Participant Creation and Category Registration

```
Participant (CREATE)
    ├─ LOOKUP Nation (representsNation)
    ├─ LOOKUP Club (memberOf, optional)
    └─ INSERT Registration (submits, forEvent, categorisedAs)
        └─ VERIFY CompetitionCategory (style, division, classLevel)
```

**Pathway:**
1. **Participant** wird angelegt mit firstName, lastName, birthDate
2. **Nation** wird per `representsNation`-Beziehung verlinkt
3. **Club** wird optional per `memberOf`-Beziehung verlinkt
4. **Registration** wird inserted mit Referenzen zu Participant, Event, und CompetitionCategory
5. **CompetitionCategory** wird validiert

**Validation Status:** ✅ **FULLY SUPPORTED**

---

### T2: Classification Verification and Start Permission

```
Registration (LOOKUP)
    ├─ READ Participant (prior scores – external lookup)
    ├─ VERIFY Classification rule (2 scores in 12 months)
    └─ UPDATE Registration
        ├─ SET classificationVerified = true ✅ NEW
        ├─ SET classificationDate = TODAY ✅ NEW
        └─ SET entryFeeStatus, equipmentStatus
```

**Pathway:**
1. **Registration** wird per participantId gesucht
2. **Participant** wird gelesen (Geburtsdatum für Altersverifizierung)
3. Prior tournament scores werden extern geprüft (nicht im WBHC-Modell gespeichert)
4. Classification-Status wird verifiziert
5. **Registration** wird aktualisiert mit:
   - `classificationVerified = true` ✅ **NEW in Revision 1**
   - `classificationDate = TODAY` ✅ **NEW in Revision 1**
   - Entry fee und equipment status werden ggf. aktualisiert

**Validation Status:** ⚠️ **PARTIELL** → ✅ **FULLY SUPPORTED** (nach Update)

**Revision Impact:** Die zwei neuen Attribute (`classificationVerified`, `classificationDate`) wurden hinzugefügt, um T2 vollständig zu unterstützen.

---

## Diagram 2: T3_T4_Pathways.puml

**Transaktionen:** T3 (Startgruppen erstellen) + T4 (Schussergebnisse erfassen)

### T3: Create Start Groups and Assign to Ranges

```
Round (LOOKUP)
    ├─ SELECT Range(s) (uses, 1..*)
    ├─ ALLOCATE 3-6 Participants
    ├─ INSERT StartGroup
    │   ├─ groupId, roundId, rangeId
    │   ├─ groupNumber
    │   └─ startTarget [1..28] ✅ CLARIFIED
    └─ LINK Registrations (includes, 3..6)
        └─ VERIFY TargetStations (contains, 28 per range)
```

**Pathway:**
1. **Round** wird gesucht (bestimmt roundType → Pfeilzahl pro Ziel)
2. **Range(s)** werden per `uses`-Beziehung geholt (1..* pro Runde)
3. Teilnehmer werden aus **Registrations** ausgewählt (3–6 pro Gruppe)
4. **StartGroup** wird angelegt mit:
   - groupNumber (Sequenz pro Runde)
   - **startTarget [1..28]** ✅ **CLARIFIED in Revision** – spezifiziert das erste zu schießende Ziel
5. **Registrations** werden per `includes`-Beziehung mit StartGroup verlinkt (3..6)
6. **TargetStations** werden validiert (genau 28 pro Range)

**Validation Status:** ⚠️ **PARTIELL** → ✅ **FULLY SUPPORTED** (nach Clarification)

**Revision Impact:** Das Attribut `startTarget` war bereits im Modell vorhanden, wurde aber in der Relationship-Dokumentation nicht explizit erwähnt. Die Clarification dokumentiert, dass dieses Attribut ausreicht, um das Start-Ziel zu spezifizieren.

---

### T4: Record Shot Results and Calculate Points

```
ScoreCard (CREATE or LOOKUP)
    ├─ recordsFor Registration
    └─ FOR each Target (1..28):
        ├─ GET TargetStation (atTarget)
        ├─ INSERT ShotResult
        │   ├─ (scoreCardId, targetNumber, arrowNumber)
        │   ├─ hitZone (Kill/Vital/Wound/Miss)
        │   └─ pointValue ✅ DERIVED
        └─ arrowNumber [1..3] per roundType
    ├─ COMPUTE roundTotal = SUM(pointValue)
    └─ SIGN ScoreCard (signedBy Official)
```

**Pathway:**
1. **ScoreCard** wird erstellt/gesucht für eine Registration und Round
2. Für jedes der 28 Ziele:
   - **TargetStation** wird gesucht (per `atTarget`-Beziehung)
   - **ShotResult** wird inserted für jeden Pfeil (1..3 je nach roundType)
   - **pointValue** wird **abgeleitet** aus:
     - roundType (Unmarked Animal 3-Arrow vs. Standard 3D 2-Arrow vs. Hunting 3D 1-Arrow)
     - hitZone (Kill → 20 Pts, Vital → 15 Pts, Wound → 10 Pts, Miss → 0 Pts)
     - arrowNumber (erste vs. zweite vs. dritte Pfeil – Bonus/Malus)
3. **roundTotal** wird berechnet als SUM aller pointValues und in ScoreCard gespeichert
4. **ScoreCard** wird vom Target Captain (Official) per `signedBy`-Beziehung unterzeichnet

**Validation Status:** ✅ **FULLY SUPPORTED**

**Key Feature:** Die abgeleitete Berechnung von `pointValue` ist kritisch und wird über eine Lookup-Tabelle oder Funktion implementiert:
```
pointValue = LOOKUP(roundType, hitZone, arrowNumber)
```

---

## Diagram 3: T5_T6_Pathways.puml

**Transaktionen:** T5 (Tagesergebnisse anzeigen) + T6 (Tie-Break erfassen)

### T5: Display Day Scores and Leaderboard

```
CompetitionCategory (SELECT)
    ├─ FOR each Registration (categorisedAs, *)
    │   ├─ LOOKUP Participant (submits, reverse)
    │   ├─ GET Nation (representsNation)
    │   ├─ AGGREGATE ScoreCards (recordsFor, 1..4 rounds)
    │   │   └─ SUM ShotResults (contains, 28..84 per scorecard)
    │   └─ GET TournamentResult
    │       ├─ totalPoints ✅ DERIVED = SUM(roundTotal)
    │       └─ rankPosition ✅ DERIVED = RANK() OVER (...)
    └─ DISPLAY leaderboard (sorted by totalPoints DESC)
```

**Pathway:**
1. **CompetitionCategory** wird ausgewählt (z. B. Adult, Bare Bow, Class A)
2. Für jeden Teilnehmer in dieser Kategorie:
   - **Participant** wird geholt (Namen, Geburtsdatum)
   - **Nation** wird geholt (Ländercode)
   - **ScoreCards** werden aggregiert (1–4 pro Round)
   - ShotResults werden summiert (28–84 pro Scorecard, abhängig von roundType)
   - **roundTotal** wird aus ShotResults berechnet
   - **TournamentResult** wird gelesen:
     - `totalPoints` = SUM aller roundTotals ✅ **DERIVED**
     - `rankPosition` = RANK() OVER (PARTITION BY categoryId ORDER BY totalPoints DESC) ✅ **DERIVED**
3. Leaderboard wird sortiert nach totalPoints DESC und angezeigt

**Validation Status:** ✅ **FULLY SUPPORTED**

**Key Feature:** Abgeleitete Ranking-Attribute ermöglichen effiziente Reporting ohne komplexe Joins:
```sql
SELECT rankPosition, totalPoints, firstName, lastName, nationCode
  FROM TournamentResult tr
  JOIN Registration r ON tr.registrationId = r.registrationId
  JOIN Participant p ON r.participantId = p.participantId
  WHERE r.categoryId = ?
  ORDER BY tr.rankPosition ASC
```

---

### T6: Record Tie-Break and Determine Winner

```
TournamentResult (IDENTIFY ties)
    ├─ WHERE totalPoints = (group by, multiple results)
    ├─ SELECT TargetGroup [1..4] for shoot-off
    ├─ CREATE TieBreak record
    └─ FOR each tied participant:
        ├─ RECORD 3 shots (arrowNumber 1, 2, 3)
        ├─ INSERT ShotResults (uses relationship)
        ├─ COMPUTE tie-break total (SUM of 3 shots)
        └─ DETERMINE winner (highest total)
    └─ UPDATE TournamentResult
        ├─ SET rankPosition = final_rank
        └─ SET tieBreakStatus = 'Resolved'
```

**Pathway:**
1. **TournamentResults** werden gesucht, bei denen `totalPoints` gleich sind (Unentschieden)
2. Ein **TargetGroup** wird ausgewählt (1–4) aus einer TargetStation
3. **TieBreak** Record wird erstellt (tieBreakId, tieBreakRound)
4. Für jeden gebundenen Teilnehmer:
   - 3 **ShotResults** werden recorded (1 Schuss pro Pfeil an ausgewählter Zielgruppe)
   - **ShotResults** werden per `uses`-Beziehung mit TieBreak verlinkt
   - Tie-break-Summe wird berechnet (SUM der 3 pointValues)
5. Gewinner wird bestimmt (höchste Gesamtpunktzahl über 3 Pfeile)
6. **TournamentResult** wird aktualisiert:
   - `rankPosition` = Finale Rangplatzierung
   - `tieBreakStatus` = 'Resolved'

**Validation Status:** ✅ **FULLY SUPPORTED**

**Note:** Wenn immer noch Unentschieden nach erste TieBreak → Repeat mit nächster TargetGroup (Round-Robin-Modus).

---

## Diagram 4: T7_T8_Pathways.puml

**Transaktionen:** T7 (Protest dokumentieren) + T8 (Ergebnisliste exportieren)

### T7: Document Protest and Assign Decision Maker

```
Incident (Participant contests decision)
    ├─ IDENTIFY Registration (affected entry)
    ├─ CREATE Protest record
    │   ├─ protestId, protestDate, protestDescription
    │   ├─ concerns Registration (*, 1)
    │   └─ decides Official (1, 0..*)
    ├─ Official REVIEWS evidence (manual off-model)
    └─ UPDATE Protest
        └─ SET protestDecision (formal text resolution)
```

**Pathway:**
1. Ein Incident tritt auf (z. B. Schütze bestreitet Scoring-Entscheidung)
2. **Registration** wird identifiziert (welche Anmeldung / welcher Schütze betroffen)
3. **Protest** Record wird erstellt mit:
   - `protestId`, `protestDate`, `protestDescription` (Beschreibung des Konflikts)
4. Protest wird per `concerns`-Beziehung mit **Registration** verlinkt (nicht direkt mit Participant)
   - Dies ermöglicht präzise Dokumentation, welche Anmeldung betroffen ist
5. **Official** (typischerweise Turnierdirektor) wird per `decides`-Beziehung zugewiesen
6. Official prüft Beweise und Regelwerk (manueller Prozess, nicht im Datenmodell)
7. **Protest** wird aktualisiert mit:
   - `protestDecision` = formale Entscheidung (freier Text oder strukturierter Enum)

**Validation Status:** ✅ **FULLY SUPPORTED**

**Design Note:** Link zu **Registration** statt direkt zu Participant ermöglicht:
- Verschiedene Proteste für gleichen Schützen in verschiedenen Kategorien
- Genaue Verfolgung, welche Entry betroffen ist (wichtig für IFAA-Compliance)

---

### T8: Export Official Results List (IFAA Format)

```
Event (SELECT event to export)
    ├─ SELECT Round(s) [R1, R2, R3, R4 or subset]
    └─ FOR each CompetitionCategory (style, division, classLevel):
        ├─ GET TournamentResults (sorted by rankPosition)
        └─ FOR each result (ranked participant):
            ├─ Participant (firstName, lastName)
            ├─ Nation (nationCode)
            ├─ Club (optional, memberOf)
            ├─ AGGREGATE ScoreCards (per round)
            │   └─ roundTotal [R1, R2, R3, R4]
            ├─ TournamentResult
            │   ├─ totalPoints ✅ DERIVED
            │   └─ tieBreakStatus
            └─ CONSTRUCT result row
    └─ FORMAT: IFAA standard (PDF or CSV)
        └─ EXPORT with timestamp and DFBV seal
```

**Pathway:**
1. **Event** wird ausgewählt (z. B. WBHC 2027)
2. **Rounds** werden ausgewählt (Subset oder alle 4)
3. Für jede **CompetitionCategory** (Stil, Division, Klasse):
   - **TournamentResults** werden geholt, sortiert by rankPosition
   - Für jeden ranked participant:
     - **Participant** wird gelesen (Name)
     - **Nation** wird gelesen (Ländercode für Flagge/Land)
     - **Club** wird gelesen (optional)
     - **ScoreCards** werden aggregiert (1–4 pro Round)
     - `roundTotal` wird angezeigt (R1, R2, R3, R4 Spalten)
     - `totalPoints` und `tieBreakStatus` werden angezeigt
   - Result row wird konstruiert: `Rank | Name | Country | Club | R1 | R2 | R3 | R4 | Total | Status`
4. Ergebnistabelle wird formatiert nach IFAA-Standard
5. Datei wird exportiert (PDF oder CSV) mit:
   - Event-Informationen
   - Datums-/Zeitstempel
   - DFBV-Siegel (externe Datei)

**Validation Status:** ✅ **FULLY SUPPORTED**

**Database Query Example:**
```sql
SELECT 
  tr.rankPosition,
  p.firstName || ' ' || p.lastName AS name,
  n.nationCode,
  c.clubName,
  sc1.roundTotal AS r1_score,
  sc2.roundTotal AS r2_score,
  sc3.roundTotal AS r3_score,
  sc4.roundTotal AS r4_score,
  tr.totalPoints,
  tr.tieBreakStatus
FROM TournamentResult tr
JOIN Registration r ON tr.registrationId = r.registrationId
JOIN Participant p ON r.participantId = p.participantId
JOIN Nation n ON p.nationCode = n.nationCode
LEFT JOIN Club c ON p.clubId = c.clubId
LEFT JOIN ScoreCard sc1 ON r.registrationId = sc1.registrationId AND sc1.roundId = 1
LEFT JOIN ScoreCard sc2 ON r.registrationId = sc2.registrationId AND sc2.roundId = 2
LEFT JOIN ScoreCard sc3 ON r.registrationId = sc3.registrationId AND sc3.roundId = 3
LEFT JOIN ScoreCard sc4 ON r.registrationId = sc4.registrationId AND sc4.roundId = 4
WHERE r.eventId = ? AND r.categoryId = ?
ORDER BY tr.rankPosition ASC
```

---

## Summary: Transaction Validation via Pathway Diagrams

| Transaction | Diagram | Entities | Relationships | Fully Supported? | Notes |
|---|---|---|---|---|---|
| T1 | T1_T2_Pathways | Participant, Registration, Nation, Club, CompetitionCategory | submits, forEvent, categorisedAs, representsNation, memberOf | ✅ YES | All entities and relationships present |
| T2 | T1_T2_Pathways | Registration, Participant, Nation, CompetitionCategory | submits (reverse) | ⚠️ → ✅ | NEW: classificationVerified, classificationDate attributes |
| T3 | T3_T4_Pathways | StartGroup, Registration, Round, Range, TargetStation | forRound, includes, assignedToRange, uses, contains | ⚠️ → ✅ | CLARIFIED: startTarget already in model |
| T4 | T3_T4_Pathways | ScoreCard, ShotResult, Registration, Round, TargetStation | recordsFor, forRound, contains, atTarget, signedBy | ✅ YES | pointValue is derived; fully supported |
| T5 | T5_T6_Pathways | TournamentResult, Registration, CompetitionCategory, ScoreCard, Participant, Nation | summarises, recordsFor, categorisedAs, submits, representsNation | ✅ YES | Derived attributes (totalPoints, rankPosition) enable fast reporting |
| T6 | T5_T6_Pathways | TieBreak, Registration, ShotResult, TargetStation, TournamentResult | resolvesTie, uses, atTarget, summarises | ✅ YES | Shoot-off mechanism supported; may require multi-round tie-breaks |
| T7 | T7_T8_Pathways | Protest, Registration, Participant, Official | concerns (Protest→Registration), decides, submits | ✅ YES | Link to Registration (not Participant) allows precision |
| T8 | T7_T8_Pathways | TournamentResult, Registration, ScoreCard, Participant, Nation, Club, CompetitionCategory, Round | summarises, recordsFor, submits, representsNation, memberOf, categorisedAs, forRound | ✅ YES | All data available for IFAA-compliant export |

---

## Iteration History

### Initial Model (Assignment 02 – Final)
- **Status:** 6/8 transactions fully supported
- **Gaps:** T2 (classification tracking), T3 (start-target clarity)

### Revised Model (Current – Assignment 04)
- **Updates Applied:** 
  1. Registration: `+classificationVerified`, `+classificationDate`
  2. StartGroup: Clarified `startTarget` documentation
- **Status:** ✅ **8/8 transactions fully supported**

---

## Recommendations for Next Phase (Logical Model)

1. **Implement derived attributes** efficiently:
   - `pointValue` → stored procedure or formula in business logic
   - `roundTotal` → database view or computed column
   - `totalPoints` → TournamentResult pre-computed, updated after each round
   - `rankPosition` → computed query or materialized view

2. **Add integrity constraints:**
   - Unique constraints: `(eventId, participantId)` on Registration
   - Unique constraints: `(registrationId, roundId)` on ScoreCard
   - Foreign key constraints on all relationships

3. **Index strategy:**
   - Cluster: Registration (eventId, categoryId)
   - Regular: ScoreCard (registrationId, roundId)
   - Regular: ShotResult (scoreCardId, targetNumber)

4. **Handle tie-breaks:**
   - Decide on data model: separate TieBreak_ShotResult junction table or embed in ShotResult

