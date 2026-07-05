# Query-Plan Evidence (Performance Probes)

**Assignment 04 – Exercise 6 (basic performance checks)**
Prüfvorlagen für `EXPLAIN (ANALYZE, BUFFERS)`. Diese Datei dokumentiert die
erwarteten Planformen und dient als Ablage für real erfasste Pläne (Copy der
`psql`-Ausgabe je Probe). Die Probes P1–P3 stehen als Kommentar am Ende von
[`../../../sql/R__test_cases.sql`](../../../sql/R__test_cases.sql).

---

## P1 — Rangliste (T5/T8): Matview + Kategorie-Index

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM wbhc.mv_tournament_ranking
WHERE event_id = 1 AND category_id = 1
ORDER BY rank_position;
```

**Erwarteter Plan (revised model):** `Index Scan using idx_mv_ranking_category on
mv_tournament_ranking` — die Sortierung nach `rank_position` wird vom Index bedient
(kein `Sort`-Knoten), Filter auf `(event_id, category_id)` als Index-Bedingung.

**Vergleich initial vs. revised (roundTotal, Iteration A):** Der Aufwand steckt im
`REFRESH MATERIALIZED VIEW`. Plan des Refresh-Selects:

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT reg.registration_id, SUM(sc.round_total)
FROM wbhc.registration reg
LEFT JOIN wbhc.score_card sc ON sc.registration_id = reg.registration_id
GROUP BY reg.registration_id;
```

- **Initial** (Aggregation über Schüsse): enthielt einen `Seq Scan on shot_result`
  (~201.600 Rows) + `HashAggregate` — der dominante Kostenpunkt.
- **Revised** (Summe über `score_card.round_total`): `Seq Scan on score_card`
  (~4.800 Rows) + `HashAggregate`. Erwartete Reduktion der gelesenen Zeilen um
  Faktor ~42 und entsprechend weniger `shared read`-Buffers.

---

## P2 — Startzulassung (T2): partieller Index

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT registration_id FROM wbhc.registration
WHERE event_id = 1 AND classification_verified = FALSE;
```

**Erwarteter Plan:** `Index Scan using idx_registration_unverified` (partieller
Index) statt `Seq Scan on registration`. Der Planner nutzt den partiellen Index, weil
das Prädikat `classification_verified = FALSE` exakt der Index-`WHERE`-Klausel
entspricht. Vorteil: nur der kleine Hot-Set (unverifizierte Anmeldungen) wird
gelesen.

**Gegenprobe ohne Index** (`SET enable_indexscan = off;` oder Index droppen): `Seq
Scan on registration` über alle ~1.200 Zeilen mit Filter.

---

## P3 — Schuss-Rücklesen (T4): PK-Ordnung ohne Sort

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM wbhc.shot_result
WHERE score_card_id = 1
ORDER BY target_number, arrow_number;
```

**Erwarteter Plan:** `Index Scan using pk_shot_result on shot_result` — da der
zusammengesetzte PK `(score_card_id, target_number, arrow_number)` sowohl den Filter
als auch die geforderte Sortierung liefert, entfällt ein separater `Sort`-Knoten.
Das begründet die Entwurfsentscheidung, für T4-Rücklesen **keinen** zusätzlichen
Index anzulegen (siehe index-catalog.md, Prinzip 4).

---

## Erfassung realer Pläne

Zum Festhalten der tatsächlichen Ausgabe:

```bash
psql -d wbhc2027 -c "EXPLAIN (ANALYZE, BUFFERS) SELECT ... ;" \
  > assets/plans/query-plan-evidence/P1_ranking.txt
```

Die `.txt`-Dateien in diesem Verzeichnis nehmen die realen Pläne auf (ein File je
Probe), sobald eine PostgreSQL-Instanz verfügbar ist.
