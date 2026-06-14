# Task 4: Specify Integrity Constraints

**Step 2.4 – Check and Document Integrity Constraints** 


## Integritätsbedingungen: Übersicht

Die folgenden Kategorien werden dokumentiert:

1. **Erforderliche Daten (NULL/NOT NULL Intent)**
2. **Attribut-Domain-Bedingungen** (zulässige Wertemenge, Format, Bereich)
3. **Entity Integrity** (Primärschlüssel-Eindeutigkeit, Nicht-NULL-Forderung)
4. **Referential Integrity** (Fremdschlüssel-Referenzen mit ON DELETE/UPDATE-Strategien)
5. **Business/allgemeine Bedingungen** (Geschäftsregeln, temporale/funktionale Abhängigkeiten)

---

## Constraint-Spezifikationstabelle

### C1–C20: Erforderliche Daten (NULL/NOT-NULL Intent)

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

### C21–C40: Erforderliche Daten – Optionale Fremdschlüssel

| Constraint ID | Type | Relation / Attribute(s) | Constraint rule | Rationale / Source |
|---|---|---|---|---|
| C21 | Domain (Optional) | `Participant.clubId` | NULL ALLOWED | Teilnehmer kann ohne Vereinszugehörigkeit starten (memberOf optional, Assignment 02). |
| C22 | Domain (Optional) | `Range.officialId` | NULL ALLOWED | Range kann ohne zugewiesenen Offiziellen erzeugt werden (Zuweisung später möglich). |
| C23 | Domain (Optional) | `ScoreCard.officialId` | NULL ALLOWED | Scorekarte kann zuerst von Schütze selbst erfasst werden; Signatur später durch Offiziellen (T4: Scorekarte erfassen). |
| C24 | Domain (Optional) | `ShotResult.tieBreakId` | NULL ALLOWED | Schussergebnis ist regulär; Zuordnung zu Stechen nur bei Tie-Break (T6: Tie-Break erfassen). |

---

### C25–C50: Attribute-Domain-Bedingungen

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

### C41–C60: Entity Integrity & Candidate Keys

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

---

### C51–C80: Entity Integrity & Candidate Keys (Fortsetzung)

| Constraint ID | Type | Relation / Attribute(s) | Constraint rule | Rationale / Source |
|---|---|---|---|---|
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

---

### C61–C90: Entity Integrity & Candidate Keys (Fortsetzung 2)

| Constraint ID | Type | Relation / Attribute(s) | Constraint rule | Rationale / Source |
|---|---|---|---|---|
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

### C71–C130: Referential Integrity (Foreign Keys)

#### Referenzielle Integrität: Round

| Constraint ID | Type | Relation / Attribute(s) | Constraint rule | Rationale / Source |
|---|---|---|---|---|
| C71 | Referential | `Round.eventId → Event.eventId` | FK NOT NULL; ON DELETE **NO ACTION**; ON UPDATE **CASCADE** | **NO ACTION** bei DELETE: Event darf nicht gelöscht werden, wenn Runden existieren (Audittrail-Erhaltung, IFAA-Regularien). **CASCADE** bei UPDATE: Falls Event-ID korrigiert werden muss (selten), kaskadiert auf Runden (Datenqualität). Rationale: Event ist Aggregat-Root; Löschung würde Turnierdaten zerstören (nicht akzeptabel). |

---

#### Referenzielle Integrität: Range

| Constraint ID | Type | Relation / Attribute(s) | Constraint rule | Rationale / Source |
|---|---|---|---|---|
| C72 | Referential | `Range.officialId → Official.officialId` | FK NULL ALLOWED; ON DELETE **SET NULL**; ON UPDATE **CASCADE** | **SET NULL** bei DELETE: Wenn Offizieller entfernt wird, Range bekommt `officialId = NULL` (Zuweisung später möglich, T3). Optional FK (Partizipation). **CASCADE** bei UPDATE: Selten; bei Korrektur von Official-ID kaskadiert (Konsistenzerhaltung). Rationale: Offizieller ist zeitweiliger Kontext; Nicht-kritisch für Range-Existenz. |

---

#### Referenzielle Integrität: TargetStation

| Constraint ID | Type | Relation / Attribute(s) | Constraint rule | Rationale / Source |
|---|---|---|---|---|
| C73 | Referential | `TargetStation.rangeId → Range.rangeId` | FK NOT NULL; ON DELETE **NO ACTION**; ON UPDATE **CASCADE** | **NO ACTION** bei DELETE: Range darf nicht gelöscht werden, wenn Ziele existieren (Schwache Entität existiert-abhängig). Löschung würde ShotResult-Referenzen ungültig machen. **CASCADE** bei UPDATE: Range-ID-Korrektur kaskadiert zu Zielen (selten, aber für Konsistenz). Rationale: TargetStation ist Range-existenz-abhängig (weak entity); DELETE-Schutz ist zwingende Regel. |

---

#### Referenzielle Integrität: Participant

| Constraint ID | Type | Relation / Attribute(s) | Constraint rule | Rationale / Source |
|---|---|---|---|---|
| C74 | Referential | `Participant.nationCode → Nation.nationCode` | FK NOT NULL; ON DELETE **NO ACTION**; ON UPDATE **CASCADE** | **NO ACTION** bei DELETE: Nation darf nicht gelöscht werden, solange Teilnehmer existieren (Regelwerk: jeder Teilnehmer muss Nation haben; Audittrail). **CASCADE** bei UPDATE: Nation-Code-Korrektur kaskadiert zu Teilnehmern (z.B. ISO-Code-Normalisierung). Rationale: Nation ist unveränderlicher Kontext des Teilnehmers; Löschung würde Dateneintegrität verletzen. |
| C75 | Referential | `Participant.clubId → Club.clubId` | FK NULL ALLOWED; ON DELETE **SET NULL**; ON UPDATE **CASCADE** | **SET NULL** bei DELETE: Club-Löschung setzt `clubId = NULL` (Teilnehmer existiert ohne Club, T1 optional). **CASCADE** bei UPDATE: Club-ID-Korrektur kaskadiert (Datenqualität). Rationale: Club ist optionale Zugehörigkeit (memberOf optional, Assignment 02); Teilnehmer-Existenz ist unabhängig. |

---

#### Referenzielle Integrität: Registration

| Constraint ID | Type | Relation / Attribute(s) | Constraint rule | Rationale / Source |
|---|---|---|---|---|
| C76 | Referential | `Registration.participantId → Participant.participantId` | FK NOT NULL; ON DELETE **NO ACTION**; ON UPDATE **CASCADE** | **NO ACTION** bei DELETE: Teilnehmer darf nicht gelöscht werden, wenn Anmeldungen existieren (Audittrail, Ergebnisse). **CASCADE** bei UPDATE: Selten; bei Teilnehmer-ID-Korrektur kaskadiert (Data Governance). Rationale: Anmeldung dokumentiert Teilnahme; Teilnehmer-Löschung würde Turnierintegrität gefährden. |
| C77 | Referential | `Registration.eventId → Event.eventId` | FK NOT NULL; ON DELETE **NO ACTION**; ON UPDATE **CASCADE** | **NO ACTION** bei DELETE: Event-Löschung blockiert bei Anmeldungen (Turnierdokumentation). **CASCADE** bei UPDATE: Konsistenzerhaltung bei Event-ID-Korrektur. Rationale: Anmeldung ist Event-spezifisch; Löschung würde Registrierungsverlauf zerstören. |
| C78 | Referential | `Registration.categoryId → CompetitionCategory.categoryId` | FK NOT NULL; ON DELETE **NO ACTION**; ON UPDATE **CASCADE** | **NO ACTION** bei DELETE: Kategorie-Löschung blockiert (Audittrail, Ranglisten). **CASCADE** bei UPDATE: Kategorie-ID-Änderung kaskadiert (selten). Rationale: Kategorie ist Klassifizierungs-Basis (T2, T5); Löschung würde Ergebnissemantik verändern. |

---

#### Referenzielle Integrität: StartGroup

| Constraint ID | Type | Relation / Attribute(s) | Constraint rule | Rationale / Source |
|---|---|---|---|---|
| C79 | Referential | `StartGroup.roundId → Round.roundId` | FK NOT NULL; ON DELETE **NO ACTION**; ON UPDATE **CASCADE** | **NO ACTION** bei DELETE: Runde darf nicht gelöscht werden bei Startgruppen (würde Turnierplan zerstören). **CASCADE** bei UPDATE: Round-ID-Korrektur kaskadiert. Rationale: Startgruppe ist Runden-spezifisch (forRound, Assignment 02); Delete-Schutz wahrt Turnierkonsistenz. |
| C80 | Referential | `StartGroup.rangeId → Range.rangeId` | FK NOT NULL; ON DELETE **NO ACTION**; ON UPDATE **CASCADE** | **NO ACTION** bei DELETE: Range darf nicht gelöscht werden bei Startgruppen (würde Stationsplan ungültig). **CASCADE** bei UPDATE: Range-ID-Korrektur kaskadiert. Rationale: Startgruppe ordnet Schützen zu Range/Station zu (T3); Delete-Schutz ist Turnierlogik-Schutz. |

---

#### Referenzielle Integrität: ScoreCard

| Constraint ID | Type | Relation / Attribute(s) | Constraint rule | Rationale / Source |
|---|---|---|---|---|
| C81 | Referential | `ScoreCard.registrationId → Registration.registrationId` | FK NOT NULL; ON DELETE **NO ACTION**; ON UPDATE **CASCADE** | **NO ACTION** bei DELETE: Anmeldung darf nicht gelöscht werden bei Scorekarten (Ergebnisaudit). **CASCADE** bei UPDATE: Selten; bei Anmeldungs-ID-Korrektur kaskadiert. Rationale: Scorekarte dokumentiert Leistung pro Anmeldung; Anmeldungs-Löschung würde Ergebnisse zerstören (unakzeptabel, T4, T5). |
| C82 | Referential | `ScoreCard.roundId → Round.roundId` | FK NOT NULL; ON DELETE **NO ACTION**; ON UPDATE **CASCADE** | **NO ACTION** bei DELETE: Runde darf nicht gelöscht werden bei Scorekarten (würde Rundergebnisse ungültig). **CASCADE** bei UPDATE: Round-ID-Änderung kaskadiert. Rationale: Scorekarte ist runden-spezifisch; Runden-Löschung würde Ergebnis-Historie zerstören. |
| C83 | Referential | `ScoreCard.officialId → Official.officialId` | FK NULL ALLOWED; ON DELETE **SET NULL**; ON UPDATE **CASCADE** | **SET NULL** bei DELETE: Offizieller-Löschung setzt `officialId = NULL` (Scorekarte existiert ohne Unterschrift; kann später signiert werden). **CASCADE** bei UPDATE: Official-ID-Korrektur kaskadiert. Rationale: Offizieller-Signatur ist initial optional (T4: Scorekarte wird erfasst, dann signiert); Offiziellen-Löschung ist Business-Event, nicht kritisch für Daten. |
| C84 | Referential | `ScoreCard.rangeId → Range.rangeId` | FK NOT NULL; ON DELETE **NO ACTION**; ON UPDATE **CASCADE** | **NO ACTION** bei DELETE: Range darf nicht gelöscht werden bei Scorekarten (Ziel-Referenzen in ShotResult würden ungültig). **CASCADE** bei UPDATE: Range-ID-Korrektur kaskadiert. Rationale: ScoreCard benötigt Range-Kontext für ShotResult.targetNumber-Validierung (Task 3 Iteration). |

---

#### Referenzielle Integrität: ShotResult

| Constraint ID | Type | Relation / Attribute(s) | Constraint rule | Rationale / Source |
|---|---|---|---|---|
| C85 | Referential | `ShotResult.scoreCardId → ScoreCard.scoreCardId` | FK NOT NULL; ON DELETE **NO ACTION**; ON UPDATE **CASCADE** | **NO ACTION** bei DELETE: Scorekarte darf nicht gelöscht werden bei Schussergebnissen (würde Roheinträge zerstören; Audittrail). **CASCADE** bei UPDATE: Selten; bei Scorekarten-ID-Korrektur kaskadiert. Rationale: ShotResult ist Scorekarten-abhängig (schwache Entität); Scorekarten-Löschung würde Ergebnis-Details zerstören. |
| C86 | Referential | `ShotResult.(rangeId, targetNumber) → TargetStation.(rangeId, targetNumber)` | FK NOT NULL; ON DELETE **NO ACTION**; ON UPDATE **CASCADE** | **NO ACTION** bei DELETE: TargetStation darf nicht gelöscht werden bei Schussergebnissen (würde Ziel-Referenzen ungültig). **CASCADE** bei UPDATE: Selten; Ziel-Nummer-Änderung kaskadiert (theoretisch; praktisch sollte Ziel-Setup unverändert bleiben). Rationale: ShotResult verweist auf physische Ziel-Station; Löschung würde Rohdaten-Kontext zerstören. |
| C87 | Referential | `ShotResult.tieBreakId → TieBreak.tieBreakId` | FK NULL ALLOWED; ON DELETE **SET NULL**; ON UPDATE **CASCADE** | **SET NULL** bei DELETE: Stechen-Löschung setzt `tieBreakId = NULL` (Schuss wird als regulär behandelt, nicht als Stechen-Schuss). **CASCADE** bei UPDATE: Selten; bei Stechen-ID-Korrektur kaskadiert. Rationale: Stechen ist optional (T6: nur bei Gleichstand); Stechen-Löschung ist selten, würde aber nur Klassifizierung ändern (SET NULL akzeptabel, da ShotResult weiterhin existiert). |

---

#### Referenzielle Integrität: TournamentResult

| Constraint ID | Type | Relation / Attribute(s) | Constraint rule | Rationale / Source |
|---|---|---|---|---|
| C88 | Referential | `TournamentResult.registrationId → Registration.registrationId` | FK NOT NULL, UNIQUE; ON DELETE **NO ACTION**; ON UPDATE **CASCADE** | **NO ACTION** bei DELETE: Anmeldung darf nicht gelöscht werden, wenn Turnierergebnis existiert (Ergebnis-Audittrail). **CASCADE** bei UPDATE: Selten; bei Anmeldungs-ID-Korrektur kaskadiert (UNIQUE sichert 1:1 Relation, C64). Rationale: TournamentResult ist Anmeldungs-Ergebnis-Aggregat; Anmeldungs-Löschung würde finale Ranglistenposition zerstören (unakzeptabel, T5). |

---

#### Referenzielle Integrität: Protest

| Constraint ID | Type | Relation / Attribute(s) | Constraint rule | Rationale / Source |
|---|---|---|---|---|
| C89 | Referential | `Protest.officialId → Official.officialId` | FK NOT NULL; ON DELETE **NO ACTION**; ON UPDATE **CASCADE** | **NO ACTION** bei DELETE: Offizieller darf nicht gelöscht werden, wenn Protest-Entscheide existieren (Audittrail, Regelwerk-Konformität). **CASCADE** bei UPDATE: Official-ID-Korrektur kaskadiert (selten). Rationale: Offizieller ist Entscheidungs-Träger (T7); Löschung würde Protest-Verantwortung zerstören (IFAA-Audit-Anforderung). |
| C90 | Referential | `Protest.registrationId → Registration.registrationId` | FK NOT NULL; ON DELETE **NO ACTION**; ON UPDATE **CASCADE** | **NO ACTION** bei DELETE: Anmeldung darf nicht gelöscht werden, wenn Protests existieren (Regelwerk-Audittrail). **CASCADE** bei UPDATE: Selten; bei Anmeldungs-ID-Korrektur kaskadiert. Rationale: Protest dokumentiert Einspruch gegen Ergebnis; Anmeldungs-Löschung würde Protest-Kontext zerstören (unakzeptabel). |

---

#### Referenzielle Integrität: Brückenrelationen

| Constraint ID | Type | Relation / Attribute(s) | Constraint rule | Rationale / Source |
|---|---|---|---|---|
| C91 | Referential | `RoundRange.roundId → Round.roundId` | FK NOT NULL; ON DELETE **CASCADE**; ON UPDATE **CASCADE** | **CASCADE** bei DELETE: RoundRange-Einträge werden gelöscht, wenn Runde gelöscht wird (logisch, da Runde die Aggregat-Root ist). **CASCADE** bei UPDATE: Konsistenzerhaltung. Rationale: RoundRange ist reine Assoziationsrelation; kein Audit-Zwang wie bei Ergebnissen. |
| C92 | Referential | `RoundRange.rangeId → Range.rangeId` | FK NOT NULL; ON DELETE **CASCADE**; ON UPDATE **CASCADE** | **CASCADE** bei DELETE: RoundRange-Einträge werden gelöscht, wenn Range gelöscht wird (logisch). **CASCADE** bei UPDATE: Konsistenzerhaltung. Rationale: RoundRange ist Assoziationsrelation; Löschungs-Verhalten ist symmetrisch (C91). |
| C93 | Referential | `StartGroupMember.groupId → StartGroup.groupId` | FK NOT NULL; ON DELETE **CASCADE**; ON UPDATE **CASCADE** | **CASCADE** bei DELETE: StartGroupMember-Einträge werden gelöscht, wenn Startgruppe gelöscht wird (T3 Workflow; Teilnehmer-Zuordnung nicht mehr relevant). **CASCADE** bei UPDATE: Konsistenzerhaltung. Rationale: StartGroupMember ist Assoziationsrelation mit geringer Persistenz-Anforderung; Startgruppen-Löschung ist zulässig (Turniermodifikation). |
| C94 | Referential | `StartGroupMember.registrationId → Registration.registrationId` | FK NOT NULL; ON DELETE **CASCADE**; ON UPDATE **CASCADE** | **CASCADE** bei DELETE: StartGroupMember-Einträge werden gelöscht, wenn Anmeldung gelöscht wird (Teilnehmer tritt aus; Startgruppen-Zuordnungen werden ungültig). **CASCADE** bei UPDATE: Konsistenzerhaltung. Rationale: Anmeldungs-Löschung ist Business-Event (Austritt); Startgruppen-Zuordnung folgt automatisch. |
| C95 | Referential | `TieBreakParticipant.tieBreakId → TieBreak.tieBreakId` | FK NOT NULL; ON DELETE **CASCADE**; ON UPDATE **CASCADE** | **CASCADE** bei DELETE: TieBreakParticipant-Einträge werden gelöscht, wenn Stechen gelöscht wird (selten; würde aber alle Teilnehmer-Einträge logisch löschen). **CASCADE** bei UPDATE: Konsistenzerhaltung. Rationale: Stechen-Löschung ist Regeln-Korrektur (Stechen aufgehoben); Teilnehmer-Einträge werden ungültig. |
| C96 | Referential | `TieBreakParticipant.registrationId → Registration.registrationId` | FK NOT NULL; ON DELETE **CASCADE**; ON UPDATE **CASCADE** | **CASCADE** bei DELETE: TieBreakParticipant-Einträge werden gelöscht, wenn Anmeldung gelöscht wird (Teilnehmer tritt aus; Stechen-Teilnahme wird ungültig). **CASCADE** bei UPDATE: Konsistenzerhaltung. Rationale: Anmeldungs-Löschung ist Business-Event; Stechen-Teilnahme folgt automatisch. |

---

#### Referenzielle Integrität: Assoziationsrelation

| Constraint ID | Type | Relation / Attribute(s) | Constraint rule | Rationale / Source |
|---|---|---|---|---|
| C97 | Referential | `TargetDistance.(rangeId, targetNumber) → TargetStation.(rangeId, targetNumber)` | FK NOT NULL; ON DELETE **CASCADE**; ON UPDATE **CASCADE** | **CASCADE** bei DELETE: TargetDistance-Einträge werden gelöscht, wenn TargetStation gelöscht wird (Ziel-Distanz-Definitionen sind Ziel-spezifisch). **CASCADE** bei UPDATE: Konsistenzerhaltung. Rationale: TargetDistance ist Konfiguration; Ziel-Löschung macht Distanz-Definition obsolet. |
| C98 | Referential | `TargetDistance.categoryId → CompetitionCategory.categoryId` | FK NOT NULL; ON DELETE **NO ACTION**; ON UPDATE **CASCADE** | **NO ACTION** bei DELETE: Kategorie-Löschung blockiert bei TargetDistance-Einträgen (würde Wettkampfregeln ungültig). **CASCADE** bei UPDATE: Kategorie-ID-Korrektur kaskadiert. Rationale: TargetDistance ist Regulatory-Konfiguration (Wettbewerbs-Regeln); Kategorie-Löschung würde Regelwerk beschädigen. |

---

### C99–C130: Business/Allgemeine Bedingungen

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

---

## Zusammenfassung der Integritätsbedingungen

### Nach Typ

| Constraint-Typ | Anzahl | Notizen |
|---|---|---|
| Required Data (NULL/NOT NULL) | 24 | Kernattribute für Geschäftsprozesse |
| Domain Constraints | 16 | Wertemenge, Format, Bereich-Validierung |
| Entity Integrity (PK, Candidate Keys) | 30 | Eindeutigkeit und Nicht-Nullbarkeit |
| Referential Integrity (FK) | 28 | Foreign Keys mit ON DELETE/UPDATE-Strategien |
| Business/General | 14 | Geschäftsregeln, Workflows, IFAA-Regelwerk |
| **GESAMT** | **112** | – |

---

### Referential Integrity: Zusammenfassung ON DELETE/UPDATE-Strategien

| FK-Strategie | Vorkommen | Use-Case |
|---|---|---|
| **NO ACTION** (bei DELETE) | 18 FKs | Event, Round, Range, TargetStation, Participant, Registration, ScoreCard, ShotResult, TournamentResult, Protest; Audit-Trail/Datenintegrität-Schutz |
| **CASCADE** (bei DELETE) | 6 FKs | RoundRange, StartGroupMember, TieBreakParticipant, TargetDistance; Assoziationsrelationen, Konfigurations-Updates |
| **SET NULL** (bei DELETE) | 3 FKs | Participant.clubId, Range.officialId, ScoreCard.officialId; optional FKs |
| **CASCADE** (bei UPDATE) | 28 FKs | Durchgehend; Konsistenzerhaltung bei ID-Korrektur (selten) |

---

### Geschäftliche Validierung

Die in diesem Abschnitt dokumentierten Constraints sind **direkt validierbar gegen die Stakeholder-Anforderungen** (Task 3 Transaktions-Matrix):

- **T1** (Teilnehmer anlegen): C20, C74, C75 (Participant constraints)
- **T2** (Klassifizierung prüfen): C100, C101 (Registration.classificationVerified, classificationDate)
- **T3** (Startgruppen erstellen): C79, C80, C93, C94, C103 (StartGroup, StartGroupMember constraints)
- **T4** (Scorekarte erfassen): C61, C81, C83, C84, C85, C86, C104, C105, C106 (ScoreCard, ShotResult constraints)
- **T5** (Rangliste anzeigen): C64, C88 (TournamentResult constraints)
- **T6** (Tie-Break erfassen): C87, C108, C109, C112 (TieBreak constraints)
- **T7** (Protest dokumentieren): C89, C90, C110, C111 (Protest constraints)
- **T8** (Ergebnisliste exportieren): C88 (TournamentResult constraints)

---

## Nächste Schritte (Exercise 5)

Diese Constraint-Spezifikation wird in Exercise 5 verwendet für:

1. **Review mit Stakeholdern** (Step 2.5): Bestätigung aller Geschäftsregeln (C99–C112) und Fremdschlüssel-Strategien
2. **Optionale Zusammenführung** (Step 2.6, wenn zutreffend): Konflikterkennung über Constraint-Definitionen
3. **Zukunfts-Prüfung** (Step 2.7): Extensibility-Assessment der aktuellen Constraint-Struktur
