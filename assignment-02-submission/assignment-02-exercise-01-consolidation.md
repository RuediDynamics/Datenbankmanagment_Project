# Assignment 02 – Exercise 1: Consolidate Requirements from Stakeholder Interviews

**Domain:** IFAA World Bowhunter Championships (WBHC) 2027, Bad Waldsee  
**Veranstalter:** Deutscher Feldbogen Sportverband e. V. (DFBV) nach IFAA-Regeln  
**Grundlage:** Assignment 01 – Personas, Stakeholder-Interviews und Reflection

---

## 1. Stakeholder Roles


| # | Rolle | Persona | Primärer Systembezug |
|---|---|---|---|
| 1 | **Turnierdirektor** | Klaus Brenner, DFBV | Strategische Planung, Regelkonformität, Gesamtübersicht |
| 2 | **Bogenschütze / Teilnehmer** | Maria Weiss, Österreich (AFBH-C) | Persönliche Anmeldung, Startinformation, eigene Ergebnisse |
| 3 | **Ergebnisbeauftragte / Registrierung** | Sandra Klein, DFBV | Tägliche Dateneingabe, Klassifizierungsprüfung, Ranglistenberechnung |

---

## 2. Key Data Needs per Role

### 2.1 Turnierdirektor (Klaus Brenner)

Der Turnierdirektor benötigt **strukturierte Übersichten** über alle zentralen Turnierbereiche. Er arbeitet nicht mit Einzeldatensätzen, sondern mit aggregierten Sichten zur Entscheidungsunterstützung.

| Datenobjekt | Konkrete Datenanforderungen |
|---|---|
| Veranstaltung | Event-ID, Name, Datum, Austragungsort, Veranstalter, IFAA-Referenz |
| Runde | Runden-ID, Rundentyp (Unmarked Animal 3-Pfeil / 3D Standard 2-Pfeil / 3D Hunting 1-Pfeil), Datum, zugewiesene Range |
| Range / Strecke | Range-ID, Bezeichnung, Anzahl Ziele (28 pro Runde), zugewiesene Divisionen/Stile |
| Ziel / Target Station | Ziel-ID, Ziel-Nummer (1–28), Zielgruppe (1–4), maximale Schussdistanz je Division |
| Offizieller | Offizielle-ID, Name, Funktion (TCO etc.), zugewiesene Range |
| Protest / Regelentscheid | Protest-ID, betroffener Schütze, Datum, Beschreibung, Entscheidung, entscheidender Offizieller |
| Gesamtrangliste | Aktuelle Ranglisten je Division, Stil und Klasse (A/B/C) |
| Teilnehmerliste | Auflistung nach Nation, Stil, Division für Schießplanaufstellung |

**Benötigte Operationen:** überwiegend R (Read), selektiv C/U bei Veranstaltungs- und Rundenplanung sowie C bei Protests.

---

### 2.2 Bogenschütze / Teilnehmer (Maria Weiss)

Der Schütze benötigt **ausschließlich lesenden Zugriff** auf eigene Daten. Schreibzugriff ist nur im Rahmen der eigenen Anmeldung oder Fehlerkorrektur vorgesehen.

| Datenobjekt | Konkrete Datenanforderungen |
|---|---|
| Eigenes Profil | Teilnehmer-ID, Vorname, Nachname, Geburtsdatum, Nation, Verein, Schießstil, Division, Klasse (A/B/C) |
| Klassifizierungskarte | Score-Record-ID, Datum, Veranstaltung, Runde, Ergebnis, Klasse, Verifikationsstatus |
| Startgruppe | Gruppen-ID, Mitglieder (Schützen-IDs), zugewiesene Range, Starttarget, Datum |
| Eigene Schussergebnisse | Ergebnis-ID, Runde, Ziel-Nummer, Pfeil-Nummer (1/2/3), Trefferzone (Kill/Vital/Wound/Miss), Punktwert |
| Taggesamt / Gesamtergebnis | Tagesergebnis, Gesamtpunkte über alle Runden, Ranglistenposition je Stil/Division/Klasse |
| Zeitplan | Rundendatum, Startzeit, Range-Bezeichnung |

**Benötigte Operationen:** R (Read) dominant; C/U nur bei Anmeldung und Fehlerkorrektur.

---

### 2.3 Ergebnisbeauftragte / Registrierung (Sandra Klein)

Die Ergebnisbeauftragte hat **den intensivsten und breitesten Schreibzugriff**. Sie führt alle operativen Datenpflegeaufgaben täglich durch und trägt die größte Fehlerverantwortung.

| Datenobjekt | Konkrete Datenanforderungen |
|---|---|
| Anmeldung | Anmelde-ID, Teilnehmer-Referenz, Stil, Division, Klasse, Nation, Verein, Startgebühr bezahlt, Ausrüstung geprüft |
| Scorekarte | Karten-ID, Teilnehmer-Referenz, Runde, Ziel-Nr. (1–28), Pfeil-Nr. (1/2/3), Trefferzone, Punktwert, Target Captain (Unterzeichner) |
| Rundengesamtergebnis | Teilnehmer-Referenz, Runde, Gesamtpunkte je Runde (berechnet) |
| Turnierergebnis | Teilnehmer-Referenz, Summenpunkte aller Runden, Ranglistenposition (je Stil/Division/Klasse), Gleichstandsmarkierung |
| Tie-Break | Tie-Break-ID, beteiligte Schützen, 3D-Ziel-Gruppe, Pfeilresultat je Schuss, Endresultat |
| Klassifizierung | Teilnehmer-Referenz, Stil, gültige Klasse, Grundlage (zwei Scores im 12-Monats-Zeitraum), Prüfstatus |

**Benötigte Operationen:** C, R, U für Anmeldung, Scorekarte und Tie-Break; R für berechnete Ranglisten.

---

## 3. Overlaps and Conflicts

### 3.1 Überschneidungen (Overlaps)

Mehrere Datenobjekte und Anforderungen werden von mehr als einer Stakeholder-Rolle benötigt:

| Überschneidung | Beteiligte Rollen | Anmerkung |
|---|---|---|
| Teilnehmerstammdaten (Name, Nation, Stil, Division, Klasse) | Alle drei | Zentrale Entität; wird von allen Rollen verwendet, jedoch mit unterschiedlichen Zugriffsrechten |
| Ranglisten je Stil/Division/Klasse | Alle drei | Turnierdirektor und Ergebnisbeauftragte brauchen vollständige Sichten; Schütze nur die eigene Position |
| Startgruppen und Range-Zuweisung | Turnierdirektor + Schütze | Turnierdirektor plant, Schütze konsumiert |
| Schussergebnisse | Schütze + Ergebnisbeauftragte | Ergebnisbeauftragte erfasst, Schütze liest; beide benötigen Darstellung auf Zielebene |
| Klassifizierungsprüfung | Schütze + Ergebnisbeauftragte | Schütze bringt Karte mit; Ergebnisbeauftragte prüft und vermerkt Ergebnis |
| Exportfunktion (PDF/CSV) | Turnierdirektor + Ergebnisbeauftragte | Beide benötigen offizielle Ergebnisexporte für IFAA und Aushänge |

### 3.2 Konflikte (Conflicts)

| Konflikt | Beteiligte Rollen | Beschreibung |
|---|---|---|
| **Granularität vs. Aufwand** | Ergebnisbeauftragte vs. Systemdesign | Die korrekte IFAA-Punktelogik (Pfeilnummer entscheidet über Punktwert) erfordert Erfassung auf Pfeil-Ebene. Das macht die Eingabe für die Ergebnisbeauftragte aufwendiger; ein einfaches Tagesgesamtscore würde nicht reichen. |
| **Klassifizierungshistorie vs. Praktikabilität** | Turnierdirektor + Ergebnisbeauftragte vs. Machbarkeit | Vollständige Verwaltung der IFAA-Klassifizierungshistorie (zwei Scores in 12 Monaten) für 1.200 Schützen ist im Rahmen der WBHC nicht realistisch; die Praxis sieht vor, dass Schützen ihre Karte mitbringen und nur der aktuelle Status geprüft wird. |
| **Datenschutz / öffentliche Sichtbarkeit** | Schütze vs. Turnierdirektor | Der Schütze möchte kontrollieren, welche Daten öffentlich sichtbar sind (z. B. nur Name und Nation, nicht Geburtsdatum). Der Turnierdirektor und die Ergebnisbeauftragte brauchen vollständige, interne Dateneinsicht. |
| **Fehlerkorrektur** | Schütze vs. Ergebnisbeauftragte | Schussergebnisse sind nach Eingabe schwer rückgängig zu machen; ein Schütze kann eine Korrektur anfragen, aber nur die Ergebnisbeauftragte darf Änderungen vornehmen. Prozess und Berechtigungen müssen klar definiert sein. |

---

## 4. Preliminary Scope

### In Scope

Das konzeptuelle Datenmodell deckt folgende Bereiche ab:

- **Teilnehmerverwaltung:** Profildaten, Stil/Divisions/Klassen-Kombination, Nation, Verein, Geburtsdatum (Altersvalidierung für Altersklassen)
- **Veranstaltungs- und Rundenverwaltung:** Vier Runden der WBHC (2× Unmarked Animal Round, 1× 3D Standard Round, 1× 3D Hunting Round) mit je eigenem Punktesystem
- **Range- und Zielstationsverwaltung:** 28 Targets pro Runde, Gruppen (1–4), Distanzangaben je Division
- **Startgruppenzuweisung:** Tägliche Zuweisung von Schützen zu Gruppen, Ranges und Starttargets; Score-Seeding ab Tag 2
- **Schussergebniserfassung:** Auf Ebene einzelner Pfeile (Ziel-Nr., Pfeil-Nr., Trefferzone, Punktwert) inkl. Target Captain
- **Ranglistenberechnung:** Getrennt nach Stil, Division und Klasse (A/B/C); Tie-Break-Verfahren (Shoot-off über 3D-Ziele)
- **Offizielle und Funktionen:** Turnierdirektor, TCOs und weitere Offizielle mit Range-Zuweisungen
- **Protest- und Regelentscheiddokumentation:** Strukturierte Protokollierung mit Entscheidung und verantwortlichem Offiziellen
- **Klassifizierungsprüfung:** Vermerken des geprüften Klassifizierungsstatus bei der Anmeldung (kein vollständiges Historienmanagement)
- **Anmeldungsverwaltung:** Inkl. Status Startgebühr bezahlt und Ausrüstung geprüft

### Out of Scope

- Vollständige IFAA-Klassifizierungshistorie aller Teilnehmer (historische Turnierdaten anderer Veranstaltungen)
- Online-Anmeldesystem mit Bezahlabwicklung (Payment-Gateway)
- Hotelbuchungen, Reiseplanung, Akkreditierung
- Detaillierte Equipment-Spezifikationen (nur Prüfstatus „geprüft / nicht geprüft")
- Ergebnisse anderer (Nicht-WBHC) Turniere als eigenständige Datenverwaltung
- Echtzeitkommunikation / Push-Benachrichtigungen an Teilnehmer
- Benutzerverwaltung und Authentifizierungssystem (Login-Management)

---

## 5. Core Transactions

Die folgenden **acht Kerntransaktionen** decken die operativen und manageriellen Anforderungen aller drei Stakeholder-Rollen ab:

| # | Transaktionsname | Typ | Primäre Rolle | Beteiligte Datenobjekte |
|---|---|---|---|---|
| T1 | **Teilnehmer anlegen und einer Stil/Divisions/Klassen-Kombination zuweisen** | Operational – Create/Update | Ergebnisbeauftragte | Teilnehmer, Anmeldung, Nation, Verein |
| T2 | **Klassifizierungskarte prüfen und Startzulassung erteilen** | Operational – Read/Update | Ergebnisbeauftragte | Anmeldung, Klassifizierung, Teilnehmer |
| T3 | **Startgruppen für eine Runde erstellen und Schützen auf Ranges/Targets zuweisen** | Operational – Create/Update | Turnierdirektor | Startgruppe, Runde, Range, Ziel, Teilnehmer |
| T4 | **Schussergebnisse einer Scorekarte (28 Ziele × Pfeilanzahl) erfassen und Punkte berechnen** | Operational – Create | Ergebnisbeauftragte | Scorekarte, Schussergebnis, Rundengesamtergebnis, Rundentyp |
| T5 | **Tagesergebnisse und Gesamtrangliste je Stil/Division/Klasse anzeigen** | Managerial – Read (calculated) | Alle drei Rollen | Turnierergebnis, Teilnehmer, Stil, Division, Klasse |
| T6 | **Tie-Break-Shoot-off erfassen und Gewinner bestimmen** | Operational – Create/Read | Ergebnisbeauftragte | Tie-Break, Schussergebnis, Teilnehmer |
| T7 | **Protest / Regelentscheid dokumentieren und einem Offiziellen zuordnen** | Operational – Create | Turnierdirektor | Protest, Offizieller, Teilnehmer |
| T8 | **Offizielle Ergebnisliste (nach IFAA-Format) für eine Runde oder das Gesamtturnier exportieren** | Managerial – Read/Report | Turnierdirektor + Ergebnisbeauftragte | Turnierergebnis, Runde, Teilnehmer, Stil, Division, Klasse |

### Zuordnung zu Stakeholder-Anforderungen

| Transaktion | Turnierdirektor | Bogenschütze | Ergebnisbeauftragte |
|---|:---:|:---:|:---:|
| T1 – Teilnehmer anlegen | | | ✓ |
| T2 – Klassifizierung prüfen | | | ✓ |
| T3 – Startgruppen erstellen | ✓ | (konsumiert) | |
| T4 – Scorekarte erfassen | | | ✓ |
| T5 – Rangliste anzeigen | ✓ | ✓ | ✓ |
| T6 – Tie-Break erfassen | | | ✓ |
| T7 – Protest dokumentieren | ✓ | | |
| T8 – Ergebnisliste exportieren | ✓ | | ✓ |


