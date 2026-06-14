# Constraint Specification Table

**Task 4: Integrity Constraints – Complete Specification**

---

## C1–C20: Erforderliche Daten (NULL/NOT-NULL Intent)

| Constraint ID | Type | Relation / Attribute(s) | Constraint rule | Rationale / Source |
|---|---|---|---|---|
| C1 | Domain (Required) | `Event.name` | NOT NULL | Event-Name ist eindeutiges Identifier-Kandidat (Assignment 02). Verweigerung unbenannter Events. |
| C2 | Domain (Required) | `Event.startDate` | NOT NULL | Jedes Turnier hat ein definiertes Startdatum (Geschäftsanforderung T8: Ergebnisliste exportieren). |
| C3 | Domain (Required) | `Event.endDate` | NOT NULL | Jedes Turnier hat ein Enddatum; benötigt für Ranglisten-Cutoff. |
| C4 | Domain (Required) | `Round.roundNumber` | NOT NULL | Jede Runde braucht Rundenindex (T3: Startgruppen je Runde, T5: Tagesergebnisse). |
| C5 | Domain (Required) | `Round.roundType` | NOT NULL | Rundentyp (z.B. Field/3D/Target) ist für Punkteberechnung erforderlich (T5: Ranglistenberechnung). |
| C6 | Domain (Required) | `Range.rangeName` | NOT NULL | Range-Name ist Identifier-Kandidat und Anzeigeelement in UI (T3: Startgruppen, T4: Schussergebnisse). |
| C7 | Domain (Required) | `TargetStation.targetNumber` | NOT NULL | Ziel-Nummer ist Teil des Schlüssels schwacher Entität und für Ergebniserfassung erforderlich. |
| C8 | Domain (Required) | `TargetStation.targetGroup` | NOT NULL | Ziel-Gruppe (z.B. 14cm/20cm/28cm) bestimmt Hit-Zone-Verwertung (T4: Scorekarten-Erfassung). |
| C9 | Domain (Required) | `Participant.firstName` | NOT NULL | Person ist eindeutig durch Namen identifizierbar (IFAA-Regularien, Ergebnislisten). |
| C10 | Domain (Required) | `Participant.lastName` | NOT NULL | Person ist eindeutig durch Namen identifizierbar (IFAA-Regularien, Ergebnislisten). |
| C11 | Domain (Required) | `Participant.birthDate` | NOT NULL | Altersklasse ist aus Geburtsdatum ableitbar; benötigt für Classification-Checks (T2). |
| C12 | Domain (Required) | `Participant.nationCode` | NOT NULL | Nationale Zuordnung ist für Statistiken und Regulierung zwingend erforderlich. |
| C13 | Domain (Required) | `Official.firstName` | NOT NULL | Offizieller ist namentlich eindeutig (Signatur auf Scorekarten, Protest-Dokumentation). |
| C14 | Domain (Required) | `Official.lastName` | NOT NULL | Offizieller ist namentlich eindeutig (Signatur auf Scorekarten, Protest-Dokumentation). |
| C15 | Domain (Required) | `Official.officialFunction` | NOT NULL | Rolle (z.B. Range Officer, Judge) definiert Zuständigkeit und Sichtbarkeit in Schnittstellen. |
| C16 | Domain (Required) | `CompetitionCategory.style` | NOT NULL | Stil (z.B. Freestyle/Bowhunter) ist Teil der Klassifizierung (T2, T5). |
| C17 | Domain (Required) | `CompetitionCategory.division` | NOT NULL | Division (z.B. Men/Women/Youth) ist Teil der Klassifizierung (T2, T5). |
| C18 | Domain (Required) | `CompetitionCategory.classLevel` | NOT NULL | Klasse (z.B. Pro/Senior/Amateur) ist Teil der Klassifizierung (T2, T5). |
| C19 | Domain (Required) | `Registration.registrationId` | NOT NULL | Eindeutiger Primärschlüssel (Entity Integrity). |
| C20 | Domain (Required) | `Registration.participantId` | NOT NULL | Jede Anmeldung bezieht sich auf einen Teilnehmer (verpflichtende Partizipation). |

---

## C21–C40: Erforderliche Daten – Optionale Fremdschlüssel

| Constraint ID | Type | Relation / Attribute(s) | Constraint rule | Rationale / Source |
|---|---|---|---|---|
| C21 | Domain (Optional) | `Participant.clubId` | NULL ALLOWED | Teilnehmer kann ohne Vereinszugehörigkeit starten (memberOf optional, Assignment 02). |
| C22 | Domain (Optional) | `Range.officialId` | NULL ALLOWED | Range kann ohne zugewiesenen Offiziellen erzeugt werden (Zuweisung später möglich). |
| C23 | Domain (Optional) | `ScoreCard.officialId` | NULL ALLOWED | Scorekarte kann zuerst von Schütze selbst erfasst werden; Signatur später durch Offiziellen (T4: Scorekarte erfassen). |
| C24 | Domain (Optional) | `ShotResult.tieBreakId` | NULL ALLOWED | Schussergebnis ist regulär; Zuordnung zu Stechen nur bei Tie-Break (T6: Tie-Break erfassen). |

---

## C25–C50: Attribute-Domain-Bedingungen

| Constraint ID | Type | Relation / Attribute(s) | Constraint rule | Rationale / Source |
|---|---|---|---|---|
| C25 | Domain | `Event.startDate`, `Event.endDate` | `startDate <= endDate` | Turnierdauer muss positiv oder null sein; logisches Konsistenz-Gebot. |
| C26 | Domain | `Round.roundDate` | `roundDate BETWEEN Event.startDate AND Event.endDate` | Rundendate muss im Event-Fenster liegen (Business-Regel). |
| C27 | Domain | `Round.roundType` | Value in ('Field', '3D', 'Target', 'Indoor', 'Shoot-off') | Nur definierte Rundentypen; Vokabular aus IFAA-Regelwerk (Assignment 02). |
| C28 | Domain | `CompetitionCategory.style` | Value in ('Freestyle', 'Bowhunter', 'Traditional', 'Recurve', 'Compound') | IFAA-Stilkategorien (Assignment 02, Stakeholder-Anforderungen). |
| C29 | Domain | `CompetitionCategory.division` | Value in ('Men', 'Women', 'Youth', 'Senior', 'Mixed') | Gültige Divisionen; IFAA-Vorgabe. |
| C30 | Domain | `CompetitionCategory.classLevel` | Value in ('Pro', 'Senior', 'Amateur', 'Beginner', 'Junior') | Gültige Klassen; Geschäftsanforderung T2 (Classification). |
| C31 | Domain | `Registration.entryFeeStatus` | Value in ('unpaid', 'paid', 'waived', 'refunded') | Zulässige Gebühren-Zustände (Finanz-Workflow). |
| C32 | Domain | `Registration.equipmentStatus` | Value in ('unverified', 'verified', 'rejected') | Equipment-Kontrolle (T2: Klassifizierungskarte prüfen). |
| C33 | Domain | `Registration.classificationVerified` | NOT NULL, default 0 (FALSE) | Boolean; Klassi-Verifikation erforderlich vor Startfreigabe (T2). |
| C34 | Domain | `Registration.classificationDate` | Timestamp or NULL | Zeitstempel der Verifikation (T2: für Audit-Trail). |
| C35 | Domain | `ScoreCard.scoreCardId` | Globally Unique Identifier or BIGINT | Eindeutige Scorekarten-ID über alle Runden/Ranges (bis 4.800 Stück). |
| C36 | Domain | `ShotResult.arrowNumber` | Value in (1..6) [oder rundentypabhängig] | Pfeilindex pro Ziel pro Scorekarte (T4: Erfassungs-Grenze). |
| C37 | Domain | `ShotResult.hitZone` | Value in ('10', '9', '8', '7', '6', 'M', 'RM') | IFAA Hit-Zones (10/9/8/7/6 Punkte, Miss, Recallable Miss); für Punkteberechnung T5. |
| C38 | Domain | `TournamentResult.tieBreakStatus` | Value in ('not-needed', 'pending', 'completed', 'exempted') | Status des Stechens für Ranglistenberechnung. |
| C39 | Domain | `Protest.protestDate` | Timestamp NOT NULL | Zeitstempel Protest-Dokumentation (T7); Audit-Trail. |
| C40 | Domain | `Protest.protestDecision` | Value in ('pending', 'upheld', 'denied', 'appeal') | Gültige Entscheidungszustände (T7 Workflow). |

---

## C41–C60: Entity Integrity & Candidate Keys

| Constraint ID | Type | Relation / Attribute(s) | Constraint rule | Rationale / Source |
|---|---|---|---|---|
| C41 | Entity Integrity | `Event.eventId` | PRIMARY KEY, NOT NULL, UNIQUE | Eindeutige Event-Identifikation (PK). |
| C42 | Entity Integrity | `Event.(name, startDate)` | UNIQUE | Alternative Key; Event ist über Name + Startdatum eindeutig identifizierbar. |
| C43 | Entity Integrity | `Round.roundId` | PRIMARY KEY, NOT NULL, UNIQUE | Eindeutige Runden-ID. |
| C44 | Entity Integrity | `Round.(eventId, roundNumber)` | UNIQUE | Nur eine Runde pro Event mit gegebener Nummer. |
| C45 | Entity Integrity | `Range.rangeId` | PRIMARY KEY, NOT NULL, UNIQUE | Eindeutige Range-ID. |
| C46 | Entity Integrity | `Range.rangeName` | UNIQUE | Range-Namen sind eindeutig (Display in UI, T3). |
| C47 | Entity Integrity | `TargetStation.(rangeId, targetNumber)` | PRIMARY KEY, NOT NULL, UNIQUE | Zusammengesetzter PK schwacher Entität; eindeutig pro Range. |
| C48 | Entity Integrity | `Nation.nationCode` | PRIMARY KEY, NOT NULL, UNIQUE | ISO 3166-1 alpha-3 Code (z.B. 'GBR', 'USA'); eindeutige Nationale. |
| C49 | Entity Integrity | `Nation.nationName` | UNIQUE | Nationale Namen sind eindeutig (Anzeige in Rankings). |
| C50 | Entity Integrity | `Club.clubId` | PRIMARY KEY, NOT NULL, UNIQUE | Eindeutige Club-ID. |
| C51 | Entity Integrity | `Club.clubName` | UNIQUE | Club-Namen sind eindeutig (Referenzen in Registration, T1). |
| C52 | Entity Integrity | `Participant.participantId` | PRIMARY KEY, NOT NULL, UNIQUE | Eindeutige Teilnehmer-ID. |
| C53 | Entity Integrity | `Official.officialId` | PRIMARY KEY, NOT NULL, UNIQUE | Eindeutige Offiziellen-ID. |
| C54 | Entity Integrity | `CompetitionCategory.categoryId` | PRIMARY KEY, NOT NULL, UNIQUE | Eindeutige Kategorie-ID. |
| C55 | Entity Integrity | `CompetitionCategory.(style, division, classLevel)` | UNIQUE | Nur eine Kategorie pro Stil–Division–Klasse-Kombination. |
| C56 | Entity Integrity | `Registration.registrationId` | PRIMARY KEY, NOT NULL, UNIQUE | Eindeutige Anmeldungs-ID. |
| C57 | Entity Integrity | `Registration.(participantId, eventId)` | UNIQUE | Jeder Teilnehmer kann sich pro Event nur einmal anmelden (1-mal-Regel). |
| C58 | Entity Integrity | `StartGroup.groupId` | PRIMARY KEY, NOT NULL, UNIQUE | Eindeutige Startgruppen-ID. |
| C59 | Entity Integrity | `StartGroup.(roundId, groupNumber)` | UNIQUE | Nur eine Startgruppe pro Nummer und Runde. |
| C60 | Entity Integrity | `ScoreCard.scoreCardId` | PRIMARY KEY, NOT NULL, UNIQUE | Eindeutige Scorekarten-ID. |
| C61 | Entity Integrity | `ScoreCard.(registrationId, roundId)` | UNIQUE | Jeder Teilnehmer kann pro Runde nur eine Scorekarte haben. |
| C62 | Entity Integrity | `ShotResult.(scoreCardId, targetNumber, arrowNumber)` | PRIMARY KEY, NOT NULL, UNIQUE | Zusammengesetzter PK; eindeutig pro Scorekarte–Ziel–Pfeil. |
| C63 | Entity Integrity | `TournamentResult.resultId` | PRIMARY KEY, NOT NULL, UNIQUE | Eindeutige Ergebnis-ID. |
| C64 | Entity Integrity | `TournamentResult.registrationId` | UNIQUE | 1:1 Beziehung; eine Anmeldung = ein Turnierergebnis (optional). |
| C65 | Entity Integrity | `TieBreak.tieBreakId` | PRIMARY KEY, NOT NULL, UNIQUE | Eindeutige Stechen-ID. |
| C66 | Entity Integrity | `Protest.protestId` | PRIMARY KEY, NOT NULL, UNIQUE | Eindeutige Protest-ID. |
| C67 | Entity Integrity | `RoundRange.(roundId, rangeId)` | PRIMARY KEY, NOT NULL, UNIQUE | Brückenrelation; jede Kombination nur einmal. |
| C68 | Entity Integrity | `StartGroupMember.(groupId, registrationId)` | PRIMARY KEY, NOT NULL, UNIQUE | Brückenrelation; jeder Teilnehmer nur einmal pro Startgruppe. |
| C69 | Entity Integrity | `TieBreakParticipant.(tieBreakId, registrationId)` | PRIMARY KEY, NOT NULL, UNIQUE | Brückenrelation; jeder Teilnehmer nur einmal pro Stechen. |
| C70 | Entity Integrity | `TargetDistance.(rangeId, targetNumber, categoryId)` | PRIMARY KEY, NOT NULL, UNIQUE | Assoziationsrelation; eindeutig pro Ziel–Kategorie. |

---

## C99–C112: Business/Allgemeine Bedingungen

| Constraint ID | Type | Relation / Attribute(s) | Constraint rule | Rationale / Source |
|---|---|---|---|---|
| C99 | Business | `Participant.birthDate` | `birthDate <= CURRENT_DATE` (nicht in Zukunft) | Geburtsdatum muss in der Vergangenheit liegen (Person muss geboren sein). |
| C100 | Business | `Registration.classificationVerified = TRUE` | Erforderlich vor Startfreigabe (Turnier-Workflow) | T2: Klassifizierungskarte muss geprüft werden; `classificationVerified` = 1 sperrt nicht-qualifizierte Schützen. |
| C101 | Business | `Registration.classificationDate IS NULL OR classificationDate IS NOT NULL` | Wenn `classificationVerified = TRUE`, dann `classificationDate NOT NULL` | Zeitstempel dokumentiert Verifikations-Zeitpunkt (Audit-Trail). |
| C102 | Business | `Registration.(participantId, eventId)` uniqueness + mandatory | Jeder Teilnehmer kann sich pro Event max. 1× anmelden | 1-Mal-Regel pro Event (IFAA-Regelwerk, T1). |
| C103 | Business | `StartGroup.startTarget BETWEEN 1 AND numberOfTargets(Range)` | Startziel existiert in der zugewiesenen Range | T3 Constraint: Startziel muss in definiertem Ziel-Bereich liegen. |
| C104 | Business | `ScoreCard.scoreCardId` uniqueness + `(registrationId, roundId)` | Nur eine Scorekarte pro Anmeldung und Runde | Jeder Teilnehmer schießt pro Runde max. 1 Runde. |
| C105 | Business | `ShotResult.arrowNumber` sequence | 1, 2, 3, ... (abhängig von Rundentyp: usually 1..6) | T4: Pfeile müssen sequenziell erfasst werden (Eingabe-Validierung). |
| C106 | Business | `ShotResult.hitZone IN ('10', '9', '8', '7', '6', 'M', 'RM')` | Nur zulässige IFAA Hit-Zones (ggf. rundentypabhängig) | IFAA-Regelwerk; Basis für Punkteberechnung T5. |
| C107 | Business | `TournamentResult.registrationId` 1:1 relationship | Jede Anmeldung produziert maximal 1 Turnier-Ergebnis | Aggregat der Schützen-Leistung über alle Runden (T5). |
| C108 | Business | `TournamentResult.tieBreakStatus` workflow | NOT NULL; Werte dokumentieren Stechen-Status (pending → completed) | T6: Status-Übergang dokumentiert Entscheidungs-Workflow. |
| C109 | Business | `TieBreak` existence | Wird erzeugt nur, wenn Gleichstand auftritt (T6-Trigger) | Tie-Breaks sind event-gesteuert (T6: Tie-Break erfassen). |
| C110 | Business | `Protest` creation window | Protest-Dokumentation nur vor End-of-Event (T7-Workflow) | IFAA-Regelwerk: Proteste müssen während Turnier dokumentiert werden. |
| C111 | Business | `Protest.protestDecision` state machine | pending → (upheld \| denied \| appeal) | Entscheidungs-Workflow; `pending` ist Initial-Status (T7). |
| C112 | Business | `ShotResult → TieBreak` mutual exclusion | IF `tieBreakId IS NOT NULL`, THEN reguläres Ergebnis ist N/A (logisch) | Schuss ist entweder regulär oder Stechen, nicht beides (Design-Annahme T3). |
