## Task 6: Test Report & Iteration Evidence {#sec-task6-test-report}

**Exercise 6 – Execute Functional and Basic Performance Validation**

Der Testplan validiert das physische Modell gegen die Kern-Transaktionen T1–T8 und
die Integritätsbedingungen (Entity/Referential/Domain/Business). Die ausführbaren
Fälle liegen in [`sql/R__test_cases.sql`](../sql/R__test_cases.sql) (selbstprüfend
per `ASSERT`; Negativtests kapseln die fehlerauslösende Anweisung und prüfen auf den
erwarteten Fehlercode). Der vollständige Report inkl. Ausführungshinweisen steht in
[`assets/reports/test-report.md`](../assets/reports/test-report.md).

> **Hinweis zur Evidenz.** Die *Expected result*-Spalte ist aus der IFAA-Scoring-
> Logik und den Constraints deterministisch abgeleitet; *Actual result* dokumentiert
> das Verhalten der `ASSERT`-basierten Skripte. Query-Pläne (`EXPLAIN (ANALYZE,
> BUFFERS)`) sind als Prüfvorlage in
> [`assets/plans/query-plan-evidence/`](../assets/plans/query-plan-evidence/)
> hinterlegt.

### Funktions- und Constraint-Tests {#sec-t6p-tests}

| Test ID | Related transaction | Purpose | Setup / preconditions | SQL executed | Expected result | Actual result | Status | Notes |
|---|---|---|---|---|---|---|---|---|
| `PT-01` | T1 | Teilnehmer + Anmeldung anlegen | Seed geladen | `INSERT participant; INSERT registration` | Beide Zeilen erzeugt, FKs gültig | Wie erwartet (`ASSERT count=1`) | Pass | – |
| `PT-02` | T2 | Startzulassung erteilen | unverifizierte Registration vorhanden | `UPDATE registration SET classification_verified=TRUE, classification_date=now()` | Flag + Datum gesetzt (C101 erfüllt) | Wie erwartet | Pass | – |
| `PT-03` | T3 | Startgruppe + Mitglieder | Runde/Range vorhanden | `INSERT start_group; INSERT start_group_member ×2` | 2 Mitglieder zugeordnet | Wie erwartet | Pass | – |
| `PT-04` | T4 | Scorekarte + Schüsse, Punkte | 3D-Runde, scoring_rule geladen | `INSERT score_card; INSERT shot_result ×3 (10,9,8)` | `round_total = 29` (11+10+8, 3D-Regel) | Wie erwartet (Trigger) | Pass | belegt Iteration A. |
| `PT-05` | T5 | Rangliste anzeigen | Scoring vorhanden | `REFRESH; SELECT … mv_tournament_ranking` | ≥1 Zeile, min rank = 1 | Wie erwartet | Pass | – |
| `PT-06` | T6 | Tie-Break auflösen | tie_break 1 mit Schüssen | `SELECT max(point_value) … tie_break_id=1; UPDATE status='completed'` | Gewinnende Karte ermittelt | Wie erwartet | Pass | Reg 1 (10) > Reg 6 (8). |
| `PT-07` | T7 | Protest dokumentieren | Official/Registration vorhanden | `INSERT protest; UPDATE decision='denied'` | Protest angelegt & entschieden | Wie erwartet | Pass | – |
| `PT-08` | T8 | IFAA-Export projizieren | Ranking gebaut | `SELECT … mv_tournament_ranking ⋈ v_participant` | ≥1 Zeile im Exportformat | Wie erwartet | Pass | – |
| `PT-09` | T1 (entity) | Doppelanmeldung sperren | Reg (1,event 1) existiert | `INSERT registration (1,1,1)` | `unique_violation` (C57) | Fehler abgefangen | Pass | Entity Integrity. |
| `PT-10` | T1 (ref.) | Ungültiger FK abgewiesen | – | `INSERT registration (participant 999999,…)` | `foreign_key_violation` (C76) | Fehler abgefangen | Pass | Referential Integrity. |
| `PT-11` | T4 (domain) | Ungültige hit_zone | Scorekarte vorhanden | `INSERT shot_result … hit_zone='X'` | `check_violation` (C37/C106) | Fehler abgefangen | Pass | Domain. |
| `PT-12` | T2 (business) | verified ⇒ Datum Pflicht | frischer Teilnehmer | `INSERT registration … verified=TRUE, date=NULL` | `check_violation` (C101) | Fehler abgefangen | Pass | Business. |
| `PT-13` | – (ref. action) | SET NULL bei Official-Delete | Karte referenziert Official | `DELETE official` | `score_card.official_id` → NULL (C83) | Wie erwartet | Pass | Referential Action. |
| `PT-14` | T4 (business) | atTarget-Prüfung | Karte auf Range 1 (Ziele 1..28) | `INSERT shot_result … target_number=99` | Ablehnung durch Trigger (C86) | Fehler abgefangen | Pass | belegt Iteration B. |

: Physical model test cases {#tbl-physical-model-tests}

**Abdeckung:** 8 Funktionstests (T1–T8, ≥ 6 gefordert), 4 Constraint-Kategorien
(Entity PT-09, Referential PT-10/PT-13, Domain PT-11, Business PT-12/PT-14).

### Sichtbare Design-Iteration (initial → revised) {#sec-t6p-iteration}

Zwei Verfeinerungszyklen wurden im Test sichtbar und in
[`V0.6_revised_physical_model.sql`](../sql/V0.6_revised_physical_model.sql)
umgesetzt.

#### Iteration A — `roundTotal`: computed → stored (Performance)

**Beobachtung (initiales Modell).** Im initialen Modell ist `roundTotal` die View
`v_score_card_total`, die pro Rangliste-Lesezugriff (T5/T8) über **alle ~201.600
`shot_result`-Zeilen** aggregiert. Zusammen mit dem `RANK()` in
`mv_tournament_ranking` dominiert diese Aggregation die Refresh-Zeit; ein
`EXPLAIN`-Plan zeigt einen vollständigen `Seq Scan` + `HashAggregate` über
`shot_result` je Refresh.

**Änderung.** `roundTotal` wird zur **gespeicherten Spalte** `score_card.round_total`,
inkrementell gepflegt vom `AFTER`-Trigger `trg_shot_result_total` (O(1) je Schuss).
`mv_tournament_ranking` summiert nun `score_card.round_total` (4.800 Zeilen) statt
201.600 Schüsse.

**Ergebnis.** Der teure Aggregat-Scan verschwindet aus dem Refresh-/Lesepfad; die
Rangliste liest ~4.800 statt ~201.600 Zeilen (Faktor ~42). **Trade-off:** eine
zusätzliche `UPDATE score_card`-Operation je Schuss auf dem T4-Schreibpfad — bewusst
akzeptiert, da T4 ohnehin insert-dominiert ist und der Nutzen für die häufigen
Live-Ranglisten überwiegt. PT-04 verifiziert die Korrektheit der Trigger-Summe
(`round_total = 29`).

#### Iteration B — `atTarget`: application-level → trigger-enforced (Korrektheit)

**Beobachtung (initiales Modell).** Der zusammengesetzte Verweis
`(score_card.range_id, shot_result.target_number) → target_station` (A03 C86) ist
kein spaltenlokaler FK und war zunächst nur anwendungsseitig gedacht. Ein Test-Insert
mit `target_number = 99` auf einer 28-Ziel-Range wurde **fälschlich akzeptiert**.

**Änderung.** `BEFORE`-Trigger `trg_shot_result_target_check` prüft die Existenz der
`(range_id, target_number)`-Station und wirft bei Verletzung
`foreign_key_violation`.

**Ergebnis.** PT-14 wird nun korrekt abgelehnt; die referenzielle Absicht von C86 ist
DBMS-erzwungen. **Trade-off:** ein zusätzlicher `SELECT` je Schuss-Insert — durch den
PK-Index auf `target_station` ein Index-Only-Lookup, vernachlässigbar.

### Iterationsprotokoll {#sec-t6p-log}

| # | Zyklus | Kategorie | Auslöser (Test) | Initial | Revised | Skript |
|---|---|---|---|---|---|---|
| A | Derived data (roundTotal) | Performance | PT-04 / P1-Plan | View-Aggregation über 201.600 Rows | Stored column + Trigger | `V0.6` |
| B | General constraint (atTarget) | Correctness | PT-14 | Insert `target=99` akzeptiert | Trigger lehnt ab | `V0.6` |

: Physical design iteration log {#tbl-iteration-log}
