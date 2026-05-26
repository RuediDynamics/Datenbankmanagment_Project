# Assignment 02 – Aufgabe 5: Annahmen, Designentscheidungen und Teamreflexion

**Domäne:** IFAA World Bowhunter Championships (WBHC) 2027, Bad Waldsee  
**Grundlage:** Aufgaben 1–4 (Anforderungen, konzeptuelles Modell, Datenwörterbuch)

---

## 1. Getroffene Annahmen

Mehrere Anforderungen blieben unvollständig oder mehrdeutig und mussten durch explizite Annahmen aufgelöst werden.

**Einzelveranstaltungs-Scope.** Die IFAA-Regeln gelten weltweit für Meisterschaften, das System ist jedoch auf die WBHC 2027 als einzelne `Event`-Instanz beschränkt. Es wurde angenommen, dass historische Ergebnisse anderer Turniere außerhalb des Scopes liegen. Dadurch konnte auf eine vollständige Klassifizierungshistorie verzichtet und stattdessen nur der bei der Anmeldung geprüfte Klassenstatus erfasst werden.

**Teilnehmer bringt die Klassifizierungskarte mit.** Ein turnierübergreifendes IFAA-Teilnehmerregister stand nicht zur Verfügung. Es wurde angenommen, dass Schützen ihre Klasse (A/B/C) durch Vorlage einer Klassifizierungskarte selbst nachweisen und Sandra Kleins Aufgabe darin besteht, diesen Status zu prüfen und zu vermerken — nicht ihn aus historischen Ergebnissen zu berechnen. Dies reduzierte den Umfang der Entitäten `Registration` und `CompetitionCategory` erheblich.

**Mehrfachnutzung von Ranges über Runden hinweg.** Die Anzahl der physischen Ranges in Bad Waldsee war nicht spezifiziert. Es wurde angenommen, dass 4–8 Ranges in mehreren Runden wiederverwendet werden können, was zu einer Viele-zu-viele-Beziehung zwischen `Round` und `Range` führt — anstelle einer festen 1:1-Zuordnung.

**Score-Seeding ab Tag 2.** Das Stakeholder-Interview erwähnte Score-Seeding für die Startgruppenzuweisung ab Runde 2, ohne jedoch einen konkreten Algorithmus zu spezifizieren. `StartGroup` wurde als einfache Datenstruktur modelliert; die Seeding-Logik wurde in die Anwendungsschicht ausgelagert.

---

## 2. Wesentliche Modellierungsentscheidungen

**`CompetitionCategory` als Entität, nicht als Attributmenge.** Das Tripel `(style, division, classLevel)` war im Initialmodell Teil von `Registration` und erzeugte Redundanz über ~1.200 Datensätze. Die Erhebung zu einer eigenständigen Entität beseitigt diese Redundanz und vereinfacht kategorieseitige Abfragen (z. B. vollständige Rangliste je Kategorie).

**`TargetStation` und `ShotResult` als schwache Entitäten.** Beide sind existenziell von ihrer übergeordneten Entität abhängig — eine `TargetStation` hat außerhalb ihrer `Range` keine Bedeutung, ein `ShotResult` außerhalb seiner `ScoreCard` keine. Die Verwendung zusammengesetzter Schlüssel `(rangeId, targetNumber)` bzw. `(scoreCardId, targetNumber, arrowNumber)` macht diese Abhängigkeit explizit und vermeidet künstliche Surrogatschlüssel.

**`Person`-Supertyp.** Sowohl `Participant` als auch `Official` teilen die Attribute `firstName` und `lastName`. Statt einer Duplikation wurde ein gemeinsamer Supertyp `Person` eingeführt. Dies hält das Modell übersichtlich und antizipiert das wahrscheinliche logische Designmuster einer einzelnen `Person`-Tabelle mit rollenbasierter Spezialisierung.

**`TargetDistance` als Assoziationsklasse.** Die maximale Schussdistanz hängt sowohl von der `TargetStation` als auch von der `CompetitionCategory` ab und ist damit eine Eigenschaft der Beziehung zwischen beiden — nicht einer der Entitäten allein. Die Modellierung als eigenständige Assoziationsklasse vermeidet ein mehrwertiges Attribut auf `TargetStation`.

**Abgeleitete Attribute im Modell belassen.** `age`, `roundTotal`, `totalPoints` und `rankPosition` sind aus Basisdaten berechenbar. Sie wurden im Datenwörterbuch als abgeleitet markiert statt entfernt, da sie explizite Informationsbedürfnisse aller drei Stakeholder widerspiegeln und im logischen Design entweder materialisiert oder bedarfsweise berechnet werden müssen.

---

## 3. Stakeholder-Konflikte und deren Auflösung

**Granularität vs. Erfassungsaufwand.** Die IFAA-Scoring-Regeln erfordern die pfeilgenaue Erfassung (die Pfeilvorgabe bestimmt den Punktwert), was jedoch einen hohen Eingabeaufwand für die Ergebnisbeauftragte bedeutet. Der Konflikt wurde zugunsten der Regelkonformität entschieden: `ShotResult` erfasst jeden Pfeil einzeln. Das Interface-Design (außerhalb des Scopes) müsste den Aufwand durch effiziente UI-Muster abfedern.

**Vollständige Klassifizierungshistorie vs. praktische Machbarkeit.** Der Turnierdirektor wünschte eine vollständige IFAA-Klassifizierungshistorie für ~1.200 Schützen; die Ergebnisbeauftragte stellte fest, dass dies im Rahmen einer Einzelveranstaltung operativ nicht umsetzbar ist. Auflösung: Das System erfasst nur den bei der Anmeldung verifizierten Klassenstatus, keine historischen Ergebnisse. Ein Flag auf `Registration` (`classificationStatus`) zeigt an, ob die Karte geprüft wurde.

**Datensichtbarkeit (Datenschutz vs. operativer Bedarf).** Teilnehmer wünschten Kontrolle über öffentlich sichtbare Daten (z. B. Ausblenden des Geburtsdatums), während Turnierdirektor und Ergebnisbeauftragte vollständige interne Einsicht benötigen. Auflösung: Das konzeptuelle Modell speichert alle Daten einheitlich; Zugriffskontrolle und öffentliche/private Sichten werden in die logische oder Anwendungsschicht ausgelagert und als offene Frage markiert.

**`Protest` mit `Registration` statt `Participant` verknüpft.** Ein Protest betrifft eine konkrete Turnierteilnahme, nicht eine Person im Allgemeinen. Die Verknüpfung von `Protest` mit `Registration` statt `Participant` ist die semantisch sauberere Modellierungsentscheidung und löst einen impliziten Konflikt zwischen der operativen Sicht des Turnierdirektors und der datensemantischen Bedeutung.

---

## 4. Risiken und offene Fragen

- **Punktwert-Nachschlagetabelle.** Die exakte IFAA-Bewertungsmatrix (hitZone × arrowNumber × roundType → pointValue) wurde nicht formal bereitgestellt. Vor dem logischen Design muss diese Tabelle dokumentiert und gegen das aktuelle IFAA-Regelwerk validiert werden, damit `pointValue` zuverlässig berechnet werden kann.
- **Tie-Break-Verfahren im Detail.** Das Modell erfasst Schussergebnisse für Stechen, legt jedoch nicht fest, ob mehrere Shoot-off-Runden möglich sind oder wie die Siegerermittlung formalisiert wird. Die Auflösungslogik bedarf der Bestätigung durch den Turnierdirektor.
- **Zugriffskontrollmodell.** Die Datenschutzanforderungen (Abschnitt 3) sind auf Datenebene noch ungeklärt. Ein rollenbasiertes Zugriffsmodell muss spezifiziert werden, bevor das logische Schema finalisiert werden kann.
- **Range-Zuweisung bei parallelen Runden.** Wenn zwei Runden gleichzeitig auf separaten Ranges stattfinden, muss die Viele-zu-viele-Beziehung zwischen `Round` und `Range` durch einen Constraint eingeschränkt werden, um Planungskonflikte zu verhindern. Ein solcher Constraint ist im aktuellen Modell noch nicht vorhanden.
