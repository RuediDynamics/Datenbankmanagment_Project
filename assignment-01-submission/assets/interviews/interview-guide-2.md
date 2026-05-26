# Interview Guide 2: Bogenschütze / Teilnehmer

**Interviewpartner:** Maria Weiss, Adult Female Bowhunter Compound (AFBH-C), Österreich

**Interviewziel:** Verstehen, welche persönlichen Turnierdaten ein Teilnehmer selbst einsehen und prüfen können muss, und welche Anforderungen an Klassifizierung und Startinformation bestehen.

## Interview Leitfaden (Interview Guide)

### Offene, datenfokussierte Fragen
1. Welche Informationen über sich selbst und Ihren Start möchten Sie vor und während des Turniers jederzeit einsehen können?
2. Wie und wann erfahren Sie, in welcher Gruppe Sie starten, an welchem Ziel und auf welcher Range?
3. Welche Daten müssen für Ihre Anmeldung korrekt hinterlegt sein, damit Sie zum Schießen zugelassen werden?

### Geschlossene Fragen
4. Möchten Sie Ihre Tagesergebnisse und die aktuelle Ranglistenanzeige digital einsehen können? (Ja/Nein)
5. Schießen Sie in mehreren Stilen und benötigen deshalb separate Ergebnisaufzeichnungen je Stil? (Ja/Nein)

### Datensicherheit / Zugriffsrechte
6. Welche Ihrer persönlichen Daten sollen für andere Teilnehmer sichtbar sein (z. B. Name und Nation in der Rangliste)?

### Sorgen / Einschränkungen / Risiken
7. Welche Fehler in der Anmeldung oder Ergebniserfassung würden Sie am meisten belasten?

---

## Datenanforderungen (Data Requirements)

| Datenentität / Thema | Benötigte Attribute | Operationen (C/R/U/D) |
|---|---|---|
| Teilnehmerprofil | Teilnehmer-ID, Vorname, Nachname, Geburtsdatum, Nation, Verein, Schießstil, Division, Klasse (A/B/C) | C, R, U |
| Klassifizierungskarte | Score-Record-ID, Teilnehmer, Datum, Veranstaltung, Runde, Ergebnis, Klasse, Verifikation durch Offizielle | R |
| Startgruppe | Gruppen-ID, Mitglieder (Schützen-IDs), zugewiesene Range, Starttarget, Tag | R |
| Eigene Ergebnisse | Ergebnis-ID, Runde, Ziel-Nummer, Pfeil-Nummer (1/2/3), Trefferzone (Kill/Vital/Wound/Miss), Punktwert | R |
| Taggesamt / Gesamtergebnis | Tagesergebnis, Gesamtpunkte über alle Runden, Ranglistenposition je Stil/Division/Klasse | R |
| Zeitplan | Rundendatum, Startzeit, Range-Bezeichnung | R |

---

## Interview Zusammenfassung (Interview Summary)

- Der Schütze braucht vor allem lesenden Zugriff auf seine eigenen Daten.
- Korrekte Stilangabe und Klassifizierungsklasse sind Voraussetzung für die Startzulassung.
- Die Startgruppe und das Starttarget müssen täglich klar und frühzeitig kommuniziert werden.
- Score-Seeding bedeutet, dass Gruppen ab Tag 2 nach Gesamtergebnis neu zusammengestellt werden.
- Mehrfachstarts in verschiedenen Stilen sind möglich, müssen aber separat erfasst werden.

---

## Auswirkungen auf die Datenbank (Implications for the Database)

- Das System muss Teilnehmer eindeutig einer Stil/Divisions-Kombination zuordnen und mehrere Stile pro Person unterstützen.
- Das Geburtsdatum muss gespeichert und validiert werden (Altersnachweis für Junior/Cub/Veteran/Senior ist Pflicht).
- Ergebnisse müssen auf Ziel-Ebene (nicht nur als Tagesgesamtwert) gespeichert werden, um Tie-Break-Regeln anwenden zu können.
