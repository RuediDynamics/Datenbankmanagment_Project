## Task 1: Physical Design Context {#sec-task1-physical-context}

**Exercise 1 – Define Target DBMS, Environment, and Assumptions**
(Connolly & Begg, Kap. 18, Step 3 Vorbereitung)

Diese Sektion definiert den technischen Rahmen, in dem das in Assignment 03
validierte logische Modell physisch umgesetzt wird. Alle nachfolgenden
Entwurfsentscheidungen (Datentypen, Constraints, Indizes, abgeleitete Objekte)
sind auf diesen Kontext und auf die Transaktionen T1–T8 (Assignment 02) sowie die
Constraint-Spezifikation C1–C112 (Assignment 03) rückführbar.

### Ziel-DBMS und Umgebung {#sec-t1p-dbms}

| Aspekt | Festlegung | Begründung / Bezug |
|---|---|---|
| **DBMS** | PostgreSQL 16 | Unterstützt alle benötigten Mechanismen nativ: `GENERATED ALWAYS AS IDENTITY`, `CHECK`, zusammengesetzte `FOREIGN KEY`, partielle Indizes, `MATERIALIZED VIEW`, Trigger/PL-pgSQL. Frei, reproduzierbar, weit verbreitet. |
| **Migrations-Framework** | Flyway-Namensschema (`V0.x__…`, `R__…`) | Versionierte, wiederholbare Schemaverwaltung (Assignment-Vorgabe). |
| **Ausführungsumgebung** | Lokal / Container (Docker `postgres:16`), Linux/Windows, UTF-8, Locale `en_US.UTF-8` | Entwicklungs- und Prüfumgebung; kein produktives Sizing nötig (Single-Event, siehe Annahmen). |
| **Hardware-Annahme** | 2–4 vCPU, 8 GB RAM, SSD; `shared_buffers` Default | Datenvolumen < 100 MB (siehe @sec-task4-capacity) passt vollständig in den Cache; I/O ist unkritisch. |
| **Zeichensatz / Kollation** | UTF-8, deterministische Kollation | Internationale Namen (Nation, Teilnehmer) korrekt speicherbar. |
| **Zeitzone** | `TIMESTAMPTZ` in UTC | Audit-Zeitstempel (Klassifizierung, Protest) zeitzonensicher. |

### Namenskonventionen für physische Objekte {#sec-t1p-naming}

Die logischen PascalCase-Namen aus Assignment 03 werden auf eine konsistente
physische Konvention abgebildet:

| Objektart | Konvention | Beispiel |
|---|---|---|
| Tabelle | `snake_case`, Singular | `score_card`, `competition_category` |
| Primärschlüssel-Constraint | `pk_<tabelle>` | `pk_score_card` |
| Fremdschlüssel | `fk_<kind>_<parent/spalte>` | `fk_score_card_registration` |
| Unique / Alternate Key | `uq_<tabelle>_<spalten>` | `uq_registration_participant_event` |
| Check-Constraint | `ck_<tabelle>_<regel>` | `ck_round_type` |
| Index | `idx_<tabelle>_<spalten>` | `idx_score_card_round` |
| Trigger / Funktion | `trg_…` / `fn_…` | `trg_shot_result_total`, `fn_refresh_rankings` |
| View / Materialized View | `v_…` / `mv_…` | `v_score_card_total`, `mv_tournament_ranking` |
| Surrogatschlüssel | `<tabelle>_id BIGINT GENERATED ALWAYS AS IDENTITY` | `event_id` |

**Reservierte-Wort-Behandlung:** Die logische Relation `Range` kollidiert mit dem
SQL-Schlüsselwort `RANGE` (Fensterfunktions-Frames). Sie wird physisch als
`shooting_range` umgesetzt, um Quoting zu vermeiden — eine bewusste DBMS-spezifische
Mapping-Entscheidung (dokumentiert in @sec-task2-physical-schema).

### Explizite Annahmen (Volumen, Wachstum, Nebenläufigkeit) {#sec-t1p-assumptions}

| # | Annahme | Wert / Aussage | Quelle |
|---|---|---|---|
| A1 | **Single-Event-Scope** | Genau eine `Event`-Instanz (WBHC 2027), 4 Runden. | A02 §4, A03 Task 5 |
| A2 | **Teilnehmervolumen** | ~1.200 Schützen, ~1.200 Anmeldungen. | A02 (1.200 Schützen) |
| A3 | **Scoring-Volumen** | ~4.800 Scorekarten (1.200 × 4 Runden), ~270.000 Schussergebnisse. | A03 Task 3 (Iteration) |
| A4 | **Nebenläufigkeit** | Niedrig–mittel: 5–15 gleichzeitige Erfassungs-Clients (Ergebnisbeauftragte) während der Scoring-Fenster. | A01 Stakeholder-Rollen |
| A5 | **Zugriffsmuster** | Schreiblastig während der Runden (T4), leselastig bei Ranglisten/Export (T5, T8). | A03 Task 3 Matrix |
| A6 | **Wachstum** | Kurzfristig statisch (Einzelveranstaltung); mittelfristig optional Mehr-Event-Serie (siehe @sec-task4-capacity). | A03 Task 5 Future Growth |
| A7 | **Datenschutz/RBAC** | Zugriffskontrolle liegt in der Anwendungsschicht; nicht Teil dieses Schemas. | A02 §4 Konflikt |

### Einschränkungen und Design-relevante Limitierungen {#sec-t1p-limits}

- **DBMS-seitig nicht direkt erzwingbare Regeln.** Einige Business-Constraints aus
  Assignment 03 sind nicht als einfache `CHECK`-Bedingung abbildbar, weil sie
  *zeilenübergreifend* prüfen (z. B. C26 `round_date` im Event-Fenster, C103
  `start_target` ≤ Anzahl Ziele der Range, C105 Pfeil-Sequenz, C110 Protest-Fenster).
  Für diese wird eine **Fallback-Strategie** dokumentiert (Trigger bzw.
  Anwendungsschicht; @sec-t2p-step33).
- **Zusammengesetzter Fremdschlüssel über zwei Tabellen (C86 `atTarget`).** Der
  Zielbezug eines Schusses hängt von `score_card.range_id` **und**
  `shot_result.target_number` ab; ein spaltenlokaler FK ist nicht möglich (vgl. A03
  Task 2 Normalisierung). Umsetzung als **Constraint-Trigger** (Iteration B,
  @sec-task6-test-report).
- **`CURRENT_DATE` in `CHECK` (C99).** PostgreSQL akzeptiert die Bedingung, prüft
  sie jedoch nur zum Schreibzeitpunkt (nicht retroaktiv) — für die Geburtsdatums-
  Plausibilität ausreichend und dokumentiert.
- **Kein produktives Sizing.** Physisches Tuning (Partitionierung, Tablespaces)
  ist bei < 100 MB Gesamtvolumen nicht erforderlich und bewusst ausgespart
  (@sec-task7-reflection, Handover).
