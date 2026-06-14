# Interview Guide 3: Ergebnisbeauftragte / Registrierung

**Interviewpartner:** Sandra Klein, Ergebnisbeauftragte und Registrierungsleiterin, DFBV

**Interviewziel:** Verstehen, wie Anmeldedaten geprüft, Schussergebnisse erfasst und Ranglisten nach den IFAA-Regeln für die vier WBHC-Runden korrekt berechnet werden.

## Interview Leitfaden (Interview Guide)

### Offene, datenfokussierte Fragen
1. Welche Daten müssen Sie bei der Anmeldung eines Schützen prüfen, und welche Felder sind für die Startzulassung zwingend notwendig?
2. Wie werden die Schussergebnisse nach jedem Schießtag erfasst, und welche Angaben stehen auf einer ausgefüllten Scorekarte?
3. Wie berechnen Sie die Rangliste, und was passiert bei einem Gleichstand (Tie)?

### Geschlossene Fragen
4. Unterscheiden sich die Punktesysteme je nach Rundentyp (Unmarked Animal 3-Pfeil vs. 3D Standard 2-Pfeil vs. 3D Hunting 1-Pfeil)? (Ja/Nein)
5. Müssen Ranglisten nach Stil, Division und Klasse (A/B/C) getrennt ausgewiesen werden? (Ja/Nein)

### Datensicherheit / Zugriffsrechte
6. Welche Daten der Scorekarte dürfen nur intern einsehbar sein, und was wird öffentlich auf der Anzeigetafel gezeigt?

### Sorgen / Einschränkungen / Risiken
7. Welche Fehlerquellen bei der Eingabe von Schussergebnissen bereiten Ihnen die größten Sorgen?

---

## Datenanforderungen (Data Requirements)

| Datenentität / Thema | Benötigte Attribute | Operationen (C/R/U/D) |
|---|---|---|
| Anmeldung | Anmelde-ID, Teilnehmer, Stil, Division, Klasse, Nation, Verein, Startgebühr bezahlt, Ausrüstung geprüft | C, R, U |
| Scorekarte | Karten-ID, Teilnehmer, Runde, Ziel-Nr. (1–28), Pfeil-Nr. (1/2/3), Trefferzone, Punktwert, Target Captain (Unterzeichner) | C, R, U |
| Rundengesamtergebnis | Teilnehmer, Runde, Gesamtpunkte je Runde | R (berechnet) |
| Turnierergebnis | Teilnehmer, Summenpunkte aller Runden, Ranglistenposition (je Stil/Division/Klasse), Gleichstandsmarkierung | R (berechnet) |
| Tie-Break | Tie-Break-ID, beteiligte Schützen, 3D-Ziel-Gruppe, Pfeilergebnis je Schuss, Ergebnis | C, R |
| Klassifizierung | Teilnehmer, Stil, gültige Klasse, Grundlage (zwei Scores im 12-Monatszeitraum) | R, U |

---

## Interview Zusammenfassung (Interview Summary)

- Jede Scorekarte enthält für jedes der 28 Ziele die Trefferzone und die genaue Pfeilnummer (1., 2. oder 3. Pfeil), weil der Punktwert davon abhängt.
- Die drei Rundentypen haben unterschiedliche Punktesysteme: Unmarked Animal (20/16/12 Kill, 18/14/10 Wound), 3D Standard 2-Pfeil (10/8/5), 3D Hunting 1-Pfeil (20/16/10).
- Ranglisten müssen immer nach Stil, Division und Klasse getrennt berechnet werden.
- Bei Gleichstand gilt ein Shoot-off über drei 3D-Ziele (je zwei Pfeile), danach Sudden Death.
- Klassifizierungen basieren auf den zwei höchsten Scores im vorangegangenen 12-Monats-Zeitraum.

---

## Auswirkungen auf die Datenbank (Implications for the Database)

- Die Datenbank muss Schussergebnisse auf Ebene einzelner Pfeile speichern (Ziel-Nr., Pfeil-Nr., Trefferzone, Punkte) – nicht nur als Zielsumme.
- Das Punktesystem muss dynamisch je Rundentyp angewendet werden; eine einfache Gesamtsumme reicht nicht.
- Die Klassifizierungslogik (zwei Scores im 12-Monatszeitraum, Aufstieg bei zwei Scores in höherer Klasse) muss durch das System unterstützt oder zumindest überprüfbar gemacht werden.
