## Task 4: Specify Integrity Constraints {#sec-task4-integrity-constraints}

**Step 2.4 – Check and Document Integrity Constraints** (Connolly & Begg, Kap. 3, 4)

Diese Sektion dokumentiert alle Integritätsbedingungen des revidierten logischen Datenmodells (Task 1, Task 3) systematisch. Jede Bedingung wird mit Business-Semantik begründet und auf Stakeholder-Anforderungen oder Datenmodell-Entscheidungen rückgeführt.

---

### Integritätsbedingungen: Übersicht

Die folgenden Kategorien werden dokumentiert:

1. **Erforderliche Daten (NULL/NOT NULL Intent)**
2. **Attribut-Domain-Bedingungen** (zulässige Wertemenge, Format, Bereich)
3. **Entity Integrity** (Primärschlüssel-Eindeutigkeit, Nicht-NULL-Forderung)
4. **Referential Integrity** (Fremdschlüssel-Referenzen mit ON DELETE/UPDATE-Strategien)
5. **Business/allgemeine Bedingungen** (Geschäftsregeln, temporale/funktionale Abhängigkeiten)

---

### Struktur der Constraint-Dokumentation

Die detaillierte Constraint-Spezifikation ist in folgende Artefakte aufgeteilt (analog zu Task 3 Matrices):

| Artefakt | Inhalt | Bezug |
|---|---|---|
| **[constraint-specification-table.md](../assets/constraints/constraint-specification-table.md)** | Vollständige Constraint-Spezifikation (C1–C112): Required Data (C1–C24), Domain Constraints (C25–C40), Entity Integrity (C41–C70), Business Rules (C99–C112) | Strukturierte Tabellen; Traceability zu Transaktionen (Task 3) |
| **[referential-actions-table.md](../assets/constraints/referential-actions-table.md)** | Foreign Key Strategien: ON DELETE / ON UPDATE mit Rationale für alle 28 FKs, organisiert nach Relationen | Detailed FK-Specifications mit Business-Begründung |

---

### Zusammenfassung der Integritätsbedingungen

### Nach Constraint-Typ

| Constraint-Typ | Anzahl | Notizen |
|---|---|---|
| Required Data (NULL/NOT NULL) | 24 | Kernattribute für Geschäftsprozesse (C1–C24) |
| Domain Constraints | 16 | Wertemenge, Format, Bereich-Validierung (C25–C40) |
| Entity Integrity (PK, Candidate Keys) | 30 | Eindeutigkeit und Nicht-Nullbarkeit (C41–C70) |
| Referential Integrity (FK) | 28 | Foreign Keys mit ON DELETE/UPDATE-Strategien (C71–C98) |
| Business/General | 14 | Geschäftsregeln, Workflows, IFAA-Regelwerk (C99–C112) |
| **GESAMT** | **112** | – |

---

### Referential Integrity: FK-Strategien (Übersicht)

| FK-Strategie | Vorkommen | Use-Case |
|---|---|---|
| **NO ACTION** (bei DELETE) | 18 FKs | Event, Round, Range, TargetStation, Participant, Registration, ScoreCard, ShotResult, TournamentResult, Protest; Audit-Trail/Datenintegrität-Schutz |
| **CASCADE** (bei DELETE) | 6 FKs | RoundRange, StartGroupMember, TieBreakParticipant, TargetDistance; Assoziationsrelationen, Konfigurations-Updates |
| **SET NULL** (bei DELETE) | 3 FKs | Participant.clubId, Range.officialId, ScoreCard.officialId; optional FKs |
| **CASCADE** (bei UPDATE) | 28 FKs | Durchgehend; Konsistenzerhaltung bei ID-Korrektur (selten) |

---

### Geschäftliche Validierung

Die dokumentierten Constraints sind **direkt validierbar gegen die Stakeholder-Anforderungen** (Task 3 Transaktions-Matrix):

- **T1** (Teilnehmer anlegen): C20, C74, C75 (Participant constraints)
- **T2** (Klassifizierung prüfen): C100, C101 (Registration.classificationVerified, classificationDate)
- **T3** (Startgruppen erstellen): C79, C80, C93, C94, C103 (StartGroup, StartGroupMember constraints)
- **T4** (Scorekarte erfassen): C61, C81, C83, C84, C85, C86, C104, C105, C106 (ScoreCard, ShotResult constraints)
- **T5** (Rangliste anzeigen): C64, C88 (TournamentResult constraints)
- **T6** (Tie-Break erfassen): C87, C108, C109, C112 (TieBreak constraints)
- **T7** (Protest dokumentieren): C89, C90, C110, C111 (Protest constraints)
- **T8** (Ergebnisliste exportieren): C88 (TournamentResult constraints)

---

### Integritätsbedingungen und Datenmodell-Iterationen

### Constraints aus Task 3 Iteration

Die in Task 3 dokumentierte Modell-Iteration (ScoreCard + rangeId) wird durch folgende neue Constraints gestützt:

- **C84**: `ScoreCard.rangeId → Range.rangeId` (FK NOT NULL; ON DELETE NO ACTION, ON UPDATE CASCADE)
  - Rationale: ScoreCard benötigt Range-Kontext für ShotResult.targetNumber-Validierung (Task 3 Iteration)
  - Ermöglicht direkten Zugriff auf rangeId ohne 4-fachen Join

---

### Nächste Schritte (Exercise 5)

Diese Constraint-Spezifikation wird in Exercise 5 verwendet für:

1. **Review mit Stakeholdern** (Step 2.5): Bestätigung aller Geschäftsregeln (C99–C112) und Fremdschlüssel-Strategien
2. **Optionale Zusammenführung** (Step 2.6, wenn zutreffend): Konflikterkennung über Constraint-Definitionen
3. **Zukunfts-Prüfung** (Step 2.7): Extensibility-Assessment der aktuellen Constraint-Struktur

---

### Dokumentation: Vollständige Dateien

- **Constraint Specification**: [`assets/constraints/constraint-specification-table.md`](../assets/constraints/constraint-specification-table.md)
- **Referential Actions**: [`assets/constraints/referential-actions-table.md`](../assets/constraints/referential-actions-table.md)
