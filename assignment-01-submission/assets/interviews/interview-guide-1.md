# Interview Guide 1: Turnierdirektor

**Interviewpartner:** Klaus Brenner, Turnierdirektor WBHC 2027, DFBV

**Interviewziel:** Verstehen, welche Daten und Strukturen der Turnierdirektor benötigt, um die vier Schießrunden der WBHC (2x Unmarked Animal Round, 1x 3D Standard Round, 1x 3D Hunting Round) regelkonform zu planen, zuzuweisen und zu überwachen.

## Interview Leitfaden (Interview Guide)

### Offene, datenfokussierte Fragen
1. Welche Informationen müssen Sie zu jedem Teilnehmer vor dem Turnier kennen, damit der Schießplan korrekt erstellt werden kann?
2. Wie wird die Aufteilung der Schützen auf Ranges und Gruppen organisiert, und welche Daten fließen dabei ein?
3. Welche Ergebnisdaten brauchen Sie täglich, um den Turnierablauf zu steuern und bei Konflikten entscheiden zu können?

### Geschlossene Fragen
4. Müssen Schützen innerhalb derselben Division und desselben Stils immer auf derselben Range schießen? (Ja/Nein)
5. Sollen Protests und Regelentscheidungen im System dokumentiert werden? (Ja/Nein)

### Datensicherheit / Zugriffsrechte
6. Welche Daten dürfen nur Sie und die IFAA-Repräsentanten einsehen, und was darf öffentlich angezeigt werden?

### Sorgen / Einschränkungen / Risiken
7. Was wäre das größte Problem, wenn das System während des Turniers ausfällt oder falsche Daten liefert?

---

## Datenanforderungen (Data Requirements)

| Datenentität / Thema | Benötigte Attribute | Operationen (C/R/U/D) |
|---|---|---|
| Veranstaltung | Event-ID, Name, Datum, Austragungsort, Veranstalter, IFAA-Referenz | C, R, U |
| Runde | Runden-ID, Rundentyp (Unmarked Animal 3-Pfeil / 3D Standard 2-Pfeil / 3D Hunting 1-Pfeil), Datum, zugewiesene Range | C, R, U |
| Range / Strecke | Range-ID, Bezeichnung, Anzahl Ziele (28 pro Runde), zugewiesene Divisionen | C, R, U |
| Ziel / Target Station | Ziel-ID, Ziel-Nummer (1–28), Gruppe (1–4), maximale Schussdistanz je Division | C, R, U |
| Offizieller | Offizielle-ID, Name, Funktion (Turnierdirektor / TCO etc.), zugewiesene Range | C, R, U, D |
| Protest / Regelentscheid | Protest-ID, Schütze, Datum, Beschreibung, Entscheidung, entscheidender Offizieller | C, R |

---

## Interview Zusammenfassung (Interview Summary)

- Der Turnierdirektor braucht vor allem strukturierte Übersichten, keine Einzeldatensätze.
- Die korrekte Zuordnung von Stilen und Divisionen zu Ranges ist entscheidend für die Regelkonformität.
- Schützen derselben Division sollen gemäß IFAA-Regeln gemeinsam auf derselben Range schießen.
- Protests und Regelentscheidungen müssen nachvollziehbar protokolliert werden.
- Exportfunktionen für offizielle IFAA-Ergebnislisten sind zwingend erforderlich.

---

## Auswirkungen auf die Datenbank (Implications for the Database)

- Das System muss Runden, Ranges und Zielstationen als eigenständige, miteinander verknüpfte Entitäten abbilden.
- Die Divisionen- und Stilzuordnung muss erzwungen werden (kein Schütze ohne gültige Stil/Divisions-Kombination).
- Ein Protokoll für Regelentscheidungen und Disqualifikationen muss integriert sein.
