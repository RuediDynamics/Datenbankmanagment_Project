# Reflexion: Stakeholder-Rollen im Datenbankprojekt


## 1. Was war die überraschendste Erkenntnis?

Bei der Auseinandersetzung mit den Stakeholder-Rollen unseres Immobilienverwaltungssystems war die überraschendste Erkenntnis, wie unterschiedlich dieselben Daten von verschiedenen Rollen wahrgenommen und benötigt werden. Wir hatten zunächst angenommen, dass alle Beteiligten grundsätzlich auf denselben Datensatz zugreifen und diesen ähnlich nutzen würden – quasi ein „geteiltes Verständnis" der Datenbank.

In der Realität zeigte sich jedoch schnell, dass ein Immobilienmakler unter einem „Objekt" etwas völlig anderes versteht als ein Filialleiter. Für den Makler ist ein Objekt ein konkretes Haus mit Adresse, Zustand, Ausstattung und aktuellem Mieter – er denkt in Einzelfällen. Für den Filialleiter hingegen ist ein Objekt primär eine Kennzahl: Auslastungsgrad, Mieteinnahmen, Leerstandsdauer. Diese unterschiedliche Perspektive auf dieselbe Entität war für uns eine unerwartete Herausforderung, die zeigt, wie wichtig es ist, Stakeholder-Interviews sorgfältig zu führen und nicht von einem einheitlichen Datenverständnis auszugehen.

Überraschend war auch, dass der Mieter als Stakeholder anfangs von uns unterschätzt wurde. Wir hatten ihn zunächst nicht als primären Nutzer der Datenbank gesehen, da er das System nicht aktiv verwaltet. Doch bei näherer Betrachtung wurde klar, dass seine Datenbedürfnisse – Transparenz über Zahlungen, Vertragslaufzeiten und offene Anfragen – durchaus eigene Anforderungen an Zugriffsrechte und Datenschutz stellen.


## 2. Wo erwarten wir die größten Konflikte?

Die größten Konflikte zwischen den Datenbedürfnissen der verschiedenen Rollen erwarten wir in zwei Bereichen:

**Detailtiefe vs. Übersichtlichkeit:** Der Filialleiter möchte aggregierte, vereinfachte Ansichten – Dashboards, Zusammenfassungen, Trends. Der Rezeptionist hingegen braucht detaillierte Einzeldatensätze, um korrekt arbeiten zu können. Ein Datenmodell, das für die eine Rolle optimiert ist, erschwert potenziell die Arbeit der anderen. Hier muss durch geeignete Views und Benutzeroberflächen vermittelt werden.

**Datenschutz vs. Transparenz:** Der Mieter hat ein berechtigtes Interesse daran, nur seine eigenen Daten einzusehen. Der Filialleiter oder Makler benötigt jedoch unter Umständen Zugriff auf Mieterdaten für Auswertungen oder Kundenkontakt. Diese Spannung zwischen Datenschutzbedürfnis und operativer Notwendigkeit ist schwer aufzulösen und muss durch ein durchdachtes Rollenrechte-Konzept adressiert werden.

Insgesamt hat uns diese Reflexion gezeigt, dass eine Datenbank nie „neutral" ist – sie spiegelt immer die Bedürfnisse und Prioritäten bestimmter Rollen wider, und es ist die Aufgabe des Entwicklerteams, diese Interessen sorgfältig abzuwägen.
