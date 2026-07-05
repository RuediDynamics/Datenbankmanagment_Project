# Assignment 04: Physical Database Design & Implementation

> **IFAA WBHC 2027 – PostgreSQL 16.** Physische Umsetzung des in Assignment 03
> validierten logischen Modells: DBMS-spezifisches Schema, Indizes, abgeleitete
> Objekte, Seed-Daten und ein ausführbarer Test- und Iterationsnachweis.

Hauptdokument: **[project-documentation.qmd](./project-documentation.qmd)**

## Verzeichnisstruktur

```text
assignment-04-submission/
├── project-documentation.qmd          # Quarto-Hauptdokument (bettet alle Sektionen ein)
├── readme.md                          # Dieses Übersichts-Dokument
├── sections/                          # Dokumentationskapitel (Exercises 1–7)
│   ├── task-1-physical-context.md         # Ex. 1: Ziel-DBMS, Umgebung, Annahmen
│   ├── task-2-physical-schema.md          # Ex. 2: Step 3.1–3.3 (Basisrelationen, Derived, Constraints)
│   ├── task-3-access-paths.md             # Ex. 3: Step 4.1–4.3 (Transaktionsanalyse, Indizes)
│   ├── task-4-capacity.md                 # Ex. 4: Step 4.4 (Kapazitätsschätzung)
│   ├── task-5-implementation.md           # Ex. 5: Implementierungspaket + Object Inventory
│   ├── task-6-test-report.md              # Ex. 6: Testbericht + Iterationsnachweis (initial→revised)
│   ├── task-7-reflection.md               # Ex. 7: Reflexion & Handover
│   └── task-8-team.md                     # Teamrollen & Aufgabenverteilung
├── sql/                               # Ausführbare Skripte (Flyway-Namensschema)
│   ├── V0.1_initial_database_schema.sql   # Schema + 21 Basistabellen, PKs
│   ├── V0.2_constraints.sql               # AKs, CHECKs, 28 FKs (ON DELETE/UPDATE)
│   ├── V0.3_indexes.sql                   # FK-/Transaktions-/Partial-Indizes
│   ├── V0.4_derived_objects.sql           # scoring_rule, Views, Materialized View, Funktionen
│   ├── V0.5_seed_data.sql                 # repräsentative, deterministische Testdaten
│   ├── V0.6_revised_physical_model.sql    # ITERATION: stored round_total + Trigger, atTarget-Trigger
│   └── R__test_cases.sql                  # wiederholbare Funktions-/Constraint-/Performance-Tests
└── assets/
    ├── diagrams/
    │   ├── physical-model-initial.puml    # initiales physisches Modell
    │   └── physical-model-revised.puml    # revidiertes physisches Modell (Iterationen A & B)
    ├── plans/
    │   └── query-plan-evidence/           # EXPLAIN-Prüfvorlagen (P1–P3)
    └── reports/
        ├── transaction-relation-matrix.md # Ex. 3 Detailmatrix
        ├── index-catalog.md               # Ex. 3 Index-Detailkatalog
        ├── capacity-estimation.md         # Ex. 4 Detailberechnung
        └── test-report.md                 # Ex. 6 Ausführungsanleitung + Evidenz
```

## Ziel-DBMS & Umgebung

- **PostgreSQL 16** (lokal oder `postgres:16`-Container), UTF-8.
- Migrationen im **Flyway-Namensschema** (`V0.x__…`, `R__…`).

## Reproduktion

```bash
createdb wbhc2027
for f in sql/V0.1_* sql/V0.2_* sql/V0.3_* sql/V0.4_* sql/V0.5_* sql/V0.6_*; do
  psql -d wbhc2027 -v ON_ERROR_STOP=1 -f "$f"
done
psql -d wbhc2027 -v ON_ERROR_STOP=1 -f sql/R__test_cases.sql   # 14/14 PASS erwartet
```

Diagramme rendern (PlantUML) — erzeugt die von `project-documentation.qmd`
referenzierten `.svg`-Dateien:

```bash
plantuml -tsvg assets/diagrams/physical-model-initial.puml \
                assets/diagrams/physical-model-revised.puml
```

> **Build-Hinweis:** Committet werden die `.puml`-Quellen (wie in Assignment 03).
> Die `.svg`-Dateien sind vor dem Quarto-Render einmalig zu generieren (Befehl
> oben); erst dann lösen die `![…](…svg)`-Referenzen im Hauptdokument korrekt auf.

## Highlights der Abgabe

- **Step 3 vollständig:** 21 Basistabellen, alle 112 Constraints als
  UNIQUE/CHECK/FK/Trigger abgebildet, 28 FKs mit referenziellen Aktionen aus A03.
- **Derived data (Step 3.2):** `age`, `pointValue`, `numberOfTargets` computed;
  `roundTotal` iteriert (computed → stored/Trigger); `totalPoints`/`rankPosition`
  materialisiert.
- **Access design (Step 4):** transaktionsgetriebene Indizes inkl. partieller und
  Covering-Indizes; bewusst minimaler Indexdruck auf der Volumen-Tabelle `shot_result`.
- **Testnachweis (Ex. 6):** 14 selbstprüfende Fälle (8 funktional, 6 Constraint über
  4 Kategorien) + **zwei sichtbare Design-Iterationen** (Performance & Korrektheit).

## Team & Aufgabenverteilung

| Name | Teamrolle | Zuständigkeit in Assignment 04 |
|---|---|---|
| **Noah M. (Notschge)** | Maintainer | Ex. 1 Kontext + Ex. 2 Basisrelationen (`V0.1`) + Object Inventory |
| **Niklas R. (Rüdi)** | Maintainer | Physische Diagramme + Ex. 2 Derived Data (`V0.4`) + Iteration A (`V0.6`) |
| **Jan S. (Jan)** | Worker | Ex. 3 Transaktionsanalyse/Indizes (`V0.3`) + Ex. 4 Kapazität |
| **Niklas K. (Katz)** | Worker | Ex. 2 Constraints/FKs (`V0.2`) + Ex. 6 Tests + Iteration B + Ex. 7 Reflexion |
