# Referential Actions Table

**Task 4: Foreign Key Strategies – ON DELETE & ON UPDATE**

---

## Referenzielle Integrität: Foreign Keys mit ON DELETE/UPDATE-Strategien

### Round Relation

| Constraint ID | FK Relation | ON DELETE Strategy | ON UPDATE Strategy | Rationale |
|---|---|---|---|---|
| C71 | `Round.eventId → Event.eventId` | **NO ACTION** | **CASCADE** | **NO ACTION** bei DELETE: Event darf nicht gelöscht werden, wenn Runden existieren (Audittrail-Erhaltung, IFAA-Regularien). **CASCADE** bei UPDATE: Falls Event-ID korrigiert werden muss (selten), kaskadiert auf Runden (Datenqualität). Rationale: Event ist Aggregat-Root; Löschung würde Turnierdaten zerstören (nicht akzeptabel). |

---

### Range Relation

| Constraint ID | FK Relation | ON DELETE Strategy | ON UPDATE Strategy | Rationale |
|---|---|---|---|---|
| C72 | `Range.officialId → Official.officialId` | **SET NULL** | **CASCADE** | **SET NULL** bei DELETE: Wenn Offizieller entfernt wird, Range bekommt `officialId = NULL` (Zuweisung später möglich, T3). Optional FK (Partizipation). **CASCADE** bei UPDATE: Selten; bei Korrektur von Official-ID kaskadiert (Konsistenzerhaltung). Rationale: Offizieller ist zeitweiliger Kontext; Nicht-kritisch für Range-Existenz. |

---

### TargetStation Relation

| Constraint ID | FK Relation | ON DELETE Strategy | ON UPDATE Strategy | Rationale |
|---|---|---|---|---|
| C73 | `TargetStation.rangeId → Range.rangeId` | **NO ACTION** | **CASCADE** | **NO ACTION** bei DELETE: Range darf nicht gelöscht werden, wenn Ziele existieren (Schwache Entität existenz-abhängig). Löschung würde ShotResult-Referenzen ungültig machen. **CASCADE** bei UPDATE: Range-ID-Korrektur kaskadiert zu Zielen (selten, aber für Konsistenz). Rationale: TargetStation ist Range-existenz-abhängig (weak entity); DELETE-Schutz ist zwingende Regel. |

---

### Participant Relation

| Constraint ID | FK Relation | ON DELETE Strategy | ON UPDATE Strategy | Rationale |
|---|---|---|---|---|
| C74 | `Participant.nationCode → Nation.nationCode` | **NO ACTION** | **CASCADE** | **NO ACTION** bei DELETE: Nation darf nicht gelöscht werden, solange Teilnehmer existieren (Regelwerk: jeder Teilnehmer muss Nation haben; Audittrail). **CASCADE** bei UPDATE: Nation-Code-Korrektur kaskadiert zu Teilnehmern (z.B. ISO-Code-Normalisierung). Rationale: Nation ist unveränderlicher Kontext des Teilnehmers; Löschung würde Dateneintegrität verletzen. |
| C75 | `Participant.clubId → Club.clubId` | **SET NULL** | **CASCADE** | **SET NULL** bei DELETE: Club-Löschung setzt `clubId = NULL` (Teilnehmer existiert ohne Club, T1 optional). **CASCADE** bei UPDATE: Club-ID-Korrektur kaskadiert (Datenqualität). Rationale: Club ist optionale Zugehörigkeit (memberOf optional, Assignment 02); Teilnehmer-Existenz ist unabhängig. |

---

### Registration Relation

| Constraint ID | FK Relation | ON DELETE Strategy | ON UPDATE Strategy | Rationale |
|---|---|---|---|---|
| C76 | `Registration.participantId → Participant.participantId` | **NO ACTION** | **CASCADE** | **NO ACTION** bei DELETE: Teilnehmer darf nicht gelöscht werden, wenn Anmeldungen existieren (Audittrail, Ergebnisse). **CASCADE** bei UPDATE: Selten; bei Teilnehmer-ID-Korrektur kaskadiert (Data Governance). Rationale: Anmeldung dokumentiert Teilnahme; Teilnehmer-Löschung würde Turnierintegrität gefährden. |
| C77 | `Registration.eventId → Event.eventId` | **NO ACTION** | **CASCADE** | **NO ACTION** bei DELETE: Event-Löschung blockiert bei Anmeldungen (Turnierdokumentation). **CASCADE** bei UPDATE: Konsistenzerhaltung bei Event-ID-Korrektur. Rationale: Anmeldung ist Event-spezifisch; Löschung würde Registrierungsverlauf zerstören. |
| C78 | `Registration.categoryId → CompetitionCategory.categoryId` | **NO ACTION** | **CASCADE** | **NO ACTION** bei DELETE: Kategorie-Löschung blockiert (Audittrail, Ranglisten). **CASCADE** bei UPDATE: Kategorie-ID-Änderung kaskadiert (selten). Rationale: Kategorie ist Klassifizierungs-Basis (T2, T5); Löschung würde Ergebnissemantik verändern. |

---

### StartGroup Relation

| Constraint ID | FK Relation | ON DELETE Strategy | ON UPDATE Strategy | Rationale |
|---|---|---|---|---|
| C79 | `StartGroup.roundId → Round.roundId` | **NO ACTION** | **CASCADE** | **NO ACTION** bei DELETE: Runde darf nicht gelöscht werden bei Startgruppen (würde Turnierplan zerstören). **CASCADE** bei UPDATE: Round-ID-Korrektur kaskadiert. Rationale: Startgruppe ist Runden-spezifisch (forRound, Assignment 02); Delete-Schutz wahrt Turnierkonsistenz. |
| C80 | `StartGroup.rangeId → Range.rangeId` | **NO ACTION** | **CASCADE** | **NO ACTION** bei DELETE: Range darf nicht gelöscht werden bei Startgruppen (würde Stationsplan ungültig). **CASCADE** bei UPDATE: Range-ID-Korrektur kaskadiert. Rationale: Startgruppe ordnet Schützen zu Range/Station zu (T3); Delete-Schutz ist Turnierlogik-Schutz. |

---

### ScoreCard Relation

| Constraint ID | FK Relation | ON DELETE Strategy | ON UPDATE Strategy | Rationale |
|---|---|---|---|---|
| C81 | `ScoreCard.registrationId → Registration.registrationId` | **NO ACTION** | **CASCADE** | **NO ACTION** bei DELETE: Anmeldung darf nicht gelöscht werden bei Scorekarten (Ergebnisaudit). **CASCADE** bei UPDATE: Selten; bei Anmeldungs-ID-Korrektur kaskadiert. Rationale: Scorekarte dokumentiert Leistung pro Anmeldung; Anmeldungs-Löschung würde Ergebnisse zerstören (unakzeptabel, T4, T5). |
| C82 | `ScoreCard.roundId → Round.roundId` | **NO ACTION** | **CASCADE** | **NO ACTION** bei DELETE: Runde darf nicht gelöscht werden bei Scorekarten (würde Rundergebnisse ungültig). **CASCADE** bei UPDATE: Round-ID-Änderung kaskadiert. Rationale: Scorekarte ist runden-spezifisch; Runden-Löschung würde Ergebnis-Historie zerstören. |
| C83 | `ScoreCard.officialId → Official.officialId` | **SET NULL** | **CASCADE** | **SET NULL** bei DELETE: Offizieller-Löschung setzt `officialId = NULL` (Scorekarte existiert ohne Unterschrift; kann später signiert werden). **CASCADE** bei UPDATE: Official-ID-Korrektur kaskadiert. Rationale: Offizieller-Signatur ist initial optional (T4: Scorekarte wird erfasst, dann signiert); Offiziellen-Löschung ist Business-Event, nicht kritisch für Daten. |
| C84 | `ScoreCard.rangeId → Range.rangeId` | **NO ACTION** | **CASCADE** | **NO ACTION** bei DELETE: Range darf nicht gelöscht werden bei Scorekarten (Ziel-Referenzen in ShotResult würden ungültig). **CASCADE** bei UPDATE: Range-ID-Korrektur kaskadiert. Rationale: ScoreCard benötigt Range-Kontext für ShotResult.targetNumber-Validierung (Task 3 Iteration). |

---

### ShotResult Relation

| Constraint ID | FK Relation | ON DELETE Strategy | ON UPDATE Strategy | Rationale |
|---|---|---|---|---|
| C85 | `ShotResult.scoreCardId → ScoreCard.scoreCardId` | **NO ACTION** | **CASCADE** | **NO ACTION** bei DELETE: Scorekarte darf nicht gelöscht werden bei Schussergebnissen (würde Roheinträge zerstören; Audittrail). **CASCADE** bei UPDATE: Selten; bei Scorekarten-ID-Korrektur kaskadiert. Rationale: ShotResult ist Scorekarten-abhängig (schwache Entität); Scorekarten-Löschung würde Ergebnis-Details zerstören. |
| C86 | `ShotResult.(rangeId, targetNumber) → TargetStation.(rangeId, targetNumber)` | **NO ACTION** | **CASCADE** | **NO ACTION** bei DELETE: TargetStation darf nicht gelöscht werden bei Schussergebnissen (würde Ziel-Referenzen ungültig). **CASCADE** bei UPDATE: Selten; Ziel-Nummer-Änderung kaskadiert (theoretisch; praktisch sollte Ziel-Setup unverändert bleiben). Rationale: ShotResult verweist auf physische Ziel-Station; Löschung würde Rohdaten-Kontext zerstören. |
| C87 | `ShotResult.tieBreakId → TieBreak.tieBreakId` | **SET NULL** | **CASCADE** | **SET NULL** bei DELETE: Stechen-Löschung setzt `tieBreakId = NULL` (Schuss wird als regulär behandelt, nicht als Stechen-Schuss). **CASCADE** bei UPDATE: Selten; bei Stechen-ID-Korrektur kaskadiert. Rationale: Stechen ist optional (T6: nur bei Gleichstand); Stechen-Löschung ist selten, würde aber nur Klassifizierung ändern (SET NULL akzeptabel, da ShotResult weiterhin existiert). |

---

### TournamentResult Relation

| Constraint ID | FK Relation | ON DELETE Strategy | ON UPDATE Strategy | Rationale |
|---|---|---|---|---|
| C88 | `TournamentResult.registrationId → Registration.registrationId` | **NO ACTION** | **CASCADE** | **NO ACTION** bei DELETE: Anmeldung darf nicht gelöscht werden, wenn Turnierergebnis existiert (Ergebnis-Audittrail). **CASCADE** bei UPDATE: Selten; bei Anmeldungs-ID-Korrektur kaskadiert (UNIQUE sichert 1:1 Relation, C64). Rationale: TournamentResult ist Anmeldungs-Ergebnis-Aggregat; Anmeldungs-Löschung würde finale Ranglistenposition zerstören (unakzeptabel, T5). |

---

### Protest Relation

| Constraint ID | FK Relation | ON DELETE Strategy | ON UPDATE Strategy | Rationale |
|---|---|---|---|---|
| C89 | `Protest.officialId → Official.officialId` | **NO ACTION** | **CASCADE** | **NO ACTION** bei DELETE: Offizieller darf nicht gelöscht werden, wenn Protest-Entscheide existieren (Audittrail, Regelwerk-Konformität). **CASCADE** bei UPDATE: Official-ID-Korrektur kaskadiert (selten). Rationale: Offizieller ist Entscheidungs-Träger (T7); Löschung würde Protest-Verantwortung zerstören (IFAA-Audit-Anforderung). |
| C90 | `Protest.registrationId → Registration.registrationId` | **NO ACTION** | **CASCADE** | **NO ACTION** bei DELETE: Anmeldung darf nicht gelöscht werden, wenn Protests existieren (Regelwerk-Audittrail). **CASCADE** bei UPDATE: Selten; bei Anmeldungs-ID-Korrektur kaskadiert. Rationale: Protest dokumentiert Einspruch gegen Ergebnis; Anmeldungs-Löschung würde Protest-Kontext zerstören (unakzeptabel). |

---

## Bridge Relations (Assoziationsrelationen)

| Constraint ID | FK Relation | ON DELETE Strategy | ON UPDATE Strategy | Rationale |
|---|---|---|---|---|
| C91 | `RoundRange.roundId → Round.roundId` | **CASCADE** | **CASCADE** | **CASCADE** bei DELETE: RoundRange-Einträge werden gelöscht, wenn Runde gelöscht wird (logisch, da Runde die Aggregat-Root ist). **CASCADE** bei UPDATE: Konsistenzerhaltung. Rationale: RoundRange ist reine Assoziationsrelation; kein Audit-Zwang wie bei Ergebnissen. |
| C92 | `RoundRange.rangeId → Range.rangeId` | **CASCADE** | **CASCADE** | **CASCADE** bei DELETE: RoundRange-Einträge werden gelöscht, wenn Range gelöscht wird (logisch). **CASCADE** bei UPDATE: Konsistenzerhaltung. Rationale: RoundRange ist Assoziationsrelation; Löschungs-Verhalten ist symmetrisch (C91). |
| C93 | `StartGroupMember.groupId → StartGroup.groupId` | **CASCADE** | **CASCADE** | **CASCADE** bei DELETE: StartGroupMember-Einträge werden gelöscht, wenn Startgruppe gelöscht wird (T3 Workflow; Teilnehmer-Zuordnung nicht mehr relevant). **CASCADE** bei UPDATE: Konsistenzerhaltung. Rationale: StartGroupMember ist Assoziationsrelation mit geringer Persistenz-Anforderung; Startgruppen-Löschung ist zulässig (Turniermodifikation). |
| C94 | `StartGroupMember.registrationId → Registration.registrationId` | **CASCADE** | **CASCADE** | **CASCADE** bei DELETE: StartGroupMember-Einträge werden gelöscht, wenn Anmeldung gelöscht wird (Teilnehmer tritt aus; Startgruppen-Zuordnungen werden ungültig). **CASCADE** bei UPDATE: Konsistenzerhaltung. Rationale: Anmeldungs-Löschung ist Business-Event (Austritt); Startgruppen-Zuordnung folgt automatisch. |
| C95 | `TieBreakParticipant.tieBreakId → TieBreak.tieBreakId` | **CASCADE** | **CASCADE** | **CASCADE** bei DELETE: TieBreakParticipant-Einträge werden gelöscht, wenn Stechen gelöscht wird (selten; würde aber alle Teilnehmer-Einträge logisch löschen). **CASCADE** bei UPDATE: Konsistenzerhaltung. Rationale: Stechen-Löschung ist Regeln-Korrektur (Stechen aufgehoben); Teilnehmer-Einträge werden ungültig. |
| C96 | `TieBreakParticipant.registrationId → Registration.registrationId` | **CASCADE** | **CASCADE** | **CASCADE** bei DELETE: TieBreakParticipant-Einträge werden gelöscht, wenn Anmeldung gelöscht wird (Teilnehmer tritt aus; Stechen-Teilnahme wird ungültig). **CASCADE** bei UPDATE: Konsistenzerhaltung. Rationale: Anmeldungs-Löschung ist Business-Event; Stechen-Teilnahme folgt automatisch. |

---

## Association Relation (Assoziationsklasse)

| Constraint ID | FK Relation | ON DELETE Strategy | ON UPDATE Strategy | Rationale |
|---|---|---|---|---|
| C97 | `TargetDistance.(rangeId, targetNumber) → TargetStation.(rangeId, targetNumber)` | **CASCADE** | **CASCADE** | **CASCADE** bei DELETE: TargetDistance-Einträge werden gelöscht, wenn TargetStation gelöscht wird (Ziel-Distanz-Definitionen sind Ziel-spezifisch). **CASCADE** bei UPDATE: Konsistenzerhaltung. Rationale: TargetDistance ist Konfiguration; Ziel-Löschung macht Distanz-Definition obsolet. |
| C98 | `TargetDistance.categoryId → CompetitionCategory.categoryId` | **NO ACTION** | **CASCADE** | **NO ACTION** bei DELETE: Kategorie-Löschung blockiert bei TargetDistance-Einträgen (würde Wettkampfregeln ungültig). **CASCADE** bei UPDATE: Kategorie-ID-Korrektur kaskadiert. Rationale: TargetDistance ist Regulatory-Konfiguration (Wettbewerbs-Regeln); Kategorie-Löschung würde Regelwerk beschädigen. |

---

## Summary: FK Strategy Distribution

| FK-Strategie | Vorkommen | Use-Case |
|---|---|---|
| **NO ACTION** (bei DELETE) | 18 FKs | Event, Round, Range, TargetStation, Participant, Registration, ScoreCard, ShotResult, TournamentResult, Protest, TargetDistance.categoryId; Audit-Trail/Datenintegrität-Schutz |
| **CASCADE** (bei DELETE) | 6 FKs | RoundRange, StartGroupMember, TieBreakParticipant, TargetDistance.rangeId; Assoziationsrelationen, Konfigurations-Updates |
| **SET NULL** (bei DELETE) | 3 FKs | Participant.clubId, Range.officialId, ScoreCard.officialId; optional FKs |
| **CASCADE** (bei UPDATE) | 28 FKs | Durchgehend; Konsistenzerhaltung bei ID-Korrektur (selten) |
