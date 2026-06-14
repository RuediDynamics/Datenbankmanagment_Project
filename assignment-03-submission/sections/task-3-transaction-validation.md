# Task 3: Validate Logical Data Model Against Transactions


## Transaction-to-Relation Matrix: Initiales Logisches Datenmodell

Die folgende Matrix bildet jede Transaktion (Zeilen) auf die im initialen
logischen Modell vorhandenen Relationen und FK-Pfade (Spalten) ab. Ein **x**
kennzeichnet, dass die Relation oder der FK-Pfad für die Transaktion benötigt
wird.

### Legende

| Symbol | Bedeutung |
|---|---|
| **x** | Relation / FK-Pfad wird von dieser Transaktion verwendet |
| – | nicht benötigt |
| ⚠ | benötigt, aber im initialen Modell nicht / unvollständig vorhanden |

---

### Matrix: Transaktionen × Basisrelationen

| Transaction | Event | Round | Range | TargetStation | Participant | Nation | Club | Official | CompCategory | Registration | StartGroup | ScoreCard | ShotResult | TournResult | TieBreak | Protest |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **T1:** Teilnehmer anlegen | x | – | – | – | x | x | x | – | x | x | – | – | – | – | – | – |
| **T2:** Klassifizierung prüfen | x | – | – | – | x | – | – | – | x | x | – | – | – | – | – | – |
| **T3:** Startgruppen erstellen | – | x | x | x | – | – | – | – | – | x | x | – | – | – | – | – |
| **T4:** Scorekarte erfassen | – | x | – | x | – | – | – | x | – | x | – | x | x | – | – | – |
| **T5:** Rangliste anzeigen | – | – | – | – | x | x | – | – | x | x | – | x | – | x | – | – |
| **T6:** Tie-Break erfassen | – | – | – | x | – | – | – | – | – | x | – | – | x | x | x | – |
| **T7:** Protest dokumentieren | – | – | – | – | – | – | – | x | – | x | – | – | – | – | – | x |
| **T8:** Ergebnisliste export. | x | x | – | – | x | x | – | – | x | x | – | x | – | x | – | – |

*Tabelle 1: Transaction-to-Relation Matrix – Basisrelationen (initiales Modell)*

---

### Matrix: Transaktionen × Brücken-/Assoziationsrelationen

| Transaction | RoundRange | StartGroupMember | TieBreakParticipant | TargetDistance |
|---|:---:|:---:|:---:|:---:|
| **T1:** Teilnehmer anlegen | – | – | – | – |
| **T2:** Klassifizierung prüfen | – | – | – | – |
| **T3:** Startgruppen erstellen | x | x | – | – |
| **T4:** Scorekarte erfassen | – | – | – | – |
| **T5:** Rangliste anzeigen | – | – | – | – |
| **T6:** Tie-Break erfassen | – | – | x | – |
| **T7:** Protest dokumentieren | – | – | – | – |
| **T8:** Ergebnisliste export. | – | – | – | – |

*Tabelle 2: Transaction-to-Relation Matrix – Brücken-/Assoziationsrelationen (initiales Modell)*

---

### Matrix: Transaktionen × FK-Pfade

| Transaction | Reg→Part | Reg→Event | Reg→CC | Part→Nation | Part→Club | SG→Round | SG→Range | SGM→SG | SGM→Reg | SC→Reg | SC→Round | SC→Off | SR→SC | SR→TS | SR→TB | TR→Reg | TBP→TB | TBP→Reg | Prot→Off | Prot→Reg | Round→Event | RR→Round | RR→Range |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **T1** | x | x | x | x | x | – | – | – | – | – | – | – | – | – | – | – | – | – | – | – | – | – | – |
| **T2** | x | – | x | – | – | – | – | – | – | – | – | – | – | – | – | – | – | – | – | – | – | – | – |
| **T3** | – | – | – | – | – | x | x | x | x | – | – | – | – | – | – | – | – | – | – | – | – | x | x |
| **T4** | – | – | – | – | – | – | – | – | – | x | x | x | x | x | – | – | – | – | – | – | – | – | – |
| **T5** | x | – | x | x | – | – | – | – | – | x | – | – | – | – | – | x | – | – | – | – | – | – | – |
| **T6** | – | – | – | – | – | – | – | – | – | – | – | – | x | x | x | x | x | x | – | – | – | – | – |
| **T7** | – | – | – | – | – | – | – | – | – | – | – | – | – | – | – | – | – | – | x | x | – | – | – |
| **T8** | x | x | x | x | – | – | – | – | – | x | x | – | – | – | – | x | – | – | – | – | x | – | – |

*Tabelle 3: Transaction-to-Relation Matrix – FK-Pfade (initiales Modell)*

---

## Detailvalidierung je Transaktion

Für jede Transaktion wird der vollständige Join-Pfad, die benötigten Attribute
und der Unterstützungsstatus dokumentiert.

---

### T1: Teilnehmer anlegen und einer Stil/Divisions/Klassen-Kombination zuweisen

| Kriterium | Details |
|---|---|
| **Typ** | Operational – Create/Update |
| **Primäre Rolle** | Ergebnisbeauftragte |
| **Benötigte Relationen** | `Participant`, `Registration`, `CompetitionCategory`, `Nation`, `Club`, `Event` |
| **Join- / FK-Pfade** | `Registration.participantId → Participant`, `Registration.eventId → Event`, `Registration.categoryId → CompetitionCategory`, `Participant.nationCode → Nation`, `Participant.clubId → Club` |
| **Benötigte Attribute** | `Participant`: participantId, firstName, lastName, birthDate; `Nation`: nationCode; `Club`: clubId, clubName; `CompetitionCategory`: style, division, classLevel; `Registration`: registrationId, entryFeeStatus, equipmentStatus |
| **Unterstützungsstatus** | ✅ **Fully supported** |
| **Erforderliche Updates** | Keine |

---

### T2: Klassifizierungskarte prüfen und Startzulassung erteilen

| Kriterium | Details |
|---|---|
| **Typ** | Operational – Read/Update |
| **Primäre Rolle** | Ergebnisbeauftragte |
| **Benötigte Relationen** | `Registration`, `Participant`, `CompetitionCategory`, `Event` |
| **Join- / FK-Pfade** | `Registration.participantId → Participant`, `Registration.categoryId → CompetitionCategory` |
| **Benötigte Attribute** | `Registration`: registrationId, classificationVerified, classificationDate, entryFeeStatus, equipmentStatus; `CompetitionCategory`: style, division, classLevel |
| **Unterstützungsstatus** | ✅ **Fully supported** |
| **Erforderliche Updates** | Keine – Attribute `classificationVerified` und `classificationDate` wurden bereits aus Assignment 02 Gap Analysis in das initiale logische Modell übernommen. |

---

### T3: Startgruppen für eine Runde erstellen und Schützen auf Ranges/Targets zuweisen

| Kriterium | Details |
|---|---|
| **Typ** | Operational – Create/Update |
| **Primäre Rolle** | Turnierdirektor |
| **Benötigte Relationen** | `StartGroup`, `StartGroupMember`, `Registration`, `Round`, `Range`, `TargetStation`, `RoundRange` |
| **Join- / FK-Pfade** | `StartGroup.roundId → Round`, `StartGroup.rangeId → Range`, `StartGroupMember.groupId → StartGroup`, `StartGroupMember.registrationId → Registration`, `RoundRange.roundId → Round`, `RoundRange.rangeId → Range` |
| **Benötigte Attribute** | `StartGroup`: groupId, groupNumber, startTarget; `Round`: roundId, roundDate, roundType; `Range`: rangeId, rangeName; `TargetStation`: targetNumber |
| **Unterstützungsstatus** | ✅ **Fully supported** |
| **Erforderliche Updates** | Keine – `StartGroupMember` als Brückenrelation löst die *:*-Beziehung korrekt auf. `startTarget` ist auf `StartGroup` vorhanden. |

---

### T4: Schussergebnisse einer Scorekarte (28 Ziele × Pfeilanzahl) erfassen und Punkte berechnen

| Kriterium | Details |
|---|---|
| **Typ** | Operational – Create |
| **Primäre Rolle** | Ergebnisbeauftragte |
| **Benötigte Relationen** | `ScoreCard`, `ShotResult`, `Registration`, `Round`, `TargetStation`, `Official` |
| **Join- / FK-Pfade** | `ScoreCard.registrationId → Registration`, `ScoreCard.roundId → Round`, `ScoreCard.officialId → Official`, `ShotResult.scoreCardId → ScoreCard`, `ShotResult.(rangeId, targetNumber) → TargetStation` |
| **Benötigte Attribute** | `ScoreCard`: scoreCardId; `ShotResult`: arrowNumber, hitZone, targetNumber; `Round`: roundType (für Punktwertberechnung); `TargetStation`: targetGroup |
| **Unterstützungsstatus** | ⚠ **Partially supported** |
| **Erforderliche Updates** | Der **Join-Pfad von `ScoreCard` zur `rangeId`** für die korrekte Befüllung von `ShotResult.rangeId` ist nicht direkt vorhanden. Aktuell muss der Pfad über `ScoreCard → Registration → StartGroupMember → StartGroup → Range` genommen werden (4 Joins). Eine Denormalisierung durch Aufnahme von `rangeId` als redundanten FK in `ScoreCard` würde den Insert-Workflow deutlich vereinfachen. → **Iteration erforderlich.** |

---

### T5: Tagesergebnisse und Gesamtrangliste je Stil/Division/Klasse anzeigen

| Kriterium | Details |
|---|---|
| **Typ** | Managerial – Read (calculated) |
| **Primäre Rolle** | Alle drei Rollen |
| **Benötigte Relationen** | `TournamentResult`, `Registration`, `CompetitionCategory`, `Participant`, `Nation`, `ScoreCard` |
| **Join- / FK-Pfade** | `TournamentResult.registrationId → Registration`, `Registration.categoryId → CompetitionCategory`, `Registration.participantId → Participant`, `Participant.nationCode → Nation`, `ScoreCard.registrationId → Registration` |
| **Benötigte Attribute** | `TournamentResult`: resultId, totalPoints (derived), rankPosition (derived), tieBreakStatus; `CompetitionCategory`: style, division, classLevel; `Participant`: firstName, lastName; `Nation`: nationCode, nationName |
| **Unterstützungsstatus** | ✅ **Fully supported** |
| **Erforderliche Updates** | Keine – abgeleitete Attribute (`totalPoints`, `rankPosition`) werden per Query berechnet (SUM/RANK). |

---

### T6: Tie-Break-Shoot-off erfassen und Gewinner bestimmen

| Kriterium | Details |
|---|---|
| **Typ** | Operational – Create/Read |
| **Primäre Rolle** | Ergebnisbeauftragte |
| **Benötigte Relationen** | `TieBreak`, `TieBreakParticipant`, `ShotResult`, `TargetStation`, `Registration`, `TournamentResult` |
| **Join- / FK-Pfade** | `TieBreakParticipant.tieBreakId → TieBreak`, `TieBreakParticipant.registrationId → Registration`, `ShotResult.tieBreakId → TieBreak`, `ShotResult.(rangeId, targetNumber) → TargetStation`, `TournamentResult.registrationId → Registration` |
| **Benötigte Attribute** | `TieBreak`: tieBreakId, tieBreakRound; `ShotResult`: hitZone, pointValue (derived); `TargetStation`: targetGroup; `TournamentResult`: tieBreakStatus |
| **Unterstützungsstatus** | ✅ **Fully supported** |
| **Erforderliche Updates** | Keine – der optionale FK `ShotResult.tieBreakId → TieBreak` und die Brückenrelation `TieBreakParticipant` decken den Workflow vollständig ab. |

---

### T7: Protest / Regelentscheid dokumentieren und einem Offiziellen zuordnen

| Kriterium | Details |
|---|---|
| **Typ** | Operational – Create |
| **Primäre Rolle** | Turnierdirektor |
| **Benötigte Relationen** | `Protest`, `Official`, `Registration` |
| **Join- / FK-Pfade** | `Protest.officialId → Official`, `Protest.registrationId → Registration` |
| **Benötigte Attribute** | `Protest`: protestId, protestDate, protestDescription, protestDecision; `Official`: officialId, firstName, lastName, officialFunction |
| **Unterstützungsstatus** | ✅ **Fully supported** |
| **Erforderliche Updates** | Keine |

---

### T8: Offizielle Ergebnisliste (nach IFAA-Format) für eine Runde oder das Gesamtturnier exportieren

| Kriterium | Details |
|---|---|
| **Typ** | Managerial – Read/Report |
| **Primäre Rolle** | Turnierdirektor + Ergebnisbeauftragte |
| **Benötigte Relationen** | `TournamentResult`, `Registration`, `CompetitionCategory`, `Participant`, `Nation`, `ScoreCard`, `Round`, `Event` |
| **Join- / FK-Pfade** | `TournamentResult.registrationId → Registration`, `Registration.participantId → Participant`, `Registration.categoryId → CompetitionCategory`, `Registration.eventId → Event`, `Participant.nationCode → Nation`, `ScoreCard.registrationId → Registration`, `ScoreCard.roundId → Round`, `Round.eventId → Event` |
| **Benötigte Attribute** | `Participant`: firstName, lastName; `Nation`: nationCode, nationName; `CompetitionCategory`: style, division, classLevel; `TournamentResult`: totalPoints (derived), rankPosition (derived); `ScoreCard`: roundTotal (derived); `Round`: roundNumber, roundType; `Event`: name |
| **Unterstützungsstatus** | ✅ **Fully supported** |
| **Erforderliche Updates** | Keine |

---

## Zusammenfassung: Unterstützungsstatus (Initiales Modell)

| Transaction | Status | Anmerkung |
|---|---|---|
| T1: Teilnehmer anlegen | ✅ Fully supported | – |
| T2: Klassifizierung prüfen | ✅ Fully supported | Gaps aus A02 bereits übernommen |
| T3: Startgruppen erstellen | ✅ Fully supported | Brückenrelation `StartGroupMember` bestätigt |
| T4: Scorekarte erfassen | ⚠ **Partially supported** | `rangeId`-Pfad für ShotResult-Insert erfordert 4 Joins; Denormalisierung empfohlen |
| T5: Rangliste anzeigen | ✅ Fully supported | Derived attributes per Query |
| T6: Tie-Break erfassen | ✅ Fully supported | – |
| T7: Protest dokumentieren | ✅ Fully supported | – |
| T8: Ergebnisliste exportieren | ✅ Fully supported | – |

*Tabelle 4: Unterstützungsstatus – Initiales logisches Datenmodell*

**Ergebnis:** 7 von 8 Transaktionen sind **fully supported**. Transaktion T4
ist **partially supported** – der Insert-Workflow für `ShotResult` erfordert
einen indirekten 4-Join-Pfad zur Bestimmung der `rangeId`. Eine gezielte
Denormalisierung behebt dieses Problem.

---

## Iteration: Initiales → Revidiertes Logisches Datenmodell

### Identifizierte Lücke

| # | Lücke | Transaktion | Betroffene Relation | Schweregrad |
|---|---|---|---|---|
| 1 | `ScoreCard` enthält keinen direkten FK auf `Range` – der `rangeId`-Wert für `ShotResult`-Inserts muss über 4 Joins (`ScoreCard → Registration → StartGroupMember → StartGroup → Range`) ermittelt werden | T4 | `ScoreCard`, `ShotResult` | Medium |

*Tabelle 5: Identifizierte Lücke im initialen logischen Datenmodell*

### Modell-Update: `ScoreCard` um `rangeId` erweitern

**Revision:** Das Attribut `rangeId` (FK → `Range`) wird als **redundanter
Fremdschlüssel** in die Relation `ScoreCard` aufgenommen.

**Revidiertes Schema für `ScoreCard`:**

```text
ScoreCard(scoreCardId, registrationId→Registration, roundId→Round,
          officialId→Official [NULL], rangeId→Range)
```

**Begründung:**

- T4 (Scorekarte erfassen) ist die **volumenintensivste** Transaktion
  (~4.800 ScoreCards mit je 28–84 ShotResults → bis zu 201.600 Inserts).
- Bei jedem `ShotResult`-Insert muss `rangeId` befüllt werden, um den FK
  `(rangeId, targetNumber) → TargetStation` zu erfüllen.
- Ohne den redundanten FK auf `ScoreCard` wäre ein 4-facher Join nötig
  (ScoreCard → Registration → StartGroupMember → StartGroup → Range), um
  die Range zu bestimmen. Das ist für die Massenerfassung unpraktisch.
- Die Denormalisierung ist **kontrolliert**: `rangeId` in `ScoreCard` kann aus
  dem eindeutigen Pfad `Registration → StartGroupMember → StartGroup.rangeId`
  zur Insert-Zeit abgeleitet und danach nicht mehr geändert werden (Write-once).
- **Normalisierungsverlust:** minimal – die funktionale Abhängigkeit
  `scoreCardId → rangeId` gilt de facto, da jede ScoreCard genau einer
  Startgruppe (und damit einer Range) zugeordnet ist.

**Trade-off:** Redundanz von `rangeId` über `ScoreCard` und `StartGroup`
vs. signifikante Performance- und Usability-Verbesserung beim Insert-Workflow.

---

## Re-Validierung: Revidiertes Logisches Datenmodell

Nach Aufnahme von `rangeId` in `ScoreCard` wird T4 erneut validiert:

### T4 (revidiert): Schussergebnisse erfassen

| Kriterium | Details |
|---|---|
| **Benötigte Relationen** | `ScoreCard`, `ShotResult`, `Registration`, `Round`, `TargetStation`, `Official` |
| **Join- / FK-Pfade (NEU)** | `ScoreCard.registrationId → Registration`, `ScoreCard.roundId → Round`, `ScoreCard.officialId → Official`, `ScoreCard.rangeId → Range` **(NEU)**, `ShotResult.scoreCardId → ScoreCard`, `ShotResult.(rangeId, targetNumber) → TargetStation` |
| **Benötigte Attribute** | `ScoreCard`: scoreCardId, **rangeId (NEU)**; `ShotResult`: arrowNumber, hitZone, targetNumber; `Round`: roundType |
| **Unterstützungsstatus** | ✅ **Fully supported** |
| **Verbesserung** | `rangeId` wird direkt aus `ScoreCard` übernommen – kein Multi-Join mehr nötig. |

---

## Revidierte Gesamtmatrix (nach Iteration)

| Transaction | Status (Initial) | Status (Revidiert) | Änderung |
|---|---|---|---|
| T1: Teilnehmer anlegen | ✅ Fully supported | ✅ Fully supported | – |
| T2: Klassifizierung prüfen | ✅ Fully supported | ✅ Fully supported | – |
| T3: Startgruppen erstellen | ✅ Fully supported | ✅ Fully supported | – |
| T4: Scorekarte erfassen | ⚠ Partially supported | ✅ **Fully supported** | `rangeId` in `ScoreCard` ergänzt |
| T5: Rangliste anzeigen | ✅ Fully supported | ✅ Fully supported | – |
| T6: Tie-Break erfassen | ✅ Fully supported | ✅ Fully supported | – |
| T7: Protest dokumentieren | ✅ Fully supported | ✅ Fully supported | – |
| T8: Ergebnisliste exportieren | ✅ Fully supported | ✅ Fully supported | – |

*Tabelle 6: Vergleich Unterstützungsstatus: initiales vs. revidiertes logisches Datenmodell*

**Ergebnis nach Iteration:** Alle 8 Transaktionen werden durch das
**revidierte logische Datenmodell** vollständig unterstützt (✅ Fully supported).

---

## Änderungsprotokoll: Initial → Revidiert

| # | Relation | Änderung | Begründung | Auslöser |
|---|---|---|---|---|
| 1 | `ScoreCard` | `rangeId → Range` als FK ergänzt | Direkter Zugriff auf `rangeId` für ShotResult-Inserts; vermeidet 4-fachen Join | T4 (partially supported) |

*Tabelle 7: Änderungsprotokoll – logisches Datenmodell Iteration 1*

**Revidiertes Gesamtschema (nur Änderung):**

```text
-- VORHER (initiales Modell):
ScoreCard(scoreCardId, registrationId→Registration, roundId→Round,
          officialId→Official [NULL])

-- NACHHER (revidiertes Modell):
ScoreCard(scoreCardId, registrationId→Registration, roundId→Round,
          officialId→Official [NULL], rangeId→Range)
```

---


