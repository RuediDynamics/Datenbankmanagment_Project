# Aufgabe 3: Stakeholder-Personas

Im Folgenden werden vier Stakeholder-Personas vorgestellt, die die in Aufgabe 2 identifizierten Rollen im Immobilienverwaltungsunternehmen abbilden. Jede Persona repräsentiert eine unterschiedliche Perspektive auf das Datenbanksystem – von der strategischen Gesamtsicht bis hin zum eingeschränkten, personalisierten Zugriff der Endkunden.

---

## Persona 1: Filialleiterin

| Element | Beschreibung |
|---|---|
| **Name & Foto** | Margarete Hofbauer <br> ![Alex Rivera](./Assests/Alex_Persona.jpg) |
| **Rollenbezeichnung** | Filialleiterin (Branch Manager), Standort Wien-Mitte |
| **Hintergrund** | 48 Jahre alt, Studium der Betriebswirtschaft an der WU Wien, seit 18 Jahren in der Immobilienbranche tätig, davon 7 Jahre als Filialleiterin. Verantwortet drei Standorte mit insgesamt 22 Mitarbeitenden und einem Portfolio von rund 450 verwalteten Objekten. |
| **Hauptverantwortlichkeiten** | Strategische Steuerung der Filiale, Personalführung, Budget- und Umsatzverantwortung, Reporting an die Geschäftsleitung, Genehmigung von Sonderverträgen, Überwachung der Belegungsquoten und Schlichtung eskalierter Kundenfälle. |
| **Daten, mit denen sie arbeitet** | Aggregierte Kennzahlen wie Auslastungsraten, Mieteinnahmen pro Quartal, Objektportfolio nach Region, Mitarbeiterperformance, Kündigungsraten, Leerstandszeiten, Kundenzufriedenheitsdaten. |
| **Was sie von der Datenbank benötigt** | Übersichtliche Dashboards mit KPIs, Trend- und Vergleichsberichte über mehrere Filialen und Zeiträume, Drill-Down-Funktionalität von Aggregaten zu Einzeldaten, Exportmöglichkeiten für Berichte an die Geschäftsleitung sowie eine zuverlässige Datenkonsistenz. |
| **Bedenken / Vorbehalte** | Sorge, dass ein neues System die laufenden Geschäftsprozesse stört. Skepsis gegenüber Schulungsaufwand für ältere Mitarbeitende. Besteht auf einer revisionssicheren Dokumentation aller Datenänderungen aus Compliance-Gründen. |
| **Bevorzugter Kommunikationsstil** | Sachlich, ergebnisorientiert, mit knappen Terminen. Bevorzugt strukturierte Interviews mit klarer Agenda und vorab versandten Fragen. Schätzt Visualisierungen (Diagramme, Mock-ups) statt langer Texte. |

---

## Persona 2: Immobilienmakler

| Element | Beschreibung |
|---|---|
| **Name & Foto** | Daniel Krausser <br> ![Alex Rivera](./Assests/Alex_Persona.jpg) |
| **Rollenbezeichnung** | Senior Immobilienmakler |
| **Hintergrund** | 34 Jahre alt, abgeschlossene Lehre als Immobilienkaufmann, zusätzliche Befähigungsprüfung zum Immobilientreuhänder. Seit 9 Jahren im Vertrieb, davon 5 Jahre im aktuellen Unternehmen. Betreut rund 60 aktive Objekte und führt monatlich etwa 40 Besichtigungen durch. |
| **Hauptverantwortlichkeiten** | Akquise neuer Mietobjekte, Beratung von Eigentümern und Interessenten, Durchführung von Besichtigungen, Vertragsverhandlungen, Erstellung von Exposés, Pflege der Kundenbeziehungen sowie Übergabe und Rücknahme von Mietobjekten. |
| **Daten, mit denen er arbeitet** | Detaillierte Objektdaten (Lage, Größe, Ausstattung, Fotos, Preis), Eigentümerinformationen, Interessentenprofile mit Suchkriterien, Besichtigungstermine, Vertragsentwürfe, Provisionsabrechnungen, Notizen zu Kundengesprächen. |
| **Was er von der Datenbank benötigt** | Schnelle Suche und Filterung im Objektbestand nach Kriterien wie Lage, Preis und Größe, Matching zwischen Interessentenprofilen und verfügbaren Objekten, mobiler Zugriff während Außenterminen, Kalenderintegration für Besichtigungen, Verlauf der Kundeninteraktionen (CRM-ähnliche Funktionen). |
| **Bedenken / Vorbehalte** | Befürchtet, dass eine zu komplexe Eingabemaske den Arbeitsfluss verlangsamt. Möchte nicht, dass Kollegen seine persönlich gepflegten Kundenkontakte ohne Zustimmung übernehmen können. Wünscht sich Offline-Funktionalität bei schlechter Mobilfunkanbindung. |
| **Bevorzugter Kommunikationsstil** | Pragmatisch, direkt, zeitlich flexibel aber begrenzt. Interviews am besten am späten Nachmittag im Büro. Bevorzugt konkrete Beispiele und reale Arbeitssituationen statt abstrakter Konzepte. |

---

## Persona 3: Rezeptionistin / Sachbearbeiterin

| Element | Beschreibung |
|---|---|
| **Name & Foto** | Sabine Wallner <br> ![Alex Rivera](./Assests/Alex_Persona.jpg) |
| **Rollenbezeichnung** | Rezeptionistin und Sachbearbeiterin im Front Office |
| **Hintergrund** | 27 Jahre alt, Handelsschulabschluss, drei Jahre Berufserfahrung im Kundenservice einer Versicherung, seit zwei Jahren im aktuellen Unternehmen. Erste Anlaufstelle für Kundinnen und Kunden, sowohl persönlich als auch telefonisch und per E-Mail. |
| **Hauptverantwortlichkeiten** | Empfang von Besuchern, Annahme und Weiterleitung von Telefonaten, Bearbeitung allgemeiner Anfragen, Eingabe neuer Interessenten- und Mieterdaten, Buchung von Besichtigungsterminen für die Maklerinnen und Makler, Erstellung einfacher Korrespondenz und Ablage. |
| **Daten, mit denen sie arbeitet** | Stammdaten von Interessenten und Mietern (Name, Adresse, Kontaktdaten), Terminkalender der Maklerinnen und Makler, kurze Notizen zu Anfragen, Posteingang und -ausgang, Standardformulare und Anschreiben. |
| **Was sie von der Datenbank benötigt** | Einfache und schnelle Eingabemasken für Neukunden, Suche nach bestehenden Datensätzen, klare Übersicht über freie Termine, automatische Benachrichtigungen an Maklerinnen und Makler bei neuen Anfragen, Vorlagen für wiederkehrende Korrespondenz, geringe Klickzahlen pro Vorgang. |
| **Bedenken / Vorbehalte** | Hat Sorge, dass ein neues System komplizierter wird als das aktuelle. Befürchtet, durch Tippfehler ungewollt Daten zu beschädigen. Wünscht sich eine Undo-Funktion und eine klare Fehlermeldung statt kryptischer Codes. |
| **Bevorzugter Kommunikationsstil** | Freundlich und gesprächig, offen für Rückfragen. Interviews idealerweise vormittags vor dem Hauptbesucherandrang. Profitiert von einem ruhigen, wertschätzenden Gesprächsklima, da sie ihre fachliche Expertise gelegentlich unterschätzt. |

---

## Persona 4: Mieter

| Element | Beschreibung |
|---|---|
| **Name & Foto** | Jakob Reisinger <br> ![Alex Rivera](./Assests/Alex_Persona.jpg) |
| **Rollenbezeichnung** | Mieter (Endkunde mit Online-Zugang zum Mieterportal) |
| **Hintergrund** | 31 Jahre alt, Softwareentwickler in einem mittelständischen Unternehmen, seit drei Jahren Mieter einer Zweizimmerwohnung im verwalteten Bestand. Technikaffin, nutzt Online-Services intensiv und erwartet ein modernes Self-Service-Angebot. |
| **Hauptverantwortlichkeiten** | Pünktliche Mietzahlung, Meldung von Schäden oder Anliegen, Einhaltung der Hausordnung, gelegentliche Kommunikation mit der Hausverwaltung. Keine berufliche Rolle im Unternehmen – er ist Konsument der Dienstleistung. |
| **Daten, mit denen er arbeitet** | Eigener Mietvertrag, Zahlungshistorie, Nebenkostenabrechnungen, eingereichte Schadensmeldungen und deren Bearbeitungsstatus, Kontaktdaten der zuständigen Ansprechperson. |
| **Was er von der Datenbank benötigt** | Sicheren Login-Bereich mit Einsicht in den eigenen Vertrag, Übersicht über offene und beglichene Zahlungen, Möglichkeit zur Online-Schadensmeldung mit Fotoupload, Statusverfolgung seiner Anliegen, Download von Dokumenten wie Abrechnungen oder Bestätigungen. |
| **Bedenken / Vorbehalte** | Hohe Sensibilität gegenüber Datenschutz. Möchte sicher sein, dass nur er seine Daten einsehen kann und dass keine Mitarbeitenden ohne dienstlichen Anlass Zugriff haben. Erwartet DSGVO-Konformität, sichere Authentifizierung und transparente Information darüber, welche Daten gespeichert werden. |
| **Bevorzugter Kommunikationsstil** | Knapp und digital. Bevorzugt schriftliche Kommunikation per E-Mail oder im Portal gegenüber Telefonaten. Für ein Interview kommt am ehesten ein Online-Termin per Videocall in Frage, mit klarer Zeitbegrenzung. |

---