# Assignment 01: Personas, Stakeholder Interviews, and Reflection

Fact-Finding and Stakeholder Analysis for Database Development

---

## Task 1: Database Developer Persona

### Alex Rivera

**Rollenbezeichnung:** Datenbankentwickler

![Alex Rivera](./assets/Alex_Persona.jpg)

#### Hintergrund

Alex hat Wirtschaftsinformatik studiert und arbeitet seit 4 Jahren als Datenbankentwickler. Seine Karriere begann er als Junior-Analyst in einem Logistikunternehmen. Dort entwarf er seine ersten relationalen Datenbanken. Danach arbeitete er an Projekten im Einzelhandel und im Gesundheitswesen. Dabei sammelte er Erfahrung mit Datenbanken für tägliche Abläufe und Berichte.

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

- Eine saubere und gut strukturierte Datenbank entwickeln, die Geschäftsprozesse richtig darstellt
- Eine Datenbank erstellen, die auch für nicht-technische Personen verständlich ist
- Eine Dokumentation schreiben, damit das System leicht gewartet oder erweitert werden kann
- Mehr über Performance-Optimierung lernen und später Lead-Datenbankarchitekt werden

#### Frustrationen / Herausforderungen

- **Unklare Anforderungen:** 
  Kunden erklären oft ihre Arbeitsweise, aber nicht genau, was sie wirklich brauchen. Dadurch wird es schwieriger, wichtige Daten und Eigenschaften früh zu erkennen.

- **Schleichende Anforderungsänderungen:**
  Nach der Planung kommen oft neue Wünsche hinzu. Dadurch muss das Datenbankschema erneut angepasst werden, was viel Zeit kostet.

- **Kommunikationslücken:** 
  Technische Datenbankthemen einfach für Kunden zu erklären, die wenig Technikkenntnisse haben, ist oft schwierig und zeitaufwendig.

- **Inkonsistente Quelldaten:** 
  Beim Übernehmen alter Daten gibt es oft verschiedene Formate oder doppelte Einträge. Diese Daten müssen zuerst bereinigt werden.

---

## Task 2: Stakeholder Role Identification

### Kontext

Das Datenbankprojekt hilft einem Immobilienunternehmen dabei, Mietwohnungen, Mieter, Besichtigungen und Mitarbeiter zu verwalten.

### Identifizierte Stakeholder-Rollen

| Rolle | Kurzbeschreibung |
|---|---|
| Filialleiter | Hat den Überblick über Wohnungen, Mitarbeiter und wichtige Zahlen |
| Immobilienmaklerin | Verwaltet Wohnungen, spricht mit Kunden und organisiert Besichtigungen |
| Rezeptionist / Sachbearbeiter | Gibt Daten ein, plant Termine und beantwortet Kundenanfragen |
| Mieter | Kann eigene Mietverträge, Zahlungen und Anfragen ansehen |

### Begründung der Rollenwahl

**Filialleiter:**
Der Filialleiter braucht Berichte über belegte Wohnungen, Einnahmen und die Arbeit der Mitarbeiter. Er trifft wichtige Entscheidungen und benötigt deshalb Zugriff auf die meisten Informationen im System.

**Immobilienmaklerin:**
Die Maklerin arbeitet jeden Tag mit Wohnungsdaten, Kundendaten und Besichtigungsterminen. Dafür braucht sie aktuelle und genaue Informationen über Wohnungen und Interessenten.

**Rezeptionist / Sachbearbeiter:**
Diese Person kümmert sich vor allem um die Eingabe und Organisation von Daten. Zum Beispiel werden neue Mieter eingetragen, Termine geplant und Anfragen weitergeleitet. Die Aufgaben wiederholen sich oft im Alltag.

**Mieter:**
Mieter sollen nur ihre eigenen Daten sehen können, zum Beispiel ihren Mietvertrag, Zahlungen oder offene Anfragen. Deshalb ist ein sicherer und eingeschränkter Zugriff wichtig.

### Einordnung der Datenbedürfnisse

**Breiteste Datenbedürfnisse:**
**Filialleiter** – Er braucht Zugriff auf fast alle Bereiche des Systems, zum Beispiel Wohnungen, Mitarbeiter, Finanzen und Kunden. Er nutzt die Daten vor allem für Auswertungen und Entscheidungen.

**Meiste tägliche Datenarbeit:**
**Rezeptionist / Sachbearbeiter** – Diese Rolle arbeitet am häufigsten mit dem System. Sie führt viele wiederkehrende Aufgaben aus und braucht schnellen Zugriff auf die Daten für die tägliche Arbeit.

---

## Task 3: Stakeholder Personas

### Persona 1: Filialleiter

| Element | Beschreibung |
|---|---|
| **Name & Foto** | Alexander Fischer <br> <img src="./assets/Filialleiter_Stakeholder.png" alt="Filialleiter" width="220"/> |
| **Rolle** | Filialleiter, Standort Wien-Mitte |
| **Kurzprofil** | 38 Jahre, Betriebswirtschaft, 18 Jahre Erfahrung, leitet 3 Standorte mit 22 Mitarbeitenden. |
| **Aufgaben** | Filiale führen, Personal leiten, Budget und Umsatz überwachen, Berichte an die Geschäftsleitung. |
| **Daten, die er nutzt** | Kennzahlen (Auslastung, Mieteinnahmen), Objektliste, Mitarbeiterzahlen, Leerstände, Kundenzufriedenheit. |
| **Was er braucht** | Klare Dashboards, Vergleichs- und Trendansichten, Drill-down zu Einzeldaten, Exportfunktionen. |
| **Sorgen** | Das System darf den Tagesbetrieb nicht stören. Schulungsaufwand für erfahrene Mitarbeitende. Revisionssichere Protokolle sind wichtig. |
| **Kommunikation** | Kurz, sachlich, mag Diagramme und klare Agenda. |

### Persona 2: Immobilienmaklerin

| Element | Beschreibung |
|---|---|
| **Name & Foto** | Daniela Krausser <br> <img src="./assets/Immobilienmakler_Stakeholder.png" alt="Immobilienmaklerin" width="220"/> |
| **Rolle** | Immobilienmaklerin (Vertrieb) |
| **Kurzprofil** | 28 Jahre, Ausbildung im Immobilienbereich, 9 Jahre Vertriebserfahrung, betreut viele Objekte. |
| **Aufgaben** | Objekte akquirieren, Besichtigungen durchführen, Verträge verhandeln, Kunden beraten. |
| **Daten, die sie nutzt** | Objektdaten (Lage, Größe, Ausstattung, Preis), Interessentenprofile, Termine, Notizen. |
| **Was sie braucht** | Schnelle Suche und Filter, Matching von Interessenten, mobile Nutzung, Kalenderintegration. |
| **Sorgen** | Zu viele Pflichtfelder verlangsamen die Arbeit. Möchte Datenschutz für ihre Kontakte. Offline-Funktion bei schlechtem Netz. |
| **Kommunikation** | Direkt und praxisnah, mag Beispiele aus dem Alltag. |

### Persona 3: Rezeptionist / Sachbearbeiter

| Element | Beschreibung |
|---|---|
| **Name & Foto** | Sebastian Wallner <br> <img src="./assets/Rezeptionist_Stakeholder.png" alt="Rezeptionist" width="220"/> |
| **Rolle** | Rezeptionist und Sachbearbeiter im Front Office |
| **Kurzprofil** | 57 Jahre, Erfahrung im Kundenservice, zuständig für Empfang und Termine. |
| **Aufgaben** | Besucher empfangen, Anrufe weiterleiten, Daten eingeben, Termine buchen. |
| **Daten, die er nutzt** | Stammdaten von Interessenten und Mietern, Terminkalender, kurze Notizen. |
| **Was er braucht** | Einfache Eingabemasken, schnelle Suche, klare Terminübersicht, Vorlagen für Schreiben. |
| **Sorgen** | Fehler durch Tippfehler, zu komplizierte Masken. Braucht klare Fehlermeldungen und eine Rückgängig-Funktion. |
| **Kommunikation** | Freundlich, offen für Rückfragen, Gespräche am Vormittag sind gut. |

### Persona 4: Mieter

| Element | Beschreibung |
|---|---|
| **Name & Foto** | Jakob Reisinger <br> <img src="./assets/Mieter_Stakeholder.png" alt="Mieter" width="220"/> |
| **Rolle** | Mieter (Nutzer des Mieterportals) |
| **Kurzprofil** | 54 Jahre, Softwareentwickler, nutzt Online-Services gern. |
| **Aufgaben** | Miete zahlen, Schäden melden, Dokumente herunterladen. |
| **Daten, die er nutzt** | Mietvertrag, Zahlungen, Nebenkosten, Schadensmeldungen, Kontaktdaten der Verwaltung. |
| **Was er braucht** | Sicherer Login, Übersicht zu Zahlungen, Online-Schadensmeldung mit Foto, Statusanzeige, Dokumentendownload. |
| **Sorgen** | Datenschutz, nur eigener Zugriff auf die Daten, DSGVO-konform, sichere Anmeldung. |
| **Kommunikation** | Kurz und digital (E-Mail oder Portal), bevorzugt Online-Termine. |

---

## Task 4: Stakeholder Interviews

### Interview 1: Filialleiter

**Interview target:** Alexander Fischer, Filialleiter Standort Wien-Mitte

**Interview goal:** Verstehen, welche aggregierten Kennzahlen, Berichte und Vergleichsdaten der Filialleiter braucht, um seine Filiale zu steuern und an die Geschäftsleitung zu berichten.

#### Interview Guide

**Data-focused open-ended questions**
1. Mit welchen Daten arbeiten Sie täglich, wenn Sie die Filiale steuern?
2. Welche Berichte oder Auswertungen brauchen Sie regelmäßig, und wie oft?
3. Welche Kennzahlen müssen jederzeit aktuell sein, damit Sie schnell Entscheidungen treffen können?

**Closed-ended questions**

4. Brauchen Sie monatliche Auswertungen zu Mieteinnahmen und Leerständen je Standort? (Ja/Nein)
5. Möchten Sie Berichte als PDF, Excel oder beides exportieren können?

**Data security / access rights**

6. Welche Daten dürfen nur Sie sehen, und welche darf das Team einsehen?

**Concerns / constraints / risks**

7. Welche Risiken sehen Sie, wenn das neue System eingeführt wird?

#### Data Requirements

| Data entity / topic | Attributes needed | Operations (C/R/U/D) |
|---|---|---|
| Filiale | Filial-ID, Name, Adresse, Mitarbeiteranzahl | R |
| Objekt | Objekt-ID, Adresse, Status, Miete, Leerstandstage | R |
| Mietvertrag | Vertrags-ID, Mieter, Objekt, Laufzeit, Mietzins | R |
| Mitarbeiter | Mitarbeiter-ID, Name, Rolle, Filiale, Performance | R |
| Kennzahl/Bericht | Auslastung, Umsatz, Kündigungsrate, Zeitraum | R |
| Audit-Log | Benutzer, Aktion, Zeitstempel | R |

#### Interview Summary
- Der Filialleiter braucht vor allem zusammengefasste Daten, keine Einzeldatensätze.
- Vergleiche zwischen Standorten und Zeiträumen sind besonders wichtig.
- Berichte werden monatlich an die Geschäftsleitung weitergegeben.
- Schulungsaufwand für ältere Mitarbeitende ist eine Sorge.
- Das Audit-Log soll nachvollziehbar machen, wer was geändert hat.

#### Implications for the Database
- Das System muss Aggregationen über mehrere Filialen und Zeiträume erlauben.
- Es braucht eine rollenbasierte Rechtevergabe, damit der Filialleiter mehr sieht als das Team.
- Ein revisionssicheres Protokoll (Audit-Log) muss alle Änderungen aufzeichnen.

---

### Interview 2: Immobilienmaklerin

**Interview target:** Daniela Krausser, Immobilienmaklerin im Vertrieb

**Interview goal:** Herausfinden, welche detaillierten Objekt- und Kundendaten die Maklerin im Tagesgeschäft braucht und wie sie unterwegs auf das System zugreifen will.

#### Interview Guide

**Data-focused open-ended questions**
1. Mit welchen Daten arbeiten Sie an einem typischen Arbeitstag?
2. Welche Listen oder Übersichten brauchen Sie, um Interessenten und Objekte zu vergleichen?
3. Welche Informationen müssen Sie zu jedem Objekt und jedem Interessenten festhalten?

**Closed-ended questions**

4. Brauchen Sie mobilen Zugriff auf Objektdaten während Besichtigungen? (Ja/Nein)
5. Wie oft legen Sie neue Interessentenprofile an: täglich, wöchentlich oder monatlich?

**Data security / access rights**

6. Sollen andere Maklerinnen und Makler Ihre persönlichen Kundenkontakte sehen können?

**Concerns / constraints / risks**

7. Was würde Sie im Tagesgeschäft am meisten stören, wenn das neue System nicht gut funktioniert?

#### Data Requirements

| Data entity / topic | Attributes needed | Operations (C/R/U/D) |
|---|---|---|
| Objekt | Objekt-ID, Adresse, Größe, Zimmer, Preis, Fotos, Ausstattung, Status | C, R, U |
| Interessent | Name, Kontaktdaten, Suchkriterien, Budget, Notizen | C, R, U |
| Eigentümer | Name, Kontaktdaten, zugehörige Objekte | R, U |
| Besichtigung | Termin-ID, Datum, Uhrzeit, Objekt, Interessent, Status | C, R, U, D |
| Vertragsentwurf | Entwurfs-ID, Objekt, Mieter, Konditionen | C, R, U |
| Notizen | Kunde, Datum, Inhalt | C, R, U |

#### Interview Summary
- Die Maklerin braucht oft schnellen Zugriff auf einzelne Datensätze, nicht auf Statistiken.
- Sie ist viel unterwegs und benötigt mobile Nutzung mit Offline-Funktion.
- Matching von Interessenten und Objekten ist eine Kernaufgabe.
- Persönlich gepflegte Kontakte sieht sie als sensibel an.
- Eingabemasken sollten nur Pflichtfelder enthalten, die wirklich nötig sind.

#### Implications for the Database
- Es braucht eine leistungsfähige Such- und Filterfunktion für Objekte und Interessenten.
- Das System muss mobil bedienbar sein und Offline-Synchronisation unterstützen.
- Kundenkontakte müssen mit Sichtbarkeitsregeln versehen werden (privat / Team).

---

### Interview 3: Mieter

**Interview target:** Jakob Reisinger, Mieter und Nutzer des Mieterportals

**Interview goal:** Klären, welche personalisierten Daten ein Mieter im Self-Service-Portal sehen und bearbeiten will und welche Datenschutzanforderungen daraus entstehen.

#### Interview Guide

**Data-focused open-ended questions**
1. Welche Informationen möchten Sie in Ihrem Mieterportal jederzeit einsehen können?
2. Welche Aufgaben möchten Sie online erledigen statt per Telefon oder E-Mail?
3. Welche Dokumente sollen Sie selbst herunterladen oder hochladen können?

**Closed-ended questions**

4. Möchten Sie Schadensmeldungen mit Foto-Upload einreichen können? (Ja/Nein)
5. Wie oft nutzen Sie das Portal voraussichtlich: täglich, wöchentlich oder nur bei Bedarf?

**Data security / access rights**

6. Wer aus dem Unternehmen darf Ihre persönlichen Daten und Zahlungen einsehen?

**Concerns / constraints / risks**

7. Welche Bedenken haben Sie beim Datenschutz und bei der Anmeldung im Portal?

#### Data Requirements

| Data entity / topic | Attributes needed | Operations (C/R/U/D) |
|---|---|---|
| Mieterkonto | Benutzer-ID, Name, E-Mail, Passwort-Hash | R, U |
| Mietvertrag (eigener) | Vertrags-ID, Objekt, Laufzeit, Miete, Nebenkosten | R |
| Zahlung | Datum, Betrag, Status, Verwendungszweck | R |
| Nebenkostenabrechnung | Jahr, Betrag, Dokument | R |
| Schadensmeldung | Meldungs-ID, Datum, Beschreibung, Foto, Status | C, R |
| Dokument | Typ, Datum, Datei | R |

#### Interview Summary
- Der Mieter will nur Zugriff auf die ihn selbst betreffenden Daten.
- Online-Schadensmeldung mit Foto-Upload ist ein zentraler Wunsch.
- Status der Anliegen soll transparent nachvollziehbar sein.
- Datenschutz und sichere Anmeldung haben höchste Priorität.
- Das Portal wird eher selten genutzt, soll aber jederzeit verfügbar sein.

#### Implications for the Database
- Die Datenbank muss strikte zeilenbasierte Zugriffsrechte unterstützen (Mieter sieht nur eigene Datensätze).
- Es braucht ein sicheres Authentifizierungs- und Protokollkonzept (DSGVO-konform).
- Schadensmeldungen müssen Datei-Anhänge und einen klaren Status-Workflow abbilden können.

---

## Task 5: Team Reflection

### Was war die überraschendste Erkenntnis?

Bei der Arbeit mit den Stakeholder-Rollen unseres Immobilienverwaltungssystems haben wir gemerkt, dass verschiedene Personen dieselben Daten ganz unterschiedlich nutzen und verstehen. Am Anfang dachten wir, dass alle Beteiligten mit denselben Daten ähnlich arbeiten würden. Doch schnell wurde klar, dass jede Rolle andere Anforderungen hat. 

Ein Immobilienmakler sieht ein „Objekt" zum Beispiel als einzelne Wohnung oder Haus mit Adresse, Ausstattung, Zustand und aktuellem Mieter. Für ihn sind genaue Details wichtig. Der Filialleiter sieht dasselbe Objekt eher aus wirtschaftlicher Sicht. Für ihn zählen Dinge wie Auslastung, Mieteinnahmen oder Leerstand. Er braucht vor allem Übersichten und Statistiken. Diese unterschiedlichen Sichtweisen auf dieselben Daten waren für uns überraschend. 

Dadurch wurde deutlich, wie wichtig gute Gespräche mit den Stakeholdern sind, damit man ihre Anforderungen richtig versteht. Außerdem haben wir den Mieter anfangs unterschätzt. Zuerst sahen wir ihn nicht als wichtigen Nutzer der Datenbank, weil er das System nicht selbst verwaltet. Später wurde uns aber klar, dass auch der Mieter wichtige Anforderungen hat, zum Beispiel Einsicht in Zahlungen, Verträge und offene Anfragen. Dadurch spielen Datenschutz und Zugriffsrechte eine große Rolle.

### Wo erwarten wir die größten Konflikte?

Die größten Konflikte erwarten wir in zwei Bereichen:

**Detailtiefe vs. Übersichtlichkeit:** 
Der Filialleiter braucht einfache Übersichten, Diagramme und Zusammenfassungen. Der Rezeptionist dagegen benötigt genaue Einzeldaten, um seine tägliche Arbeit richtig erledigen zu können. Ein System, das nur für Übersichten gemacht ist, hilft dem Rezeptionisten wenig. Umgekehrt können zu viele Details für den Filialleiter unübersichtlich sein. Deshalb braucht das System unterschiedliche Ansichten für verschiedene Rollen.

**Datenschutz vs. Transparenz:** 
Mieter sollen nur ihre eigenen Daten sehen können. Makler und Filialleiter brauchen jedoch teilweise Zugriff auf Mieterdaten, um ihre Arbeit zu erledigen. Dadurch entsteht ein Konflikt zwischen Datenschutz und den Anforderungen des Unternehmens. Dieses Problem muss mit klaren Rollen und Zugriffsrechten gelöst werden.

---

## Team Members and Division of Work

| Full Name | Team Role | Division of Work |
|---|---|---|
| Noah M. (Notschge) | Maintainer | Task 1 (Database Developer Persona), Task 5 (Reflection) |
| Niklas R. (Rüdi) | Maintainer | Task 2 (Stakeholder Role Identification), Task 4 (Interview 1 – Filialleiter) |
| Jan S. (Jan) | Worker | Task 3 (Stakeholder Personas 1–2), Task 4 (Interview 2 – Immobilienmaklerin) |
| Niklas K. (Katz) | Worker | Task 3 (Stakeholder Personas 3–4), Task 4 (Interview 3 – Mieter) |



---

*Assignment 01 — Fertiggestellt: 8. Mai 2026*
