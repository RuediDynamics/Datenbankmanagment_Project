# Datenbankmanagement Projekt

> **Schulprojekt:** Datenbankentwicklung im 2. Semester

Dieses Repository dient als zentrale Ablage für alle Aufgaben und Abgaben unseres Datenbankmanagement-Projekts. Das Hauptdokument für die gesamte Projektdokumentation finden Sie hier:

**[Zentrales Hauptdokument (project-documentation.qmd)](./project-documentation.qmd)**

---

## Voraussetzungen / Requirements

Um die Dokumentation lokal anzuschauen, zu bearbeiten oder zu rendern, wird folgende Komponente benötigt:

1. **Quarto CLI** (Version 1.4+ empfohlen): Ermöglicht das lokale Rendern der `.qmd`-Dateien zu HTML/PDF.
   * Download: [quarto.org/docs/get-started/](https://quarto.org/docs/get-started/)

---

## Abgaben & Projekt-Dokumentation

Hier finden Sie die direkten Verknüpfungen zu den jeweiligen Abgaben und deren Haupt-Dokumenten:

### [Assignment 01: Personas, Stakeholder Interviews, and Reflection](./assignment-01-submission/project-documentation.qmd)
*   **Beschreibung:** Ermittlung von Anforderungen, Definition von Stakeholder-Personas und Durchführung strukturierter Interviews zur Vorbereitung der Datenbankentwicklung (WBHC 2027 in Bad Waldsee).
*   **Hauptdokument:** [project-documentation.qmd](./assignment-01-submission/project-documentation.qmd)

### [Assignment 02: Conceptual Data Modeling](./assignment-02-submission/project-documentation.qmd)
*   **Beschreibung:** Erstellung eines konzeptuellen Datenmodells (UML in PlantUML), Datenwörterbuch, Transaktionsvalidierung und Reflexion.
*   **Hauptdokument:** [project-documentation.qmd](./assignment-02-submission/project-documentation.qmd)

### [Assignment 03: Logical Database Design](./assignment-03-submission/project-documentation.qmd)
*   **Beschreibung:** Ableitung des logischen Relationenschemas aus dem konzeptuellen Modell, Normalisierung bis 3NF/BCNF, Transaktions-Mapping/Validierung und Spezifikation von Integritätsbedingungen.
*   **Hauptdokument:** [project-documentation.qmd](./assignment-03-submission/project-documentation.qmd)

---

## Repository-Struktur

Die Ordnerstruktur des Projekts ist wie folgt aufgebaut:

```text
.
├── README.md                          # Dieses Haupt-Dokument (Index & Navigation)
├── assignment-01-submission/          # Abgabeordner für Assignment 01
│   ├── project-documentation.qmd       # Hauptabgabedokument (Aufgabenübersicht)
│   └── assets/                        # Ergänzende Ressourcen
│       ├── personas/                  # Ausgelagerte Personas
│       │   ├── developer-persona.md
│       │   ├── stakeholder-persona-1.md
│       │   ├── stakeholder-persona-2.md
│       │   └── stakeholder-persona-3.md
│       ├── interviews/                # Ausgelagerte Interview-Leitfäden & Summaries
│       │   ├── interview-guide-1.md
│       │   ├── interview-guide-2.md
│       │   └── interview-guide-3.md
│       ├── images/                    # Persona-Avatarbilder
│       │   ├── developer-avatar.png
│       │   ├── stakeholder-1-avatar.png
│       │   ├── stakeholder-2-avatar.png
│       │   └── stakeholder-3-avatar.png
│       └── readme.md                  # Reviewer-Anleitung für die Assets
├── assignment-02-submission/          # Abgabeordner für Assignment 02
│   ├── project-documentation.qmd       # Hauptabgabedokument (Aufgabenübersicht)
│   └── assets/                        # Ergänzende Ressourcen
│       ├── diagrams/                  # UML-Klassendiagramme (PlantUML)
│       │   ├── conceptual-model-initial.puml
│       │   ├── conceptual-model-initial.svg
│       │   ├── conceptual-model-final.puml
│       │   ├── conceptual-model-final.svg
│       │   ├── T1_T2_Pathways.puml
│       │   ├── T1_T2_Pathways.svg
│       │   └── ...
│       └── readme.md                  # Reviewer-Anleitung für die Assets
└── assignment-03-submission/          # Abgabeordner für Assignment 03
    ├── project-documentation.qmd       # Hauptabgabedokument (Aufgabenübersicht)
    ├── readme.md                      # Übersichts-Dokument für Assignment 03
    ├── sections/                      # Einzelne Dokumentationskapitel (Tasks 1-6)
    └── assets/                        # Ergänzende Ressourcen
        ├── diagrams/                  # UML-Klassendiagramme (PlantUML & SVG)
        └── constraints/               # Tabellarische Integritätsbedingungen
```
