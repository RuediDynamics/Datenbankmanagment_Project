## Task 2: Validate Relations Using Normalization {#sec-task2-normalization}

### Durchgearbeitetes Beispiel: von 1NF zu 3NF {#sec-t2-worked}

Als Worked Example dient eine **naive, flache** Erfassung der Schussergebnisse,
wie sie aus Transaktion T4 („Scorekarte erfassen") bei unsauberem Entwurf
entstehen könnte. Daran werden partielle (2NF) und transitive (3NF) Abhängigkeiten
sichtbar gemacht und beseitigt.

#### Ausgangsrelation (unnormalisiert, nur 1NF) {#sec-t2-worked-0}

```text
ScoreEntry(registrationId, roundId, targetNumber, arrowNumber,
           participantId, firstName, lastName, nationCode, nationName,
           clubId, clubName, roundNumber, roundType, roundDate,
           hitZone, pointValue)
```

**Primärschlüssel (zusammengesetzt):** `(registrationId, roundId, targetNumber,
arrowNumber)` – identifiziert das Ergebnis genau eines Pfeils.

**Relevante funktionale Abhängigkeiten:**

| # | Funktionale Abhängigkeit | Art |
|---|---|---|
| FD1 | `registrationId → participantId` | partiell (Teil des PK) |
| FD2 | `participantId → firstName, lastName, nationCode, clubId` | transitiv |
| FD3 | `nationCode → nationName` | transitiv |
| FD4 | `clubId → clubName` | transitiv |
| FD5 | `roundId → roundNumber, roundType, roundDate` | partiell (Teil des PK) |
| FD6 | `{registrationId, roundId, targetNumber, arrowNumber} → hitZone` | voll |
| FD7 | `{roundType, hitZone, arrowNumber} → pointValue` | abgeleitet (IFAA-Scoring) |

: Funktionale Abhängigkeiten der Ausgangsrelation `ScoreEntry` {#tbl-t2-fd-scoreentry}

`ScoreEntry` ist in **1NF** (alle Werte atomar, keine Wiederholungsgruppen), aber
nicht in 2NF.

#### Schritt 1NF → 2NF: partielle Abhängigkeiten entfernen {#sec-t2-worked-2nf}

FD1 und FD5 sind partielle Abhängigkeiten: `participantId` (und die daran
hängenden Attribute) bestimmen sich allein aus `registrationId`, die
Rundenattribute allein aus `roundId` – beides **echte Teilmengen** des
Schlüssels. Auslagerung in Relationen, die auf der jeweiligen Determinante
schlüsseln:

```text
R_Reg(registrationId, participantId, firstName, lastName,
      nationCode, nationName, clubId, clubName)         -- aus FD1, FD2, FD3, FD4
R_Round(roundId, roundNumber, roundType, roundDate)      -- aus FD5
R_Shot(registrationId, roundId, targetNumber, arrowNumber, hitZone)  -- Restschlüssel + FD6
```

`pointValue` (FD7) ist ein **abgeleiteter** Wert (`roundType` × `hitZone` ×
`arrowNumber` per IFAA-Tabelle) und wird nicht gespeichert; er entfällt aus
`R_Shot`. Damit sind alle drei Relationen in **2NF**.

#### Schritt 2NF → 3NF: transitive Abhängigkeiten entfernen {#sec-t2-worked-3nf}

`R_Reg` enthält transitive Abhängigkeiten über das Nichtschlüsselattribut
`participantId` (FD2) sowie über `nationCode` (FD3) und `clubId` (FD4):
`registrationId → participantId → firstName …`. Auflösung:

```text
Registration(registrationId, participantId)            -- Restmenge (+ A02-Attribute)
Participant(participantId, firstName, lastName, nationCode, clubId, birthDate)
Nation(nationCode, nationName)
Club(clubId, clubName)
```

Endergebnis: `Registration`, `Participant`, `Nation`, `Club`, `Round`,
`ScoreCard`/`ShotResult` – exakt die Relationen aus Task 1. Die Zerlegung ist
**verlustfrei** (jede Determinante ist Schlüssel der ausgelagerten Relation) und
**abhängigkeitserhaltend** (jede FD ist in genau einer Relation rekonstruierbar).
Damit ist die Methodik bestätigt: das in Task 1 abgeleitete Schema ist bereits das
Ergebnis konsequenter 1NF→2NF→3NF-Zerlegung.

### Gesamtanalyse aller Relationen {#sec-t2-allrelations}

Die folgende Tabelle wendet die Normalisierungsprüfung auf **alle 20 Relationen**
an (abgeleitete Attribute weggelassen). Brücken- und Assoziationsrelationen sind
am Ende gelistet.

| Relation | Candidate key(s) | Funktionale Abhängigkeiten | Aktuelle NF | Aktion | Resultierende Relation(en) |
|---|---|---|---|---|---|
| `Event` | `eventId`; `(name, startDate)` | `eventId →` alle; `(name,startDate) →` alle | BCNF | keine | `Event` |
| `Round` | `roundId`; `(eventId, roundNumber)` | `roundId →` alle; `(eventId,roundNumber) →` alle | BCNF | keine | `Round` |
| `Range` | `rangeId`; `rangeName` | `rangeId → officialId, rangeName`; `rangeName →` alle | BCNF | keine | `Range` |
| `TargetStation` | `(rangeId, targetNumber)` | `(rangeId, targetNumber) → targetGroup` | 3NF* | keine (s. @sec-t2-borderline) | `TargetStation` |
| `Nation` | `nationCode`; `nationName` | beide → das jeweils andere | BCNF | keine | `Nation` |
| `Club` | `clubId`; `clubName` | beide → das jeweils andere | BCNF | keine | `Club` |
| `Participant` | `participantId` | `participantId → nationCode, clubId, firstName, lastName, birthDate` | BCNF | keine | `Participant` |
| `Official` | `officialId` | `officialId → firstName, lastName, officialFunction` | BCNF | keine | `Official` |
| `CompetitionCategory` | `categoryId`; `(style, division, classLevel)` | `categoryId →` Tripel; Tripel `→ categoryId` | BCNF | keine | `CompetitionCategory` |
| `Registration` | `registrationId`; `(eventId, participantId)` | `registrationId →` alle; `(eventId,participantId) →` alle | BCNF | keine | `Registration` |
| `StartGroup` | `groupId`; `(roundId, groupNumber)` | `groupId →` alle; `(roundId,groupNumber) →` alle | BCNF | keine | `StartGroup` |
| `ScoreCard` | `scoreCardId`; `(registrationId, roundId)` | `scoreCardId →` alle; `(registrationId,roundId) →` alle | BCNF | keine | `ScoreCard` |
| `ShotResult` *(Task-1-Fassung)* | `(scoreCardId, targetNumber, arrowNumber)` | Schlüssel `→ hitZone, tieBreakId`; **`scoreCardId → rangeId`** | **2NF** | **Dekomponieren** | `ShotResult` ohne `rangeId` (s. @sec-t2-revision) |
| `TournamentResult` | `resultId`; `registrationId` | `resultId →` alle; `registrationId →` alle | BCNF | keine | `TournamentResult` |
| `TieBreak` | `tieBreakId` | `tieBreakId → tieBreakRound` | BCNF | keine | `TieBreak` |
| `Protest` | `protestId` | `protestId →` alle | BCNF | keine | `Protest` |
| `RoundRange` | `(roundId, rangeId)` | nur Schlüssel (All-Key) | BCNF | keine | `RoundRange` |
| `StartGroupMember` | `(groupId, registrationId)` | nur Schlüssel (All-Key) | BCNF | keine | `StartGroupMember` |
| `TieBreakParticipant` | `(tieBreakId, registrationId)` | nur Schlüssel (All-Key) | BCNF | keine | `TieBreakParticipant` |
| `TargetDistance` | `(rangeId, targetNumber, categoryId)` | `(rangeId, targetNumber, categoryId) → maxDistance` | 3NF* | keine (s. @sec-t2-borderline) | `TargetDistance` |

: Normalisierungsanalyse aller Relationen {#tbl-normalization-analysis}

\* Mit Annahme über range-spezifische Konfiguration (siehe @sec-t2-borderline).

### Gefundene Verletzung und Revision: `ShotResult` {#sec-t2-revision}

In Task 1 wurde `rangeId` in `ShotResult` aufgenommen, um den zusammengesetzten
Fremdschlüssel `(rangeId, targetNumber) → TargetStation` (Beziehung `atTarget`)
durchsetzbar zu machen. Die Normalisierungsprüfung deckt dadurch eine
**2NF-Verletzung** auf:

- Schlüssel von `ShotResult`: `(scoreCardId, targetNumber, arrowNumber)`.
- Eine Scorekarte wird in genau einer Runde auf genau einer Range geschossen,
  daher gilt **`scoreCardId → rangeId`**.
- `rangeId` hängt damit nur von `scoreCardId` ab – einer **echten Teilmenge** des
  Primärschlüssels → **partielle Abhängigkeit** → Verstoß gegen 2NF.

**Revision (verlustfrei):** `rangeId` wird aus `ShotResult` entfernt. Die Range
einer Scorekarte ist ohnehin über den bestehenden Pfad
`ScoreCard → StartGroupMember ⋈ StartGroup → Range` ableitbar; eine Speicherung in
`ShotResult` wäre redundant. Die revidierte Relation

```text
ShotResult(scoreCardId, targetNumber, arrowNumber, tieBreakId, hitZone)
```

ist in **3NF** (alle Nichtschlüsselattribute hängen voll vom Schlüssel ab, keine
transitiven Abhängigkeiten).

**Konsequenz für die Beziehung `atTarget`:** Ohne `rangeId` in `ShotResult` ist
kein spalten-lokaler Fremdschlüssel auf `TargetStation(rangeId, targetNumber)`
mehr möglich. Die physische Zielstation wird stattdessen **kontextuell** über den
Range-Pfad der Scorekarte aufgelöst; `targetNumber` bleibt per Domain-Constraint
`[1..28]` abgesichert (Task 4). Sollte projektseitig eine DBMS-erzwungene
referenzielle Integrität auf `TargetStation` zwingend gefordert sein, ist die
Wiederaufnahme von `rangeId` in `ShotResult` als **bewusste, dokumentierte
Denormalisierung** (kontrollierte Redundanz) zu behandeln – nicht als Normalform.
Das revidierte Modell ist @fig-logical-normalized.

![Normalisiertes logisches Datenmodell (≥ 3NF). Änderung ggü. Task 1: `rangeId` aus `ShotResult` entfernt, `atTarget` kontextuell aufgelöst (gestrichelt). PlantUML-Quelle: `assets/diagrams/logical-model-normalized.puml`](../assets/diagrams/logical-model-normalized.svg){#fig-logical-normalized}

### Grenzfälle mit Modellierungsannahme {#sec-t2-borderline}

Zwei Relationen sind nur **unter einer expliziten Annahme** in 3NF; die Annahme
folgt der Behandlung in Assignment 02 (Konfiguration je Range durch den
Turnierdirektor).

**`TargetStation.targetGroup`.** Wäre die Zielgruppe (1–4) global allein durch
`targetNumber` festgelegt (`targetNumber → targetGroup`), läge eine partielle
Abhängigkeit und damit eine 2NF-Verletzung vor; man würde eine Lookup-Relation
`TargetGroupMap(targetNumber, targetGroup)` auslagern. **Annahme:** Die Gruppierung
wird **pro Range** konfiguriert (verschiedene Streckenlayouts), daher gilt
`(rangeId, targetNumber) → targetGroup` voll → **3NF**, keine Zerlegung.

**`TargetDistance.maxDistance`.** Analog könnte `maxDistance` bei identischer
Zielbestückung über alle Ranges allein von `(targetNumber, categoryId)` abhängen.
**Annahme:** Die Zielbestückung (und damit die Distanzklasse) ist
range-spezifisch, also `(rangeId, targetNumber, categoryId) → maxDistance` voll →
**3NF**. Eine spätere Erfassung der Distanz-/Tierklasse je Ziel würde ein neues
Attribut `distanceClass` auf `TargetStation` nahelegen (Future Growth, Task 5).

### Abhängigkeitserhaltung und Verlustfreiheit {#sec-t2-properties}

- **Verlustfreiheit (lossless join):** Bei jeder Zerlegung (Worked Example und
  `ShotResult`-Revision) ist das gemeinsame Attribut der Teilrelationen Schlüssel
  mindestens einer Teilrelation; die Verbund-Operation rekonstruiert das Original
  ohne Geistertupel.
- **Abhängigkeitserhaltung (dependency preservation):** Jede ursprüngliche FD ist
  innerhalb einer der resultierenden Relationen prüfbar; es gehen keine
  Abhängigkeiten verloren, die nur über einen Join prüfbar wären.
- **BCNF-Hinweis:** 17 der 20 Relationen erfüllen sogar BCNF (jede Determinante
  ist Candidate Key). Die drei verbleibenden (`TargetStation`, `TargetDistance`
  unter Annahme; `ShotResult` nach Revision) sind in 3NF, was der
  Assignment-Vorgabe genügt.