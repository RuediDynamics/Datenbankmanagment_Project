# Task 3: Validate Logical Data Model Against Transactions


## Transaction Validation Matrix – Initiales Logisches Datenmodell

| Transaction | Relation(s) used | Join path / FK path | Key attributes needed | Support status | Notes / required model update |
|---|---|---|---|---|---|
| `T1: Teilnehmer anlegen und Stil/Div/Class zuweisen` | `Participant`, `Registration`, `CompetitionCategory`, `Nation`, `Club`, `Event` | `Registration.participantId → Participant.participantId`, `Registration.eventId → Event.eventId`, `Registration.categoryId → CompetitionCategory.categoryId`, `Participant.nationCode → Nation.nationCode`, `Participant.clubId → Club.clubId` | `participantId`, `firstName`, `lastName`, `birthDate`, `nationCode`, `clubId`, `style`, `division`, `classLevel`, `registrationId`, `entryFeeStatus`, `equipmentStatus` | Full | Fully supported. Alle Relationen, FK-Pfade und Attribute vorhanden. Keine Lücken. |
| `T2: Klassifizierungskarte prüfen und Startzulassung erteilen` | `Registration`, `Participant`, `CompetitionCategory` | `Registration.participantId → Participant.participantId`, `Registration.categoryId → CompetitionCategory.categoryId` | `registrationId`, `classificationVerified`, `classificationDate`, `entryFeeStatus`, `equipmentStatus`, `style`, `division`, `classLevel` | Full | Fully supported. Attribute `classificationVerified` und `classificationDate` wurden aus Assignment 02 Gap Analysis bereits in das initiale logische Modell übernommen. |
| `T3: Startgruppen erstellen und Schützen auf Ranges/Targets zuweisen` | `StartGroup`, `StartGroupMember`, `Registration`, `Round`, `Range`, `TargetStation`, `RoundRange` | `StartGroup.roundId → Round.roundId`, `StartGroup.rangeId → Range.rangeId`, `StartGroupMember.groupId → StartGroup.groupId`, `StartGroupMember.registrationId → Registration.registrationId`, `RoundRange.roundId → Round.roundId`, `RoundRange.rangeId → Range.rangeId` | `groupId`, `groupNumber`, `startTarget`, `roundId`, `roundDate`, `roundType`, `rangeId`, `rangeName`, `targetNumber` | Full | Fully supported. Brückenrelation `StartGroupMember` löst *:*-Beziehung korrekt auf. `startTarget` auf `StartGroup` vorhanden. |
| `T4: Schussergebnisse einer Scorekarte erfassen und Punkte berechnen` | `ScoreCard`, `ShotResult`, `Registration`, `Round`, `TargetStation`, `Official` | `ScoreCard.registrationId → Registration.registrationId`, `ScoreCard.roundId → Round.roundId`, `ScoreCard.officialId → Official.officialId`, `ShotResult.scoreCardId → ScoreCard.scoreCardId`, `ShotResult.(rangeId, targetNumber) → TargetStation.(rangeId, targetNumber)` | `scoreCardId`, `arrowNumber`, `hitZone`, `targetNumber`, `roundType`, `targetGroup`, `rangeId` | **Partial** | **Gap:** Kein direkter FK-Pfad von `ScoreCard` zu `Range`. `ShotResult.rangeId` muss über 4 Joins ermittelt werden: `ScoreCard → Registration → StartGroupMember → StartGroup → Range`. → **Iteration erforderlich: `rangeId` als FK in `ScoreCard` ergänzen.** |
| `T5: Tagesergebnisse und Gesamtrangliste anzeigen` | `TournamentResult`, `Registration`, `CompetitionCategory`, `Participant`, `Nation`, `ScoreCard` | `TournamentResult.registrationId → Registration.registrationId`, `Registration.categoryId → CompetitionCategory.categoryId`, `Registration.participantId → Participant.participantId`, `Participant.nationCode → Nation.nationCode`, `ScoreCard.registrationId → Registration.registrationId` | `resultId`, `totalPoints` (derived), `rankPosition` (derived), `tieBreakStatus`, `style`, `division`, `classLevel`, `firstName`, `lastName`, `nationCode`, `nationName` | Full | Fully supported. Abgeleitete Attribute (`totalPoints`, `rankPosition`) werden per SUM/RANK-Query berechnet. |
| `T6: Tie-Break-Shoot-off erfassen und Gewinner bestimmen` | `TieBreak`, `TieBreakParticipant`, `ShotResult`, `TargetStation`, `Registration`, `TournamentResult` | `TieBreakParticipant.tieBreakId → TieBreak.tieBreakId`, `TieBreakParticipant.registrationId → Registration.registrationId`, `ShotResult.tieBreakId → TieBreak.tieBreakId`, `ShotResult.(rangeId, targetNumber) → TargetStation.(rangeId, targetNumber)`, `TournamentResult.registrationId → Registration.registrationId` | `tieBreakId`, `tieBreakRound`, `hitZone`, `pointValue` (derived), `targetGroup`, `tieBreakStatus` | Full | Fully supported. Optionaler FK `ShotResult.tieBreakId` und Brückenrelation `TieBreakParticipant` decken Workflow vollständig ab. |
| `T7: Protest dokumentieren und Offiziellen zuordnen` | `Protest`, `Official`, `Registration` | `Protest.officialId → Official.officialId`, `Protest.registrationId → Registration.registrationId` | `protestId`, `protestDate`, `protestDescription`, `protestDecision`, `officialId`, `firstName`, `lastName`, `officialFunction` | Full | Fully supported. Keine Lücken. |
| `T8: Ergebnisliste exportieren (IFAA-Format)` | `TournamentResult`, `Registration`, `CompetitionCategory`, `Participant`, `Nation`, `ScoreCard`, `Round`, `Event` | `TournamentResult.registrationId → Registration.registrationId`, `Registration.participantId → Participant.participantId`, `Registration.categoryId → CompetitionCategory.categoryId`, `Registration.eventId → Event.eventId`, `Participant.nationCode → Nation.nationCode`, `ScoreCard.registrationId → Registration.registrationId`, `ScoreCard.roundId → Round.roundId`, `Round.eventId → Event.eventId` | `firstName`, `lastName`, `nationCode`, `nationName`, `style`, `division`, `classLevel`, `totalPoints` (derived), `rankPosition` (derived), `roundTotal` (derived), `roundNumber`, `roundType`, `name` | Full | Fully supported. Export über TournamentResult mit JOINs über Registration → Participant → Nation und Registration → CompetitionCategory. |

*Transaction validation matrix – initiales logisches Datenmodell*

---

## Transaction-to-Relation Cross-Reference Matrix

Zusätzlich zur Validierungsmatrix zeigt die folgende Kreuzreferenz-Matrix,
welche Relationen von welchen Transaktionen verwendet werden (x = benötigt).

| Transaction | Event | Round | Range | TargetStation | Participant | Nation | Club | Official | CompCategory | Registration | StartGroup | ScoreCard | ShotResult | TournResult | TieBreak | Protest | RoundRange | StartGroupMember | TieBreakParticipant |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| T1: Teilnehmer anlegen | x | – | – | – | x | x | x | – | x | x | – | – | – | – | – | – | – | – | – |
| T2: Klassifizierung prüfen | – | – | – | – | x | – | – | – | x | x | – | – | – | – | – | – | – | – | – |
| T3: Startgruppen erstellen | – | x | x | x | – | – | – | – | – | x | x | – | – | – | – | – | x | x | – |
| T4: Scorekarte erfassen | – | x | – | x | – | – | – | x | – | x | – | x | x | – | – | – | – | – | – |
| T5: Rangliste anzeigen | – | – | – | – | x | x | – | – | x | x | – | x | – | x | – | – | – | – | – |
| T6: Tie-Break erfassen | – | – | – | x | – | – | – | – | – | x | – | – | x | x | x | – | – | – | x |
| T7: Protest dokumentieren | – | – | – | – | – | – | – | x | – | x | – | – | – | – | – | x | – | – | – |
| T8: Ergebnisliste export. | x | x | – | – | x | x | – | – | x | x | – | x | – | x | – | – | – | – | – |

*Transaction-to-Relation Cross-Reference Matrix*

---

## Iteration: Initiales → Revidiertes Logisches Datenmodell

### Identifizierte Lücke

| # | Lücke | Transaktion | Betroffene Relation | Schweregrad |
|---|---|---|---|---|
| 1 | `ScoreCard` enthält keinen direkten FK auf `Range` – `rangeId` für `ShotResult`-Inserts muss über 4 Joins ermittelt werden (`ScoreCard → Registration → StartGroupMember → StartGroup → Range`) | T4 | `ScoreCard`, `ShotResult` | Medium |

### Modell-Update: `ScoreCard` um `rangeId` erweitern

**Revision:** `rangeId` (FK → `Range`) wird als redundanter Fremdschlüssel in `ScoreCard` aufgenommen.

```text
-- VORHER (initiales Modell):
ScoreCard(scoreCardId, registrationId→Registration, roundId→Round,
          officialId→Official [NULL])

-- NACHHER (revidiertes Modell):
ScoreCard(scoreCardId, registrationId→Registration, roundId→Round,
          officialId→Official [NULL], rangeId→Range)
```

**Begründung:**

- T4 ist die **volumenintensivste** Transaktion (~4.800 ScoreCards × 28–84 ShotResults → bis zu 201.600 Inserts).
- `ShotResult.rangeId` muss bei jedem Insert befüllt werden (FK auf `TargetStation`).
- Ohne `ScoreCard.rangeId` wäre ein 4-facher Join nötig – unpraktisch für Massenerfassung.
- **Kontrollierte Denormalisierung:** `rangeId` in `ScoreCard` wird bei Insert einmalig abgeleitet (Write-once).
- **Normalisierungsverlust:** minimal – `scoreCardId → rangeId` gilt de facto, da jede ScoreCard einer Startgruppe (und damit einer Range) zugeordnet ist.

---

## Transaction Validation Matrix – Revidiertes Logisches Datenmodell

| Transaction | Relation(s) used | Join path / FK path | Key attributes needed | Support status | Notes / required model update |
|---|---|---|---|---|---|
| `T1: Teilnehmer anlegen und Stil/Div/Class zuweisen` | `Participant`, `Registration`, `CompetitionCategory`, `Nation`, `Club`, `Event` | `Registration.participantId → Participant.participantId`, `Registration.eventId → Event.eventId`, `Registration.categoryId → CompetitionCategory.categoryId`, `Participant.nationCode → Nation.nationCode`, `Participant.clubId → Club.clubId` | `participantId`, `firstName`, `lastName`, `birthDate`, `nationCode`, `clubId`, `style`, `division`, `classLevel`, `registrationId`, `entryFeeStatus`, `equipmentStatus` | Full | Keine Änderung. |
| `T2: Klassifizierungskarte prüfen und Startzulassung erteilen` | `Registration`, `Participant`, `CompetitionCategory` | `Registration.participantId → Participant.participantId`, `Registration.categoryId → CompetitionCategory.categoryId` | `registrationId`, `classificationVerified`, `classificationDate`, `entryFeeStatus`, `equipmentStatus`, `style`, `division`, `classLevel` | Full | Keine Änderung. |
| `T3: Startgruppen erstellen und Schützen auf Ranges/Targets zuweisen` | `StartGroup`, `StartGroupMember`, `Registration`, `Round`, `Range`, `TargetStation`, `RoundRange` | `StartGroup.roundId → Round.roundId`, `StartGroup.rangeId → Range.rangeId`, `StartGroupMember.groupId → StartGroup.groupId`, `StartGroupMember.registrationId → Registration.registrationId`, `RoundRange.roundId → Round.roundId`, `RoundRange.rangeId → Range.rangeId` | `groupId`, `groupNumber`, `startTarget`, `roundId`, `roundDate`, `roundType`, `rangeId`, `rangeName`, `targetNumber` | Full | Keine Änderung. |
| `T4: Schussergebnisse einer Scorekarte erfassen und Punkte berechnen` | `ScoreCard`, `ShotResult`, `Registration`, `Round`, `TargetStation`, `Official` | `ScoreCard.registrationId → Registration.registrationId`, `ScoreCard.roundId → Round.roundId`, `ScoreCard.officialId → Official.officialId`, **`ScoreCard.rangeId → Range.rangeId` (NEU)**, `ShotResult.scoreCardId → ScoreCard.scoreCardId`, `ShotResult.(rangeId, targetNumber) → TargetStation.(rangeId, targetNumber)` | `scoreCardId`, `rangeId` **(NEU)**, `arrowNumber`, `hitZone`, `targetNumber`, `roundType`, `targetGroup` | **Full** | **Zuvor Partial → jetzt Full.** `rangeId` wird direkt aus `ScoreCard` übernommen, kein 4-facher Join mehr nötig. |
| `T5: Tagesergebnisse und Gesamtrangliste anzeigen` | `TournamentResult`, `Registration`, `CompetitionCategory`, `Participant`, `Nation`, `ScoreCard` | `TournamentResult.registrationId → Registration.registrationId`, `Registration.categoryId → CompetitionCategory.categoryId`, `Registration.participantId → Participant.participantId`, `Participant.nationCode → Nation.nationCode`, `ScoreCard.registrationId → Registration.registrationId` | `resultId`, `totalPoints` (derived), `rankPosition` (derived), `tieBreakStatus`, `style`, `division`, `classLevel`, `firstName`, `lastName`, `nationCode`, `nationName` | Full | Keine Änderung. |
| `T6: Tie-Break-Shoot-off erfassen und Gewinner bestimmen` | `TieBreak`, `TieBreakParticipant`, `ShotResult`, `TargetStation`, `Registration`, `TournamentResult` | `TieBreakParticipant.tieBreakId → TieBreak.tieBreakId`, `TieBreakParticipant.registrationId → Registration.registrationId`, `ShotResult.tieBreakId → TieBreak.tieBreakId`, `ShotResult.(rangeId, targetNumber) → TargetStation.(rangeId, targetNumber)`, `TournamentResult.registrationId → Registration.registrationId` | `tieBreakId`, `tieBreakRound`, `hitZone`, `pointValue` (derived), `targetGroup`, `tieBreakStatus` | Full | Keine Änderung. |
| `T7: Protest dokumentieren und Offiziellen zuordnen` | `Protest`, `Official`, `Registration` | `Protest.officialId → Official.officialId`, `Protest.registrationId → Registration.registrationId` | `protestId`, `protestDate`, `protestDescription`, `protestDecision`, `officialId`, `firstName`, `lastName`, `officialFunction` | Full | Keine Änderung. |
| `T8: Ergebnisliste exportieren (IFAA-Format)` | `TournamentResult`, `Registration`, `CompetitionCategory`, `Participant`, `Nation`, `ScoreCard`, `Round`, `Event` | `TournamentResult.registrationId → Registration.registrationId`, `Registration.participantId → Participant.participantId`, `Registration.categoryId → CompetitionCategory.categoryId`, `Registration.eventId → Event.eventId`, `Participant.nationCode → Nation.nationCode`, `ScoreCard.registrationId → Registration.registrationId`, `ScoreCard.roundId → Round.roundId`, `Round.eventId → Event.eventId` | `firstName`, `lastName`, `nationCode`, `nationName`, `style`, `division`, `classLevel`, `totalPoints` (derived), `rankPosition` (derived), `roundTotal` (derived), `roundNumber`, `roundType`, `name` | Full | Keine Änderung. |

*Transaction validation matrix – revidiertes logisches Datenmodell*

---

## Vergleich: Initiales vs. Revidiertes Modell

| Transaction | Status (Initial) | Status (Revidiert) | Änderung |
|---|---|---|---|
| T1: Teilnehmer anlegen | Full | Full | – |
| T2: Klassifizierung prüfen | Full | Full | – |
| T3: Startgruppen erstellen | Full | Full | – |
| T4: Scorekarte erfassen | **Partial** | **Full** | `rangeId` in `ScoreCard` ergänzt |
| T5: Rangliste anzeigen | Full | Full | – |
| T6: Tie-Break erfassen | Full | Full | – |
| T7: Protest dokumentieren | Full | Full | – |
| T8: Ergebnisliste exportieren | Full | Full | – |

**Ergebnis:** Nach einer Iteration (Hinzufügen von `rangeId → Range` als FK in `ScoreCard`) werden alle 8 Transaktionen durch das revidierte logische Datenmodell **vollständig unterstützt** (Full).

---

## Änderungsprotokoll: Initial → Revidiert

| # | Relation | Änderung | Begründung | Auslöser |
|---|---|---|---|---|
| 1 | `ScoreCard` | `rangeId → Range` als FK ergänzt | Direkter Zugriff auf `rangeId` für ShotResult-Inserts; vermeidet 4-fachen Join | T4 (Partial → Full) |

*Änderungsprotokoll – logisches Datenmodell Iteration 1*
