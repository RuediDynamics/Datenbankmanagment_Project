# Assignment 01: Personas, Stakeholder Interviews, and Reflection

Fact-Finding and Stakeholder Analysis for Database Development

---

## Task 1: Database Developer Persona

### Alex Rivera

**Rollenbezeichnung:** Datenbankentwickler

![Alex Rivera](./assets/Alex_Persona.jpg)

#### Hintergrund

Alex hat Wirtschaftsinformatik studiert und arbeitet seit 4 Jahren als Datenbankentwickler. Seine Karriere begann er als Junior-Analyst in einem Logistikunternehmen. Dort entwarf er seine ersten relationalen Datenbanken. Danach arbeitete er an Projekten im Einzelhandel und im Gesundheitswesen. Dabei sammelte er Erfahrung mit Datenbanken für tägliche Abläufe und Berichte. Sein aktuelles Projekt ist die Entwicklung eines Datenbanksystems für die IFAA World Bowhunter Championships (WBHC) 2027 in Bad Waldsee – eine Veranstaltung mit rund 1.200 Bogenschützen aus aller Welt.

#### Kernaufgaben

- Kundenanforderungen sammeln und analysieren
- Entity-Relationship-Diagramme erstellen und daraus Datenbankstrukturen entwickeln
- SQL-Abfragen, gespeicherte Prozeduren und Views schreiben und verbessern
- Mit Frontend-Entwicklern zusammenarbeiten, damit die Datenmodelle passen
- Datenbankstrukturen dokumentieren, damit andere das System später warten oder erweitern können

#### Schlüsselkompetenzen

**Technisch**
- SQL
- Datenmodellierung und Normalisierung
- Arbeiten mit ER-Diagramm-Programmen
- Grundkenntnisse im ETL-Pipeline-Design
- Nutzung von Git zur Versionskontrolle

**Sozial**
- Technische Anforderungen verständlich aus Kundengesprächen ableiten
- Aktives Zuhören
- Klare Kommunikation bei Teamarbeit

#### Ziele

- Eine saubere und gut strukturierte Datenbank entwickeln, die die Abläufe der WBHC 2027 korrekt abbildet
- Eine Datenbank erstellen, die auch für nicht-technische Personen wie Turnieroffizielle verständlich ist
- Eine Dokumentation schreiben, damit das System leicht gewartet oder für künftige Weltmeisterschaften erweitert werden kann
- Mehr über Performance-Optimierung lernen und später Lead-Datenbankarchitekt werden

#### Frustrationen / Herausforderungen

- **Unklare Anforderungen:**
  Organisatoren erklären oft ihre bestehende Arbeitsweise, aber nicht genau, was sie wirklich brauchen. Bei der WBHC ist es schwierig, die genauen Datenpunkte für mehrstufige Schießformate (Unmarked Animal Round, 3D Standard Round, 3D Hunting Round) früh zu erkennen.

- **Schleichende Anforderungsänderungen:**
  Nach der Planung kommen oft neue Wünsche hinzu. Zum Beispiel können Regeländerungen der IFAA oder zusätzliche Anforderungen des Veranstalters DFBV das Datenbankschema nachträglich beeinflussen.

- **Kommunikationslücken:**
  Technische Datenbankthemen einfach für Turnieroffizielle oder freiwillige Helfer zu erklären, die wenig Technikkenntnisse haben, ist oft schwierig und zeitaufwendig.

- **Inkonsistente Quelldaten:**
  Beim Übernehmen von Anmeldedaten aus verschiedenen nationalen Verbänden gibt es oft unterschiedliche Formate oder fehlende Klassifizierungsangaben. Diese Daten müssen zuerst bereinigt werden.

---

## Task 2: Stakeholder Role Identification

### Kontext

Das Datenbankprojekt unterstützt die Organisation und Durchführung der IFAA World Bowhunter Championships (WBHC) 2027 in Bad Waldsee, Deutschland. Das System muss Teilnehmer, Nationen, Vereine, Schießrunden, Zielstationen, Ergebnisse, Ausrüstungskategorien und offizielle Funktionsträger verwalten. Die Veranstaltung wird vom Deutschen Feldbogen Sportverband e.V. (DFBV) nach den Regeln der International Field Archery Association (IFAA) ausgerichtet.

### Identifizierte Stakeholder-Rollen

| Rolle | Kurzbeschreibung |
|---|---|
| Turnierdirektor | Verantwortet die Gesamtorganisation, genehmigt Schießpläne und trägt die finale Verantwortung für Regelkonformität |
| Bogenschütze / Teilnehmer | Meldet sich an, schießt in einer festen Stil- und Divisionskombination und benötigt Zugriff auf eigene Ergebnisse und Startinformationen |
| Feldkapitän / Streckenmarshall | Teilt Gruppen ein, überwacht die Strecken, entscheidet bei Regelfragen vor Ort und verwaltet den Ablauf auf der Range |
| Ergebnisbeauftragter / Registrierung | Nimmt Anmeldungen entgegen, prüft Klassifizierungskarten, erfasst Schussergebnisse und berechnet Ranglisten |

### Begründung der Rollenwahl

**Turnierdirektor:**
Der Turnierdirektor hat die höchste Entscheidungsbefugnis. Er genehmigt Rundenpläne, koordiniert alle offiziellen Funktionsträger und ist verantwortlich für die korrekte Anwendung der IFAA-Regeln. Er benötigt deshalb Zugriff auf die meisten Datenbereiche des Systems.

**Bogenschütze / Teilnehmer:**
Der Schütze ist der zentrale Nutzer der Veranstaltung. Alle Kernfunktionen des Systems – Anmeldung, Startgruppenzuweisung, Ergebniserfassung und Rangliste – drehen sich um seine Daten. Mit rund 1.200 erwarteten Teilnehmern ist diese Rolle die volumenmäßig größte.

**Feldkapitän / Streckenmarshall:**
Der Feldkapitän übernimmt operative Aufgaben auf den Ranges: Gruppenzuteilung, Starttarget-Festlegung und Kontrolle des Schießablaufs. Er braucht vor allem aktuelle Gruppen- und Ablaufinformationen.

**Ergebnisbeauftragter / Registrierung:**
Diese Rolle arbeitet am häufigsten mit dem System. Sie erfasst Anmeldedaten, prüft Klassifizierungen, trägt Schussergebnisse ein und erstellt Ranglisten. Fehler in dieser Rolle wirken sich direkt auf die Turnierauswertung aus.

### Einordnung der Datenbedürfnisse

**Breiteste Datenbedürfnisse:**
**Turnierdirektor** – Er braucht Zugriff auf fast alle Bereiche: Teilnehmer, Nationen, Runden, Ergebnisse und Offizielle. Er nutzt die Daten vor allem für Entscheidungen und Gesamtübersichten.

**Meiste tägliche Datenarbeit:**
**Ergebnisbeauftragter / Registrierung** – Diese Rolle arbeitet am häufigsten mit dem System. Sie führt viele wiederkehrende Aufgaben aus – Anmeldung, Klassifizierungsprüfung, Ergebniserfassung – und braucht schnellen und zuverlässigen Zugriff auf alle Teilnehmerdaten.

---

## Task 3: Stakeholder Personas

### Persona 1: Turnierdirektor

| Element | Beschreibung |
|---|---|
| **Name & Foto** | Klaus Brenner <br> <img src="./assets/Filialleiter_Stakeholder.png" alt="Turnierdirektor" width="220"/> |
| **Rolle** | Turnierdirektor WBHC 2027, DFBV |
| **Kurzprofil** | 53 Jahre, langjähriger Funktionär des DFBV, hat bereits mehrere nationale und internationale IFAA-Turniere geleitet. Kennt die IFAA-Regeln sehr gut und ist verantwortlich für die Einhaltung aller Vorschriften gegenüber der IFAA. |
| **Aufgaben** | Gesamtkoordination der Veranstaltung, Genehmigung von Schießplänen und Streckenaufbauten, Benennung und Beaufsichtigung aller Turnieroffizielle (Feldkapitäne, TCO, Streckenmarshalls), Entscheidung bei Regelkonflikten, Kommunikation mit der IFAA. |
| **Daten, die er nutzt** | Teilnehmerliste nach Nation und Stil, Rundenplan und Streckenzuteilung, Tagesergebnisse und Gesamtranglisten, Status der Ausrüstungskontrollen, Statistiken über Gruppen und Starts. |
| **Was er braucht** | Gesamtübersicht aller aktiven Runden und Gruppen, aktuelle Ranglisten je Division und Stil, Exportfunktion für offizielle Ergebnislisten, Protokolle zu Regelentscheidungen und Protests. |
| **Sorgen** | Das System darf den Turnierablauf nicht verzögern. Falsch erfasste Stile oder Divisionen können zur Disqualifikation führen. Regelverstöße müssen nachvollziehbar dokumentiert sein. |
| **Kommunikation** | Strukturiert und sachlich, bevorzugt klare Agenden und schriftliche Zusammenfassungen. |

### Persona 2: Bogenschütze / Teilnehmer

| Element | Beschreibung |
|---|---|
| **Name & Foto** | Maria Weiss <br> <img src="./assets/Immobilienmakler_Stakeholder.png" alt="Bogenschützin" width="220"/> |
| **Rolle** | Teilnehmerin WBHC 2027, Adult Female Bowhunter Compound (AFBH-C) |
| **Kurzprofil** | 34 Jahre, Mitglied eines österreichischen IFAA-Vereins, nimmt regelmäßig an internationalen 3D-Turnieren teil. Besitzt eine aktuelle IFAA-Klassifizierungskarte (Klasse A, Bowhunter Compound). |
| **Aufgaben** | Anmeldung zum Turnier, Equipment-Check vor dem Start, tägliches Schießen auf der zugewiesenen Strecke in der zugewiesenen Gruppe, Überprüfung der eigenen Ergebnisse. |
| **Daten, die sie nutzt** | Eigenes Profil (Name, Nation, Verein, Stil, Division, Klasse), Startgruppe und Starttarget je Tag, eigene Tages- und Gesamtergebnisse, Ranglistenanzeige, Zeitplan der Runden. |
| **Was sie braucht** | Schnelle Einsicht in eigene Ergebnisse und Ranglistenposition, klare Darstellung der Startgruppe und des Starttargets, einfache Möglichkeit, Fehler in der eigenen Registrierung zu melden. |
| **Sorgen** | Falsch erfasster Schießstil führt zu Disqualifikation. Fehlende oder falsche Klassifizierung verhindert den Start. Unklare Informationen über Startzeiten und Gruppenaufteilung. |
| **Kommunikation** | Direkt und praktisch, nutzt bevorzugt digitale Kanäle und Aushänge am Turniergelände. |

### Persona 3: Feldkapitän / Streckenmarshall

| Element | Beschreibung |
|---|---|
| **Name & Foto** | Thomas Gruber <br> <img src="./assets/Rezeptionist_Stakeholder.png" alt="Feldkapitän" width="220"/> |
| **Rolle** | Feldkapitän Range 2, WBHC 2027 |
| **Kurzprofil** | 47 Jahre, erfahrener Bogenschütze und seit 12 Jahren als Turnieroffiziant tätig. Kennt die IFAA-Schießregeln aus der Praxis und ist verantwortlich für den reibungslosen Ablauf auf seiner zugewiesenen Range. |
| **Aufgaben** | Gruppenaufstellung am ersten Tag, Starttarget-Zuteilung, Score-Seeding ab Tag 2, Überwachung des Schießablaufs, Entscheidung bei Zielzuweisungsproblemen, Koordination der Streckenmarshalls. |
| **Daten, die er nutzt** | Teilnehmerliste mit Divisionszuordnung, aktuelle Gruppenaufteilung mit Namen und Scores, Starttarget je Gruppe, Tagesergebnisse zur Neuseeding-Berechnung. |
| **Was er braucht** | Aktuelle Gruppenübersicht (druckbar und digital), klare Darstellung der Scorereihenfolge für das Seeding, schnelle Suche nach einzelnen Schützen und ihrer Gruppe, Möglichkeit, Gruppenänderungen einzutragen. |
| **Sorgen** | Schützen starten auf der falschen Range oder am falschen Target. Score-Seeding-Fehler führen zu falschen Gruppenaufteilungen. Zu langsame Informationsweitergabe bei kurzfristigen Änderungen. |
| **Kommunikation** | Kurz und direkt, bevorzugt gedruckte Listen als Backup. Gespräche am Morgen vor dem Schießbetrieb sind ideal. |

### Persona 4: Ergebnisbeauftragter / Registrierung

| Element | Beschreibung |
|---|---|
| **Name & Foto** | Sandra Klein <br> <img src="./assets/Mieter_Stakeholder.png" alt="Ergebnisbeauftragte" width="220"/> |
| **Rolle** | Ergebnisbeauftragte und Registrierungsleiterin, WBHC 2027 |
| **Kurzprofil** | 39 Jahre, arbeitet beim DFBV als Veranstaltungskoordinatorin. Hat bereits bei mehreren nationalen Meisterschaften die Ergebniserfassung geleitet und kennt die IFAA-Klassifizierungsregeln gut. |
| **Aufgaben** | Entgegennehmen und Prüfen von Anmeldungen, Verifikation der Klassifizierungskarten (Klasse A/B/C je Stil), Eingabe der täglichen Schussergebnisse, Berechnung von Tages- und Gesamtranglisten, Verwaltung von Gleichständen (Tie-Breaks), Ausgabe offizieller Ergebnislisten. |
| **Daten, die sie nutzt** | Vollständige Teilnehmerdaten, Klassifizierungsangaben (Stil, Division, Klasse), Schussergebnisse pro Ziel und Runde (Pfeilnummer, Trefferzone, Punktwert), Gesamtranglisten je Stil/Division/Klasse. |
| **Was sie braucht** | Übersichtliche Eingabemasken für Schussergebnisse, automatische Klassifizierungsprüfung bei der Anmeldung, automatische Ranglistenberechnung nach Gesamtpunkten und Tie-Break-Regeln, Exportfunktion für offizielle Ergebnislisten (PDF, CSV). |
| **Sorgen** | Fehler bei der Scoreeingabe sind schwer rückgängig zu machen. Klassifizierungsprüfung bei 1.200 Schützen ist sehr aufwendig. Tie-Break-Verfahren (Shoot-off über 3D-Ziele) müssen klar abgebildet sein. |
| **Kommunikation** | Sachlich und detailorientiert, schätzt klare Fehlermeldungen und Validierungsrückmeldungen direkt im System. |

---

## Task 4: Stakeholder Interviews

### Interview 1: Turnierdirektor

**Interview target:** Klaus Brenner, Turnierdirektor WBHC 2027, DFBV

**Interview goal:** Verstehen, welche Daten und Strukturen der Turnierdirektor benötigt, um die vier Schießrunden der WBHC (2x Unmarked Animal Round, 1x 3D Standard Round, 1x 3D Hunting Round) regelkonform zu planen, zuzuweisen und zu überwachen.

#### Interview Guide

**Data-focused open-ended questions**

1. Welche Informationen müssen Sie zu jedem Teilnehmer vor dem Turnier kennen, damit der Schießplan korrekt erstellt werden kann?
2. Wie wird die Aufteilung der Schützen auf Ranges und Gruppen organisiert, und welche Daten fließen dabei ein?
3. Welche Ergebnisdaten brauchen Sie täglich, um den Turnierablauf zu steuern und bei Konflikten entscheiden zu können?

**Closed-ended questions**

4. Müssen Schützen innerhalb derselben Division und desselben Stils immer auf derselben Range schießen? (Ja/Nein)
5. Sollen Protests und Regelentscheidungen im System dokumentiert werden? (Ja/Nein)

**Data security / access rights**

6. Welche Daten dürfen nur Sie und die IFAA-Repräsentanten einsehen, und was darf öffentlich angezeigt werden?

**Concerns / constraints / risks**

7. Was wäre das größte Problem, wenn das System während des Turniers ausfällt oder falsche Daten liefert?

#### Data Requirements

| Data entity / topic | Attributes needed | Operations (C/R/U/D) |
|---|---|---|
| Veranstaltung | Event-ID, Name, Datum, Austragungsort, Veranstalter, IFAA-Referenz | C, R, U |
| Runde | Runden-ID, Rundenttyp (Unmarked Animal 3-Pfeil / 3D Standard 2-Pfeil / 3D Hunting 1-Pfeil), Datum, zugewiesene Range | C, R, U |
| Range / Strecke | Range-ID, Bezeichnung, Anzahl Ziele (28 pro Runde), zugewiesene Divisionen | C, R, U |
| Ziel / Target Station | Ziel-ID, Ziel-Nummer (1–28), Gruppe (1–4), maximale Schussdistanz je Division | C, R, U |
| Offizieller | Offizielle-ID, Name, Funktion (Turnierdirektor / Feldkapitän / TCO / Streckenmarshall), zugewiesene Range | C, R, U, D |
| Protest / Regelentscheid | Protest-ID, Schütze, Datum, Beschreibung, Entscheidung, entscheidender Offizieller | C, R |

#### Interview Summary

- Der Turnierdirektor braucht vor allem strukturierte Übersichten, keine Einzeldatensätze.
- Die korrekte Zuordnung von Stilen und Divisionen zu Ranges ist entscheidend für die Regelkonformität.
- Schützen derselben Division sollen gemäß IFAA-Regeln gemeinsam auf derselben Range schießen.
- Protests und Regelentscheidungen müssen nachvollziehbar protokolliert werden.
- Exportfunktionen für offizielle IFAA-Ergebnislisten sind zwingend erforderlich.

#### Implications for the Database

- Das System muss Runden, Ranges und Zielstationen als eigenständige, miteinander verknüpfte Entitäten abbilden.
- Die Divisionen- und Stilzuordnung muss erzwungen werden (kein Schütze ohne gültige Stil/Divisions-Kombination).
- Ein Protokoll für Regelentscheidungen und Disqualifikationen muss integriert sein.

---

### Interview 2: Bogenschütze / Teilnehmer

**Interview target:** Maria Weiss, Adult Female Bowhunter Compound (AFBH-C), Österreich

**Interview goal:** Verstehen, welche persönlichen Turnierdaten ein Teilnehmer selbst einsehen und prüfen können muss, und welche Anforderungen an Klassifizierung und Startinformation bestehen.

#### Interview Guide

**Data-focused open-ended questions**

1. Welche Informationen über sich selbst und Ihren Start möchten Sie vor und während des Turniers jederzeit einsehen können?
2. Wie und wann erfahren Sie, in welcher Gruppe Sie starten, an welchem Ziel und auf welcher Range?
3. Welche Daten müssen für Ihre Anmeldung korrekt hinterlegt sein, damit Sie zum Schießen zugelassen werden?

**Closed-ended questions**

4. Möchten Sie Ihre Tagesergebnisse und die aktuelle Ranglistenanzeige digital einsehen können? (Ja/Nein)
5. Schießen Sie in mehreren Stilen und benötigen deshalb separate Ergebnisaufzeichnungen je Stil? (Ja/Nein)

**Data security / access rights**

6. Welche Ihrer persönlichen Daten sollen für andere Teilnehmer sichtbar sein (z. B. Name und Nation in der Rangliste)?

**Concerns / constraints / risks**

7. Welche Fehler in der Anmeldung oder Ergebniserfassung würden Sie am meisten belasten?

#### Data Requirements

| Data entity / topic | Attributes needed | Operations (C/R/U/D) |
|---|---|---|
| Teilnehmerprofil | Teilnehmer-ID, Vorname, Nachname, Geburtsdatum, Nation, Verein, Schießstil, Division, Klasse (A/B/C) | C, R, U |
| Klassifizierungskarte | Score-Record-ID, Teilnehmer, Datum, Veranstaltung, Runde, Ergebnis, Klasse, Verifikation durch Offizielle | R |
| Startgruppe | Gruppen-ID, Mitglieder (Schützen-IDs), zugewiesene Range, Starttarget, Tag | R |
| Eigene Ergebnisse | Ergebnis-ID, Runde, Ziel-Nummer, Pfeil-Nummer (1/2/3), Trefferzone (Kill/Vital/Wound/Miss), Punktwert | R |
| Taggesamt / Gesamtergebnis | Tagesergebnis, Gesamtpunkte über alle Runden, Ranglistenposition je Stil/Division/Klasse | R |
| Zeitplan | Rundendatum, Startzeit, Range-Bezeichnung | R |

#### Interview Summary

- Der Schütze braucht vor allem lesenden Zugriff auf seine eigenen Daten.
- Korrekte Stilangabe und Klassifizierungsklasse sind Voraussetzung für die Startzulassung.
- Die Startgruppe und das Starttarget müssen täglich klar und frühzeitig kommuniziert werden.
- Score-Seeding bedeutet, dass Gruppen ab Tag 2 nach Gesamtergebnis neu zusammengestellt werden.
- Mehrfachstarts in verschiedenen Stilen sind möglich, müssen aber separat erfasst werden.

#### Implications for the Database

- Das System muss Teilnehmer eindeutig einer Stil/Divisions-Kombination zuordnen und mehrere Stile pro Person unterstützen.
- Das Geburtsdatum muss gespeichert und validiert werden (Altersnachweis für Junior/Cub/Veteran/Senior ist Pflicht).
- Ergebnisse müssen auf Ziel-Ebene (nicht nur als Tagesgesamtwert) gespeichert werden, um Tie-Break-Regeln anwenden zu können.

---

### Interview 3: Ergebnisbeauftragte / Registrierung

**Interview target:** Sandra Klein, Ergebnisbeauftragte und Registrierungsleiterin, DFBV

**Interview goal:** Verstehen, wie Anmeldedaten geprüft, Schussergebnisse erfasst und Ranglisten nach den IFAA-Regeln für die vier WBHC-Runden korrekt berechnet werden.

#### Interview Guide

**Data-focused open-ended questions**

1. Welche Daten müssen Sie bei der Anmeldung eines Schützen prüfen, und welche Felder sind für die Startzulassung zwingend notwendig?
2. Wie werden die Schussergebnisse nach jedem Schießtag erfasst, und welche Angaben stehen auf einer ausgefüllten Scorekarte?
3. Wie berechnen Sie die Rangliste, und was passiert bei einem Gleichstand (Tie)?

**Closed-ended questions**

4. Unterscheiden sich die Punktesysteme je nach Rundentyp (Unmarked Animal 3-Pfeil vs. 3D Standard 2-Pfeil vs. 3D Hunting 1-Pfeil)? (Ja/Nein)
5. Müssen Ranglisten nach Stil, Division und Klasse (A/B/C) getrennt ausgewiesen werden? (Ja/Nein)

**Data security / access rights**

6. Welche Daten der Scorekarte dürfen nur intern einsehbar sein, und was wird öffentlich auf der Anzeigetafel gezeigt?

**Concerns / constraints / risks**

7. Welche Fehlerquellen bei der Eingabe von Schussergebnissen bereiten Ihnen die größten Sorgen?

#### Data Requirements

| Data entity / topic | Attributes needed | Operations (C/R/U/D) |
|---|---|---|
| Anmeldung | Anmelde-ID, Teilnehmer, Stil, Division, Klasse, Nation, Verein, Startgebühr bezahlt, Ausrüstung geprüft | C, R, U |
| Scorekarte | Karten-ID, Teilnehmer, Runde, Ziel-Nr. (1–28), Pfeil-Nr. (1/2/3), Trefferzone, Punktwert, Target Captain (Unterzeichner) | C, R, U |
| Rundengesamtergebnis | Teilnehmer, Runde, Gesamtpunkte je Runde | R (berechnet) |
| Turnierergebnis | Teilnehmer, Summenpunkte aller Runden, Ranglistenposition (je Stil/Division/Klasse), Gleichstandsmarkierung | R (berechnet) |
| Tie-Break | Tie-Break-ID, beteiligte Schützen, 3D-Ziel-Gruppe, Pfeilergebnis je Schuss, Ergebnis | C, R |
| Klassifizierung | Teilnehmer, Stil, gültige Klasse, Grundlage (zwei Scores im 12-Monatszeitraum) | R, U |

#### Interview Summary

- Jede Scorekarte enthält für jedes der 28 Ziele die Trefferzone und die genaue Pfeilnummer (1., 2. oder 3. Pfeil), weil der Punktwert davon abhängt.
- Die drei Rundentypen haben unterschiedliche Punktesysteme: Unmarked Animal (20/16/12 Kill, 18/14/10 Wound), 3D Standard 2-Pfeil (10/8/5), 3D Hunting 1-Pfeil (20/16/10).
- Ranglisten müssen immer nach Stil, Division und Klasse getrennt berechnet werden.
- Bei Gleichstand gilt ein Shoot-off über drei 3D-Ziele (je zwei Pfeile), danach Sudden Death.
- Klassifizierungen basieren auf den zwei höchsten Scores im vorangegangenen 12-Monats-Zeitraum.

#### Implications for the Database

- Die Datenbank muss Schussergebnisse auf Ebene einzelner Pfeile speichern (Ziel-Nr., Pfeil-Nr., Trefferzone, Punkte) – nicht nur als Zielsumme.
- Das Punktesystem muss dynamisch je Rundentyp angewendet werden; eine einfache Gesamtsumme reicht nicht.
- Die Klassifizierungslogik (zwei Scores im 12-Monatszeitraum, Aufstieg bei zwei Scores in höherer Klasse) muss durch das System unterstützt oder zumindest überprüfbar gemacht werden.

---

## Task 5: Team Reflection

### Was war die überraschendste Erkenntnis?

Bei der Einarbeitung in die IFAA-Regeln und die Anforderungen der WBHC 2027 haben wir erkannt, wie komplex das scheinbar einfache Konzept „Schütze schießt auf ein Ziel und bekommt Punkte" tatsächlich ist. Am Anfang dachten wir, es gehe im Wesentlichen um das Speichern von Gesamtergebnissen. Doch schnell wurde klar, dass jeder einzelne Pfeil getrennt erfasst werden muss – mit Pfeilnummer, Trefferzone und rundenspezifischem Punktwert.

Besonders überraschend war die Kombination aus vier verschiedenen Rundentypen mit je eigenem Punktesystem: Im Unmarked Animal Round (3 Pfeile) hängt der Punktwert davon ab, ob der erste, zweite oder dritte Pfeil trifft. Im 3D Standard Round (2 Pfeile) zählen beide Pfeile. Im 3D Hunting Round (1 Pfeil) gibt es drei Zonen (Kill, Vital, Wound). Das bedeutet, dieselbe Trefferzone erzielt je nach Rundentyp und Pfeilreihenfolge einen anderen Punktwert. Das hat erhebliche Auswirkungen auf die Datenbankstruktur, die wir anfangs unterschätzt hatten.

Zusätzlich überraschte uns die Vielzahl an Stil-Divisions-Kombinationen: Neun Schießstile, sieben Altersklassen und zwei Geschlechter ergeben über 100 mögliche Startkategorien (z. B. AFBH-C für Adult Female Bowhunter Compound). Jede davon braucht eine eigene Rangliste und eigene Klassifizierungsklassen (A, B, C).

### Wo erwarten wir die größten Konflikte?

Die größten Konflikte erwarten wir in zwei Bereichen:

**Granularität der Ergebniserfassung vs. Systemkomplexität:**
Eine akkurate Abbildung der IFAA-Punkteregeln erfordert die Speicherung jedes Pfeils mit Nummer, Zone und rundenspezifischem Punktwert. Das macht die Datenstruktur deutlich komplexer als ein einfaches „Gesamtscore pro Runde". Die Herausforderung besteht darin, diese Tiefe zu implementieren, ohne die Eingabe für die Ergebnisbeauftragte unnötig aufwendig zu machen.

**Klassifizierungslogik vs. Praktikabilität:**
Die IFAA-Klassifizierungsregeln (zwei Scores im 12-Monatszeitraum, dynamischer Aufstieg) sind sehr detailliert und zeitabhängig. Vollständig im System abzubilden, wäre wünschenswert, setzt aber voraus, dass historische Turnierdaten korrekt vorliegen. In der Praxis werden bei der WBHC wahrscheinlich die Klassifizierungen manuell von den Schützen auf der Klassifizierungskarte mitgebracht und dann nur noch geprüft. Das System muss diese Prüfung unterstützen, ohne die gesamte Klassifizierungshistorie aller 1.200 Teilnehmer selbst zu verwalten.

---

## Team Members and Division of Work

| Full Name | Team Role | Division of Work |
|---|---|---|
| Noah M. (Notschge) | Maintainer | Task 1 (Database Developer Persona), Task 5 (Reflection) |
| Niklas R. (Rüdi) | Maintainer | Task 2 (Stakeholder Role Identification), Task 4 (Interview 1 – Turnierdirektor) |
| Jan S. (Jan) | Worker | Task 3 (Stakeholder Personas 1–2), Task 4 (Interview 2 – Bogenschütze) |
| Niklas K. (Katz) | Worker | Task 3 (Stakeholder Personas 3–4), Task 4 (Interview 3 – Ergebnisbeauftragte) |



---
