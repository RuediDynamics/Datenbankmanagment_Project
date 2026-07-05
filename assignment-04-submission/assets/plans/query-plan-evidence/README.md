# Query-Plan Evidence (Performance Probes)

**Assignment 04 – Exercise 6 (basic performance checks)**
Reale `EXPLAIN (ANALYZE, BUFFERS)`-Ausgaben, erfasst auf PostgreSQL 16
(Seed-Datenstand: V0.1–V0.6 + V0.5 Seed). Die Probes P1–P4 sind als Kommentar
am Ende von [`../../../sql/R__test_cases.sql`](../../../sql/R__test_cases.sql)
definiert.

---

## P1 — Rangliste lesen (T5/T8): Matview-Scan

**Datei:** [`P1_ranking_matview.txt`](P1_ranking_matview.txt)

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM wbhc.mv_tournament_ranking
WHERE event_id = 1 AND category_id = 1
ORDER BY rank_position;
```

**Ergebnis:** `Seq Scan on mv_tournament_ranking` + `Sort (quicksort)`.
Der Planner wählt bei 41 Matview-Zeilen (1 Page, `shared hit=1`) keinen
Index-Scan, weil der sequentielle Scan auf einer einzelnen Page billiger ist
als ein Index-Lookup. Erwartet und korrekt bei diesem Datenvolumen.
Bei produktiven Datenmengen (1.200+ Anmeldungen) würde
`idx_mv_ranking_category` greifen.

**Execution Time:** 0.057 ms — Matview-Zugriff ist nahezu instantan.

---

## P2 — Matview-Refresh-Quelle (Iteration A Evidenz)

**Datei:** [`P2_matview_refresh_source.txt`](P2_matview_refresh_source.txt)

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT reg.registration_id, SUM(sc.round_total)
FROM wbhc.registration reg
LEFT JOIN wbhc.score_card sc ON sc.registration_id = reg.registration_id
GROUP BY reg.registration_id;
```

**Ergebnis:** `Hash Left Join` über `registration` (41 Rows) ⋈ `score_card`
(43 Rows), `shared read=2`. Das bestätigt **Iteration A**: der Refresh
summiert `score_card.round_total` (43 Zeilen) statt `shot_result`-Punktwerte
(2.240+ Zeilen im Seed, ~201.600 in Produktion). Die teure Aggregation über
die Volumentabelle ist aus dem Refresh-Pfad verschwunden.

**Execution Time:** 0.169 ms.

---

## P3 — Startzulassung (T2): Partieller Index bestätigt

**Datei:** [`P3_admission_partial_index.txt`](P3_admission_partial_index.txt)

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT registration_id FROM wbhc.registration
WHERE event_id = 1 AND classification_verified = FALSE;
```

**Ergebnis:** `Index Scan using idx_registration_unverified` — der partielle
Index wird genutzt, weil das Filterprädikat `classification_verified = FALSE`
exakt der `WHERE`-Klausel des partiellen Index entspricht. Nur 13 unverifizierte
Zeilen werden gelesen statt alle 41 Registrierungen.

**Execution Time:** 0.092 ms — Entwurfsentscheidung bestätigt.

---

## P4 — Schuss-Rücklesen (T4): PK-Index genutzt

**Datei:** [`P4_shot_readback_pk.txt`](P4_shot_readback_pk.txt)

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM wbhc.shot_result
WHERE score_card_id = 1
ORDER BY target_number, arrow_number;
```

**Ergebnis:** `Bitmap Index Scan on pk_shot_result` → `Bitmap Heap Scan`.
Der zusammengesetzte PK `(score_card_id, target_number, arrow_number)` bedient
sowohl den Filter als auch die Lesereihenfolge. Der `Sort`-Knoten (quicksort,
27 kB in-memory) entsteht durch die Bitmap-Strategie, bei der die
Tupel-Reihenfolge nicht exakt Index-sortiert ist — bei 56 Zeilen vernachlässigbar.
Dies bestätigt die Entwurfsentscheidung, **keinen zusätzlichen Index** auf
`shot_result` für T4-Rücklesen anzulegen.

**Execution Time:** 0.091 ms.

---

## Zusammenfassung

| Probe | Zugriffspfad | Index genutzt? | Execution Time |
|---|---|---|---|
| P1 Ranking | Seq Scan (1-Page Matview) | Nein (erwartet bei 41 Rows) | 0.057 ms |
| P2 Refresh | Hash Left Join (score_card) | PK implizit | 0.169 ms |
| P3 Admission | **Index Scan** | **idx_registration_unverified** ✅ | 0.092 ms |
| P4 Shot read | **Bitmap Index Scan** | **pk_shot_result** ✅ | 0.091 ms |

Alle Pläne bestätigen die dokumentierten Entwurfsentscheidungen aus
@tbl-index-catalog und @tbl-derived-data-design.
