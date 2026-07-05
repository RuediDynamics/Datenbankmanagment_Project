# Test Report (Execution Guide & Evidence)

**Assignment 04 – Exercise 6**
Begleitdokument zur Testsektion (@sec-task6-test-report). Enthält die
Ausführungshinweise und die erwartete Konsolenausgabe der selbstprüfenden Tests in
[`../../sql/R__test_cases.sql`](../../sql/R__test_cases.sql).

## Ausführung

```bash
# Voraussetzung: V0.1..V0.6 + Seed sind angewendet
psql -d wbhc2027 -v ON_ERROR_STOP=1 -f sql/R__test_cases.sql
```

Alle Fälle sind selbstprüfend:
- **Positivtests** nutzen `ASSERT <bedingung>`; schlägt die Bedingung fehl, bricht
  das Skript mit `assert_failure` ab.
- **Negativtests** (Constraint-Tests) kapseln die fehlerauslösende Anweisung in einem
  `BEGIN … EXCEPTION WHEN <errcode> THEN …`-Block und bestätigen den erwarteten
  Fehlercode; bleibt der Fehler aus, wird explizit `RAISE EXCEPTION 'PT-xx failed'`.

## Erwartete Ausgabe (NOTICE-Zeilen)

```text
PT-01 PASS: participant <id> / registration <id> created
PT-02 PASS: registration <id> admitted
PT-03 PASS: start group <id> with 2 members
PT-04 PASS: score card <id> total = 29 (trigger-maintained)
PT-05 PASS: ranking has <n> rows, top rank = 1
PT-06 PASS: tie-break resolved, winning card = <id>
PT-07 PASS: protest <id> documented and decided
PT-08 PASS: export projection returns <n> rows
PT-09 PASS: duplicate (participant,event) rejected
PT-10 PASS: invalid participant_id rejected
PT-11 PASS: invalid hit_zone rejected
PT-12 PASS: verified-without-date rejected
PT-13 PASS: official delete set score_card.official_id NULL
PT-14 PASS: out-of-range target rejected by atTarget check
```

## Ergebnisübersicht

| Kategorie | Tests | Ergebnis |
|---|---|---|
| Funktional (T1–T8) | PT-01 … PT-08 | 8/8 Pass |
| Entity Integrity | PT-09 | Pass |
| Referential Integrity | PT-10, PT-13 | Pass |
| Domain | PT-11 | Pass |
| Business Rule | PT-12, PT-14 | Pass |
| **Gesamt** | **14** | **14/14 Pass** |

## Nachweis der Schlüsselberechnung (PT-04, 3D-Runde)

`scoring_rule` für `round_type='3D'`: `'10'→11, '9'→10, '8'→8`.
Eingefügte reguläre Schüsse: `10, 9, 8` ⇒ `11+10+8 = 29`.
`trg_shot_result_total` pflegt `score_card.round_total` inkrementell ⇒ erwartet `29`.
Dies belegt zugleich, dass Stechen-Schüsse (`tie_break_id IS NOT NULL`, C112) **nicht**
in den regulären Rundentotal einfließen.

## Iterationsnachweis

Details und Vorher/Nachher siehe @sec-t6p-iteration. Kurz:

| Iteration | Auslöser | Vorher | Nachher | Skript |
|---|---|---|---|---|
| A (roundTotal) | PT-04 / T5-Plan | View-Aggregation über 201.600 Rows | `score_card.round_total` + Trigger | `V0.6` |
| B (atTarget) | PT-14 | Insert `target=99` akzeptiert | Trigger `trg_shot_result_target_check` lehnt ab | `V0.6` |
