# Assignment 03: Logischer Datenbankentwurf (Logical Database Design)


## Verzeichnisstruktur (Folder Structure)

```text
assignment-03-submission/
├── project-documentation.qmd     # Quarto-Hauptdokument (bettet alle Sektionen ein)
├── readme.md                      # Dieses Übersichts-Dokument
├── sections/                      # Einzelne Dokumentationskapitel
│   ├── task-1-derive-relations.md       # Ableitung des Relationenschemas aus dem ER-Modell
│   ├── task-2-normalization.md          # Normalisierung (Worked Example & 3NF/BCNF-Prüfung)
│   ├── task-3-transaction-validation.md # Validierung gegen die 8 Kerntransaktionen (inkl. Iteration)
│   ├── task-4-integrity-constraints.md # Zusammenfassung der Integritätsbedingungen
│   ├── task-5-review-growth.md         # Review mit Stakeholdern & Zukunftsfähigkeit (Future Growth)
│   └── task-6-team-division.md          # Teamrollen & Aufgabenverteilung
└── assets/                        # Diagramme und Detailtabellen
    ├── diagrams/
    │   ├── logical-model-initial.puml   # PlantUML-Quelle des initialen logischen Modells
    │   ├── logical-model-initial.svg    # Gerendertes UML-Diagramm (initial)
    │   ├── logical-model-normalized.puml# PlantUML-Quelle des normalisierten (3NF+) Modells
    │   └── logical-model-normalized.svg # Gerendertes UML-Diagramm (normalisiert, >= 3NF)
    └── constraints/
        ├── constraint-specification-table.md # Detailtabelle aller 112 Integritätsbedingungen
        └── referential-actions-table.md       # Detaillierte Fremdschlüssel-Strategien (ON DELETE / UPDATE)
```

## Team & Aufgabenverteilung (Team & Division of Work)

| Name | Teamrolle | Zuständigkeit in Assignment 03 |
|---|---|---|
| **Noah M. (Notschge)** | Maintainer | Task 1 (Ableitung der Relationen, Mapping-Dokumentation) + Task 5 (Review & Future Growth) |
| **Niklas R. (Rüdi)** | Maintainer | Task 1/2 UML-Diagramme (PlantUML) + Task 2 (Normalisierung bis 3NF) |
| **Jan S. (Jan)** | Worker | Task 3 (Transaktions-zu-Relation-Matrix + Iterationsnachweis) |
| **Niklas K. (Katz)** | Worker | Task 4 (Integritätsbedingungen: Tabellen) + Task 6 (Koordination/Zusammenführung) |
