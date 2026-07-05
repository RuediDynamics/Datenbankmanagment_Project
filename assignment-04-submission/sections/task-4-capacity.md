## Task 4: Capacity & Growth Estimation (Step 4.4) {#sec-task4-capacity}

**Exercise 4 – Estimate Disk Space Requirements**
(Connolly & Begg, Kap. 18, Step 4.4)

Diese Sektion schätzt den Speicherbedarf für die Erstinbetriebnahme der WBHC 2027
und ein kurzfristiges Wachstum. Die vollständige Herleitung liegt in
[`assets/reports/capacity-estimation.md`](../assets/reports/capacity-estimation.md).

### Methode und Annahmen {#sec-t4p-method}

- **Volumen-Treiber** (aus A02/A03): 1 Event, 4 Runden, ~8 Ranges à 28 Ziele,
  **~1.200 Schützen**, 1 Anmeldung je Schütze, **4.800 Scorekarten** (1.200 × 4),
  ø 42 Schüsse je Karte → **~201.600 Schussergebnisse** (A03 Task 3 Iteration).
- **Zeilenbreite:** PostgreSQL-Heap-Tupel = 24 B Header + Nullbitmap + Spaltendaten,
  8-Byte-aligned. Angesetzt werden gerundete Nettobreiten inkl. Alignment.
- **Tabellengröße** = Zeilen × ø Zeilenbreite, aufgerundet auf 8-KB-Pages, plus
  ~10 % Heap-Overhead (Fillfactor/Padding).
- **Index-Overhead** wird separat grob mit ~40–60 % der Heap-Größe der jeweils
  indizierten Tabelle veranschlagt (btree, kurze Schlüssel).
- Genauigkeit ist bewusst näherungsweise; Klarheit der Annahmen zählt mehr als
  Präzision.

### Capacity Estimation {#sec-t4p-table}

| Table | Estimated rows | Avg row size (bytes) | Estimated table size | Growth assumption | Notes |
|---|---|---|---|---|---|
| `nation` | 50 | 40 | ~8 KB | statisch | ISO-Referenz. |
| `club` | 200 | 48 | ~16 KB | +5 %/Jahr | – |
| `official` | 40 | 64 | ~8 KB | statisch | – |
| `competition_category` | 30 | 56 | ~8 KB | statisch | Style×Div×Class-Teilmenge. |
| `event` | 1 | 120 | ~8 KB | +1/Event | Single-Event-Scope (A1). |
| `round` | 4 | 48 | ~8 KB | +4/Event | – |
| `shooting_range` | 8 | 56 | ~8 KB | statisch | – |
| `target_station` | 224 | 40 | ~16 KB | statisch | 8 × 28. |
| `participant` | 1.200 | 72 | ~110 KB | +Event-Kohorte | – |
| `registration` | 1.200 | 80 | ~120 KB | +1.200/Event | – |
| `start_group` | 960 | 48 | ~64 KB | ×4 Runden | 240 Gruppen × 4. |
| `start_group_member` | 4.800 | 40 | ~230 KB | ×4 Runden | – |
| `score_card` | 4.800 | 56 | ~350 KB | ×4 Runden | +`round_total` (revised). |
| **`shot_result`** | **201.600** | **48** | **~11 MB** | dominanter Treiber | Volumen-Tabelle. |
| `tournament_result` | 1.200 | 48 | ~64 KB | +1.200/Event | – |
| `tie_break` | 20 | 40 | ~8 KB | selten | – |
| `tie_break_participant` | 50 | 40 | ~8 KB | selten | – |
| `protest` | 30 | 200 | ~8 KB | selten | TEXT-Feld. |
| `round_range` | 16 | 40 | ~8 KB | statisch | – |
| `target_distance` | 2.000 | 48 | ~110 KB | statisch | Station×Kategorie-Teilmenge. |
| `scoring_rule` | 40 | 40 | ~8 KB | statisch | Regel-Lookup. |
| **Heap gesamt** | **~218.000** | – | **~12,7 MB** | – | – |
| Indizes (PK + Sekundär + Matview) | – | – | **~9–11 MB** | – | ~60 % der `shot_result`-PK dominiert. |
| `mv_tournament_ranking` | 1.200 | 72 | ~110 KB | mit Event | materialisiert. |
| **Gesamt (initial)** | – | – | **~24 MB** | – | passt vollständig in RAM (A-Hardware). |

: Capacity estimation {#tbl-capacity-estimation}

### Wachstum (6–12 Monate) {#sec-t4p-growth}

- **Innerhalb des Single-Event-Scopes** (A1) ist das Volumen nach Turnierende
  praktisch statisch; es entsteht kein laufendes Wachstum. Der 12-Monats-Bedarf
  bleibt bei **~24 MB**.
- **Szenario Mehr-Event-Serie** (A03 Future Growth): Jedes weitere Event derselben
  Größe fügt ~12–13 MB Heap + ~9–11 MB Indizes hinzu, dominiert erneut durch
  `shot_result` (~201.600 Zeilen/Event). Bei **4 Events/Jahr** ⇒ **~+100 MB/Jahr**.
  Selbst nach 5 Jahren (~0,5 GB) ist keine Partitionierung zwingend; als
  Handover-Empfehlung (@sec-task7-reflection) wäre bei einer echten Serie eine
  **Range-Partitionierung von `shot_result` nach `event_id`/`round_id`** der erste
  Skalierungsschritt.
- **Sensitivität:** Der Schätzwert hängt fast ausschließlich an der ø-Pfeilzahl je
  Ziel (1–3 je Rundentyp). Die Bandbreite ist 28 Schüsse/Karte (nur 3D-Hunting,
  ~134.000 Rows, ~8 MB) bis 84 Schüsse/Karte (nur 3-Pfeil, ~403.000 Rows, ~19 MB
  Heap). Der Ansatz von ø 42 liegt bewusst im Mittel.
