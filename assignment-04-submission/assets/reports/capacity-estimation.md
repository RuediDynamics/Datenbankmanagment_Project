# Capacity Estimation (Detailed)

**Assignment 04 – Exercise 4, Step 4.4**
Detaillierte Herleitung des Speicherbedarfs. Zusammenfassung im Hauptdokument
@tbl-capacity-estimation.

## Volumen-Treiber (aus Assignment 02/03)

| Treiber | Wert | Quelle |
|---|---|---|
| Events | 1 | A02 §4 (Single-Event-Scope) |
| Runden | 4 | A02 §Domäne |
| Ranges | 8 | Annahme (2 pro Runde, wiederverwendet) |
| Ziele je Range | 28 | A02 §Range |
| Schützen / Anmeldungen | 1.200 | A02 (1.200 Schützen) |
| Scorekarten | 1.200 × 4 = 4.800 | A03 Task 3 |
| ø Schüsse je Karte | 42 (Mittel 28–84) | A03 Task 3 Iteration |
| Schussergebnisse | ~201.600 | 4.800 × 42 |

## Zeilenbreiten-Methode

PostgreSQL-Heap-Tupel: 23 B Tupel-Header (auf 24 B aligned) + optionale Nullbitmap
+ Spaltendaten, jede Zeile auf 8 B aligned. Angesetzte Nettobreiten (gerundet):

| Datentyp | Bytes | Anmerkung |
|---|---|---|
| `bigint` | 8 | Surrogatschlüssel |
| `smallint` | 2 | – |
| `boolean` | 1 | – |
| `char(3)` | 4 | 3 + 1 Länge |
| `date` | 4 | – |
| `timestamptz` | 8 | – |
| `varchar(n)` | 1–4 + Inhalt | variabel, ø angesetzt |
| Tupel-Header | 24 | je Zeile |

## Detaillierte Tabellenberechnung

| Table | Rows | Row bytes (Header+Daten) | Heap (Rows×Bytes, +10 %) | Est. size |
|---|--:|--:|--:|--:|
| `nation` | 50 | 24+16 = 40 | 2.200 | ~8 KB (1 page) |
| `club` | 200 | 24+24 = 48 | 10.560 | ~16 KB |
| `official` | 40 | 24+40 = 64 | 2.816 | ~8 KB |
| `competition_category` | 30 | 24+32 = 56 | 1.848 | ~8 KB |
| `event` | 1 | 24+96 = 120 | 132 | ~8 KB |
| `round` | 4 | 24+24 = 48 | 211 | ~8 KB |
| `shooting_range` | 8 | 24+32 = 56 | 493 | ~8 KB |
| `target_station` | 224 | 24+16 = 40 | 9.856 | ~16 KB |
| `participant` | 1.200 | 24+48 = 72 | 95.040 | ~110 KB |
| `registration` | 1.200 | 24+56 = 80 | 105.600 | ~120 KB |
| `start_group` | 960 | 24+24 = 48 | 50.688 | ~64 KB |
| `start_group_member` | 4.800 | 24+16 = 40 | 211.200 | ~230 KB |
| `score_card` | 4.800 | 24+32 = 56 | 295.680 | ~350 KB |
| **`shot_result`** | **201.600** | **24+24 = 48** | **10.644.480** | **~11 MB** |
| `tournament_result` | 1.200 | 24+24 = 48 | 63.360 | ~64 KB |
| `tie_break` | 20 | 24+16 = 40 | 880 | ~8 KB |
| `tie_break_participant` | 50 | 24+16 = 40 | 2.200 | ~8 KB |
| `protest` | 30 | 24+176 = 200 | 6.600 | ~8 KB |
| `round_range` | 16 | 24+16 = 40 | 704 | ~8 KB |
| `target_distance` | 2.000 | 24+24 = 48 | 105.600 | ~110 KB |
| `scoring_rule` | 40 | 24+16 = 40 | 1.760 | ~8 KB |
| **Heap-Summe** | ~218.500 | – | **~12,7 MB** | – |

## Index- und Matview-Overhead

| Objekt | Schätzung | Basis |
|---|--:|---|
| PK-Index `shot_result` (24 B key × 201.600) | ~6–7 MB | dominanter Index |
| Übrige PK-/UNIQUE-Indizes | ~1 MB | kleine Tabellen |
| Explizite Sekundärindizes (inkl. `idx_shot_result_tie_break`) | ~2–3 MB | v. a. auf shot_result |
| `mv_tournament_ranking` + 2 Indizes | ~0,15 MB | 1.200 Zeilen |
| **Index/Matview-Summe** | **~9–11 MB** | – |

## Gesamt und Wachstum

| Szenario | Bedarf |
|---|--:|
| **Initial (WBHC 2027)** | **~24 MB** (Heap ~12,7 + Indizes ~10 + Matview) |
| 12 Monate (Single-Event, statisch) | ~24 MB (kein laufendes Wachstum) |
| Mehr-Event-Serie, 4 Events/Jahr | ~+100 MB/Jahr (je Event ~22–24 MB, dominiert von `shot_result`) |

**Sensitivität.** Der Gesamtwert hängt fast vollständig an der ø-Pfeilzahl je Ziel:
- Untergrenze (nur 1-Pfeil-3D, 28 Schüsse/Karte): ~134.000 Rows → ~8 MB Heap, ~19 MB gesamt.
- Obergrenze (nur 3-Pfeil, 84 Schüsse/Karte): ~403.000 Rows → ~19 MB Heap, ~40 MB gesamt.
- Ansatz ø 42 liegt bewusst mittig.

**Fazit.** Das Gesamtvolumen (< 50 MB selbst im Worst Case) passt vollständig in den
RAM der Annahme-Hardware (8 GB). I/O-orientiertes Tuning (Partitionierung,
Tablespaces) ist erst im Mehr-Event-Szenario relevant und dort als Handover-
Empfehlung (Partitionierung von `shot_result` nach `event_id`) dokumentiert.
