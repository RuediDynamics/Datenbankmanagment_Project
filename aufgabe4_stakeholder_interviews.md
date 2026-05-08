# Aufgabe 4: Stakeholder-Interviews (einfaches Deutsch)

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
