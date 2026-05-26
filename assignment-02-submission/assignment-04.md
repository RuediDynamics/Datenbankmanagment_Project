# Assignment 04 – Validate Conceptual Model Against Stakeholder Transactions

**Domäne:** IFAA World Bowhunter Championships (WBHC) 2027, Bad Waldsee  
**Basis:** Assignment 02 – Final Conceptual Data Model | Assignment 03 – Data Dictionary  
**Methodik:** Connolly & Begg (2015), Kapitel 17 – Transaction Modeling & Validation

---

## Overview

Diese Aufgabe validiert, ob das finale konzeptuelle Datenmodell alle 8 Kerntransaktionen (T1–T8) aus Assignment 01 vollständig unterstützt. Die Validierung erfolgt mittels:

1. **Transaction-to-Model Matrix:** Zeigt für jede Transaktion, welche Entities, Relationships und Attribute erforderlich sind
2. **Transaction Pathway Representation:** Visualisiert die Navigationsrouten durch das Datenmodell
3. **Gap Analysis:** Identifiziert fehlende Elemente oder notwendige Modellanpassungen
4. **Design Iteration:** Dokumentiert ggf. erforderliche Revisionen

---

## Part 1: Transaction-to-Model Matrix (Initial Model)

| Transaction | Entities involved | Relationships involved | Attributes required | Fully supported? | Notes |
|---|---|---|---|---|---|
| **T1: Teilnehmer anlegen + Stil/Div/Class zuweisen** | Participant, Registration, CompetitionCategory, Nation, Club | submits (P→Reg), forEvent (Reg→Event), categorisedAs (Reg→CC), representsNation (P→Nation), memberOf (P→Club) | P: firstName, lastName, birthDate; N: nationCode; C: clubName; CC: style, division, classLevel | JA | Alle erforderlichen Entities und Relationships vorhanden; Attribute complete. Keine Lücken. |
| **T2: Klassifizierungskarte prüfen + Startzulassung** | Participant, Registration, CompetitionCategory | submits (P→Reg), categorisedAs (Reg→CC), representsNation (P→Nation) | Registration: entryFeeStatus, equipmentStatus, classificationVerified(?) | PARTIELL | Attribute `classificationVerified` und `classificationDate` fehlen in Registration. Modell-Update erforderlich. |
| **T3: Startgruppen erstellen + Schützen auf Ranges/Targets zuweisen** | StartGroup, Registration, Round, Range, TargetStation | forRound (SG→Round), includes (SG→Reg), assignedToRange (SG→Range), assignedToRange (SG→TargetStation?) | Round: roundDate; Range: rangeId; TargetStation: targetNumber; StartGroup: groupNumber, startTarget | PARTIELL | Relationship zwischen StartGroup und TargetStation fehlt. Aktuell nur assignedToRange (SG→Range) vorhanden; muss auch Start-Target (1–28) spezifizieren. Update erforderlich. |
| **T4: Schussergebnisse erfassen + Punkte berechnen** | ScoreCard, ShotResult, Registration, Round, TargetStation | recordsFor (SC→Reg), forRound (SC→Round), contains (SC→SR), atTarget (SR→TargetStation) | ScoreCard: scoreCardId, registrationId, roundId; ShotResult: arrowNumber, hitZone, pointValue; TargetStation: targetNumber | JA | Alle Entities und Relationships vorhanden; pointValue ist abgeleitet und wird berechnet. Fully supported. |
| **T5: Tagesergebnisse + Gesamtrangliste anzeigen** | TournamentResult, Registration, CompetitionCategory, ScoreCard, Participant | summarises (TR→Reg), recordsFor (SC→Reg), categorisedAs (Reg→CC), submits (P→Reg) | TR: totalPoints, rankPosition (abgeleitet); Reg: registrationId, participantId; CC: style, division, classLevel; SC: roundTotal | JA | Alle erforderlichen Entities vorhanden; abgeleitete Attribute (rankPosition, totalPoints) unterstützen Ranking. Fully supported. |
| **T6: Tie-Break erfassen + Gewinner bestimmen** | TieBreak, Registration, ShotResult, TargetStation | resolvesTie (TB→Reg), uses (TB→SR), atTarget (SR→TargetStation) | TieBreak: tieBreakId, tieBreakRound; ShotResult: pointValue, hitZone; TargetStation: targetGroup | JA | Alle Entities und Relationships vorhanden; targetGroup auf TargetStation ermöglicht Zielgruppe-Auswahl. Fully supported. |
| **T7: Protest dokumentieren + Offiziellen zuordnen** | Protest, Official, Registration, Participant | decides (Off→Protest), concerns (Protest→Reg), submits (P→Reg) | Protest: protestId, protestDate, protestDescription, protestDecision; Official: officialId, officialFunction | JA | Alle Entities und Relationships vorhanden. Protest mit Registration (nicht direkt mit Participant) verknüpft ist semantisch korrekt. Fully supported. |
| **T8: Ergebnisliste exportieren (IFAA-Format)** | TournamentResult, Registration, ScoreCard, Participant, CompetitionCategory, Round | summarises (TR→Reg), recordsFor (SC→Reg), submits (P→Reg), categorisedAs (Reg→CC), forRound (SC→Round) | All key attributes: P: firstName, lastName; Reg: registrationId; CC: style, division, classLevel; TR: totalPoints, rankPosition; SR: roundTotal | JA | Alle erforderlichen Entities und deren Attribute vorhanden; Export kann über TournamentResult mit JOIN über Reg→P→N erstellt werden. Fully supported. |

: Transaction-to-Model Matrix (Initial) {#tbl-transaction-matrix-initial}

---

## Part 2: Gap Analysis

### Kritische Lücken

| # | Lücke | Entities betroffen | Severity | Lösung |
|---|---|---|---|---|
| 1 | **T2:** Klassifizierungsprüfung-Attribute fehlen | Registration | Medium | Attribute `classificationVerified: Boolean`, `classificationDate: ISO 8601` zu Registration hinzufügen |
| 2 | **T3:** Start-Target Zuordnung ungenau | StartGroup → TargetStation | Medium | Direkte Relationship oder Attribut `startTarget` auf StartGroup ergänzen (bereits in Modell, aber nicht explizit in Dokumentation) |

### Weitere Beobachtungen

| # | Befund | Bewertung |
|---|---|---|
| 1 | Alle 8 Transaktionen können mit dem finalen Modell aus Assignment 02 durchgeführt werden | Bestätigt |
| 2 | 6 von 8 Transaktionen sind **fully supported** | Strong foundation |
| 3 | 2 Transaktionen (T2, T3) erfordern **Minor Model Adjustments** | Handhabbar |
| 4 | Keine existenziellen Lücken (z. B. fehlende Entities) identifiziert | Gut |

---

## Part 3: Modell-Updates (Revision 1)

Basierend auf der Gap Analysis werden folgende Anpassungen am Modell vorgenommen:

### Update 1: Registration – Klassifizierungsprüfung erweitern

**Entität:** `Registration`  
**Neue Attribute:**

```
classificationVerified: Boolean
  Description: Gibt an, ob die Klassifizierungskarte des Teilnehmers geprüft und validiert wurde
  Domain: {true, false}
  Required: Yes
  Derived: No

classificationDate: ISO 8601 (YYYY-MM-DD)
  Description: Datum, an dem die Klassifizierung geprüft wurde
  Domain: ISO 8601
  Required: Yes (wenn classificationVerified = true)
  Derived: No
```

**Begründung:** T2 benötigt Tracking des Klassifizierungsstatus zur Startzulassung. Aktuell gibt es keine Mechanik zum Dokumentieren, dass eine Klassifizierungskarte geprüft wurde.

---

### Update 2: StartGroup – Start-Target explizit dokumentieren

**Entität:** `StartGroup`  
**Attribut bereits vorhanden, aber in Relationship-Dokumentation präzisieren:**

Das Attribut `startTarget: Integer [1..28]` war bereits in Assignment 02 definiert und ist ausreichend zur Adressierung des Start-Ziels einer Startgruppe. Keine zusätzliche Relationship nötig, da dies über das Attribut abgedeckt ist.

**Dokumentation:** In T3 (Startgruppen-Erstellung) wird `startTarget` von der Range-Zuweisung abgeleitet oder manuell gesetzt. Die aktuelle Modellierung ist ausreichend.

---

## Part 4: Revised Transaction-to-Model Matrix (Nach Updates)

| Transaction | Entities involved | Relationships involved | Attributes required | Fully supported? | Status |
|---|---|---|---|---|---|
| **T1: Teilnehmer anlegen** | Participant, Registration, CompetitionCategory, Nation, Club | submits, forEvent, categorisedAs, representsNation, memberOf | firstName, lastName, birthDate, nationCode, style, division, classLevel | JA | No changes |
| **T2: Klassifizierungskarte prüfen** | Participant, Registration, CompetitionCategory | submits, categorisedAs, representsNation | entryFeeStatus, equipmentStatus, **classificationVerified, classificationDate** | JA | Updated |
| **T3: Startgruppen erstellen** | StartGroup, Registration, Round, Range, TargetStation | forRound, includes, assignedToRange | roundDate, groupNumber, **startTarget**, targetNumber | JA | Clarified |
| **T4: Schussergebnisse erfassen** | ScoreCard, ShotResult, Registration, Round, TargetStation | recordsFor, forRound, contains, atTarget | scoreCardId, arrowNumber, hitZone, pointValue, targetNumber | JA | No changes |
| **T5: Tagesergebnisse anzeigen** | TournamentResult, Registration, CompetitionCategory, ScoreCard, Participant | summarises, recordsFor, categorisedAs, submits | totalPoints, rankPosition, roundTotal, style, division, classLevel | JA | No changes |
| **T6: Tie-Break erfassen** | TieBreak, Registration, ShotResult, TargetStation | resolvesTie, uses, atTarget | tieBreakId, tieBreakRound, pointValue, hitZone, targetGroup | JA | No changes |
| **T7: Protest dokumentieren** | Protest, Official, Registration, Participant | decides, concerns, submits | protestId, protestDate, protestDescription, protestDecision, officialId | JA | No changes |
| **T8: Ergebnisliste exportieren** | TournamentResult, Registration, ScoreCard, Participant, CompetitionCategory, Round | summarises, recordsFor, submits, categorisedAs, forRound | firstName, lastName, totalPoints, rankPosition, roundTotal, style, division, classLevel | JA | No changes |

: Transaction-to-Model Matrix (Revised) {#tbl-transaction-matrix-revised}

---

## Part 5: Transaction Pathways – Entity Traversal

Für jede Transaktion werden die Entities und Relationships dokumentiert, die durchquert werden. Siehe auch PlantUML-Diagramme (*.puml-Dateien).

### T1: Teilnehmer anlegen und einer Stil/Divisions/Klassen-Kombination zuweisen

**Transaktion Typ:** Operational – Create/Update  
**Primäre Rolle:** Ergebnisbeauftragte (Sandra Klein)

**Entity Pathway:**
```
1. START: Participant (CREATE)
   - Attribute: firstName, lastName, birthDate, participantId (PK)
2. representsNation -> Nation
   - Attribute: nationCode (FK), nationName
3. memberOf -> Club (optional)
   - Attribute: clubId (FK), clubName
4. CREATE: Registration
   - Attribute: registrationId (PK), entryFeeStatus, equipmentStatus
   - FK: participantId (to Participant)
   - FK: eventId (to Event)
5. categorisedAs -> CompetitionCategory
   - Attribute: categoryId (FK), style, division, classLevel
END: Participant fully registered in system
```

**Validation Status:** FULLY SUPPORTED – No changes needed.

---

### T2: Klassifizierungskarte prüfen und Startzulassung erteilen

**Transaktion Typ:** Operational – Read/Update  
**Primäre Rolle:** Ergebnisbeauftragte (Sandra Klein)

**Entity Pathway:**
```
1. START: Registration (LOOKUP by participantId, eventId)
   - Attribute: registrationId, entryFeeStatus, equipmentStatus
2. submits <- Participant
   - Lookup: Prior tournament scores (external data)
3. categorisedAs -> CompetitionCategory
   - Verify classification rule (2 scores within 12 months)
4. UPDATE: Registration
   - SET: classificationVerified = true (NEW)
   - SET: classificationDate = TODAY (NEW)
   - SET: entryFeeStatus, equipmentStatus
END: Participant marked as approved
```

**Validation Status:** PARTIELL -> FULLY SUPPORTED (After Update 1)

---

### T3: Startgruppen für eine Runde erstellen und auf Ranges/Targets zuweisen

**Transaktion Typ:** Operational – Create/Update  
**Primäre Rolle:** Turnierdirektor (Klaus Brenner)

**Entity Pathway:**
```
1. START: Round (LOOKUP by eventId, roundNumber)
2. uses -> Range(s) (SELECT available, 1..*)
3. ALLOCATE: 3-6 Participants from Registrations
4. CREATE: StartGroup (for each Range)
   - groupId, groupNumber, startTarget [1..28] (CLARIFIED)
5. includes -> Registration (3..6 per group)
6. contains -> TargetStation (verify 28 per range)
END: StartGroup populated and assigned
```

**Validation Status:** PARTIELL -> FULLY SUPPORTED (After Clarification)

---

### T4: Schussergebnisse einer Scorekarte erfassen und Punkte berechnen

**Transaktion Typ:** Operational – Create  
**Primäre Rolle:** Ergebnisbeauftragte (Sandra Klein)

**Entity Pathway:**
```
1. START: ScoreCard (CREATE/LOOKUP for Registration + Round)
2. FOR EACH target (1..28):
   - atTarget -> TargetStation
   - FOR EACH arrow (1..3 depending on roundType):
     - INPUT: hitZone (Kill/Vital/Wound/Miss)
     - COMPUTE: pointValue (DERIVED)
     - INSERT: ShotResult
3. COMPUTE: roundTotal = SUM(pointValue)
4. UPDATE: ScoreCard SET roundTotal
5. SIGN: ScoreCard by Official (Target Captain)
END: All shot results recorded
```

**Validation Status:** FULLY SUPPORTED – No changes needed.

---

### T5: Tagesergebnisse und Gesamtrangliste anzeigen

**Transaktion Typ:** Managerial – Read (Calculated)  
**Primäre Rolle:** Alle drei Roles

**Entity Pathway:**
```
1. SELECT: CompetitionCategory (style, division, classLevel)
2. FOR EACH Registration in category:
   - submits <- Participant (get name)
   - representsNation -> Nation
   - AGGREGATE: ScoreCards (1..4 per registration)
   - COMPUTE: totalPoints (DERIVED) = SUM(roundTotal)
   - COMPUTE: rankPosition (DERIVED) = RANK() OVER (...)
3. DISPLAY: Leaderboard sorted by totalPoints DESC
END: Category ranking displayed
```

**Validation Status:** FULLY SUPPORTED – No changes needed.

---

### T6: Tie-Break-Shoot-off erfassen und Gewinner bestimmen

**Transaktion Typ:** Operational – Create/Read  
**Primäre Rolle:** Ergebnisbeauftragte (Sandra Klein)

**Entity Pathway:**
```
1. IDENTIFY: Tied participants (same totalPoints in category)
2. SELECT: TargetGroup [1..4] for shoot-off
3. CREATE: TieBreak record
4. FOR EACH tied participant:
   - RECORD: 3 shots (arrows 1-3)
   - INSERT: ShotResults (via uses relationship)
   - COMPUTE: tie-break total
5. DETERMINE: Winner (highest 3-shot total)
6. UPDATE: TournamentResult
   - SET: rankPosition = final_rank
   - SET: tieBreakStatus = 'Resolved'
END: Tie-break resolved
```

**Validation Status:** FULLY SUPPORTED – No changes needed.

---

### T7: Protest / Regelentscheid dokumentieren und Offiziellen zuordnen

**Transaktion Typ:** Operational – Create  
**Primäre Rolle:** Turnierdirektor (Klaus Brenner)

**Entity Pathway:**
```
1. INCIDENT: Participant contests decision
2. IDENTIFY: Affected Registration
3. CREATE: Protest
   - protestId, protestDate, protestDescription
4. concerns -> Registration
5. decides <- Official (decision-maker)
6. Official REVIEWS: Evidence and rulebook (manual)
7. UPDATE: Protest
   - SET: protestDecision (formal text)
END: Protest documented and resolved
```

**Validation Status:** FULLY SUPPORTED – No changes needed.

---

### T8: Offizielle Ergebnisliste exportieren (IFAA-Format)

**Transaktion Typ:** Managerial – Read/Report  
**Primäre Rolle:** Turnierdirektor + Ergebnisbeauftragte

**Entity Pathway:**
```
1. SELECT: Event
2. SELECT: Round(s) to export
3. FOR EACH CompetitionCategory:
   - SELECT: TournamentResults (sorted by rankPosition)
   - FOR EACH result:
     - Participant (firstName, lastName)
     - Nation (nationCode)
     - Club (optional)
     - AGGREGATE: ScoreCards per round
     - DISPLAY: R1, R2, R3, R4, Total scores
     - tieBreakStatus
4. CONSTRUCT: Result rows
5. FORMAT: IFAA standard (PDF or CSV)
6. EXPORT: With timestamp and DFBV seal
END: Official result list exported
```

**Validation Status:** FULLY SUPPORTED – No changes needed.

---

## Part 6: Summary: Transaction Validation Results

### Overall Assessment

| Aspect | Result | Notes |
|---|---|---|
| **Transactions fully supported** | 6 / 8 (initial) -> 8/8 (revised) | Complete coverage |
| **Transactions with minor updates** | 2 / 8 (initial) -> 0/8 (revised) | All resolved |
| **Critical gaps** | 0 | No missing entities |
| **Data model revision needed** | Yes | Minor updates only |
| **Model re-validation after updates** | Passed | All 8/8 fully supported |

---

## Part 7: Design Iteration Summary

### Iteration 1: Initial Model (Assignment 02 – Final)

**Status:** 6/8 transactions fully supported; 2/8 with gaps

**Identified Gaps:**
- **T2:** Missing Classification tracking attributes (`classificationVerified`, `classificationDate`)
- **T3:** Start-Target assignment ambiguous in relationship documentation

---

### Iteration 2: Revised Model (Current – Assignment 04)

**Updates Applied:**

1. **Registration Entity:** Added attributes
   - `classificationVerified: Boolean` – tracks whether classification card was verified
   - `classificationDate: ISO 8601` – tracks when classification was verified

2. **StartGroup Entity:** Clarified existing attribute
   - `startTarget: Integer [1..28]` – already in model, now properly documented for T3 pathway

**Result:** All 8/8 transactions now fully supported

---

## Part 8: Transaction Pathway Diagrams

Vier PlantUML-Diagramme visualisieren die Entity-Traversals für alle 8 Transaktionen:

| Diagram | Transaktionen | Focus | Visualisiert |
|---|---|---|---|
| `T1_T2_Pathways.puml` | T1, T2 | Participant registration & classification | Entity creation, lookups, updates |
| `T3_T4_Pathways.puml` | T3, T4 | Start groups & shot recording | Range assignment, result entry |
| `T5_T6_Pathways.puml` | T5, T6 | Rankings & tie-breaks | Aggregations, derived attributes, winner determination |
| `T7_T8_Pathways.puml` | T7, T8 | Protests & exports | Dispute handling, comprehensive reporting |

**Verwendung:** Die Diagramme zeigen visuell, wie Transaktionen durch das Modell navigieren, welche Relationships traversiert werden, und wo abgeleitete Attribute berechnet werden.

---

## Part 9: Recommendations for Next Phase (Logical Model)

1. **Implement derived attributes** efficiently:
   - pointValue: stored procedure or formula in business logic
   - roundTotal: database view or computed column
   - totalPoints: TournamentResult pre-computed, updated after each round
   - rankPosition: computed query or materialized view

2. **Add integrity constraints:**
   - Unique constraints: (eventId, participantId) on Registration
   - Unique constraints: (registrationId, roundId) on ScoreCard
   - Foreign key constraints on all relationships
   - Check constraint: arrowNumber must match roundType

3. **Index strategy:**
   - Cluster: Registration (eventId, categoryId)
   - Regular: ScoreCard (registrationId, roundId)
   - Regular: ShotResult (scoreCardId, targetNumber)
   - Regular: TournamentResult (rankPosition, tieBreakStatus)

4. **Tie-break data model:**
   - Decide: separate TieBreak_ShotResult junction table or embed ShotResult usage pattern
   - Clarify: whether TieBreak ShotResults are stored separately or linked to existing ScoreCard ShotResults

---

## Conclusion

Das finale konzeptuelle Datenmodell (nach Revision 1) unterstützt vollständig alle 8 Stakeholder-Transaktionen aus Exercise 1.

**Deliverables:**
- Transaction-to-Model Matrix (Initial + Revised)
- Gap Analysis mit 2 identifizierten Lücken
- Detaillierte Pathways für alle 8 Transaktionen
- Design Iteration Summary
- 4 PlantUML Transaction Pathway Diagramme
- Recommendations für Logical Model Phase

**Nächste Schritte:** Transition zum logischen Datenmodell (Relational Schema, Physical Design)

