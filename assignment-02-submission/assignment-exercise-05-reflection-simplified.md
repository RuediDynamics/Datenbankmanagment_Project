# Assignment 02 – Aufgabe 5: Annahmen, Designentscheidungen und Teamreflexion

**Domäne:** IFAA World Bowhunter Championships (WBHC) 2027, Bad Waldsee  
**Grundlage:** Aufgaben 1–4 (Anforderungen, konzeptuelles Modell, Datenwörterbuch)

---

## 1. Getroffene Annahmen

Mehrere Anforderungen waren unvollständig oder unklar und mussten deshalb durch klare Annahmen ergänzt werden.

**Begrenzung auf eine einzelne Veranstaltung.** Die IFAA-Regeln gelten zwar weltweit für Meisterschaften, das System bezieht sich jedoch nur auf die WBHC 2027 als einzelne `Event`-Instanz. Es wurde angenommen, dass frühere Ergebnisse anderer Turniere nicht berücksichtigt werden müssen. Dadurch war keine vollständige Historie der Klassifizierungen nötig. Stattdessen wird nur der bei der Anmeldung geprüfte Klassenstatus gespeichert.

**Teilnehmer bringen ihre Klassifizierungskarte selbst mit.** Es gab kein zentrales IFAA-Register für Teilnehmer. Deshalb wurde angenommen, dass Schützen ihre Klasse (A/B/C) selbst mit einer Klassifizierungskarte nachweisen. Die Aufgabe von Sandra Kleins besteht darin, diesen Status zu kontrollieren und zu dokumentieren — nicht ihn anhand alter Ergebnisse zu berechnen. Dadurch konnten die Entitäten `Registration` und `CompetitionCategory` einfacher gehalten werden.

**Mehrfache Nutzung von Ranges über mehrere Runden.** Die genaue Anzahl der verfügbaren Ranges in Bad Waldsee war nicht bekannt. Deshalb wurde angenommen, dass 4–8 Ranges in mehreren Runden erneut verwendet werden können. Dadurch entstand eine Viele-zu-viele-Beziehung zwischen `Round` und `Range` statt einer festen 1:1-Zuordnung.

**Score-Seeding ab Tag 2.** Im Stakeholder-Interview wurde erwähnt, dass ab Runde 2 die Startgruppen anhand der bisherigen Ergebnisse eingeteilt werden. Ein genauer Algorithmus wurde jedoch nicht beschrieben. Deshalb wurde `StartGroup` nur als einfache Datenstruktur modelliert, während die eigentliche Seeding-Logik in die Anwendungsschicht ausgelagert wurde.

---

## 2. Wichtige Modellierungsentscheidungen

**`CompetitionCategory` als eigene Entität statt als Attributgruppe.** Die Kombination `(style, division, classLevel)` war zuerst Teil von `Registration` und führte bei ungefähr 1.200 Datensätzen zu vielen Wiederholungen. Durch die Modellierung als eigene Entität wird Redundanz vermieden und Abfragen nach Kategorien (z. B. Ranglisten) werden einfacher.

**`TargetStation` und `ShotResult` als schwache Entitäten.** Beide existieren nur zusammen mit ihrer übergeordneten Entität — eine `TargetStation` ohne `Range` und ein `ShotResult` ohne `ScoreCard` haben keine Bedeutung. Zusammengesetzte Schlüssel wie `(rangeId, targetNumber)` oder `(scoreCardId, targetNumber, arrowNumber)` machen diese Abhängigkeit deutlich und vermeiden unnötige künstliche IDs.

**`Person` als gemeinsamer Supertyp.** Sowohl `Participant` als auch `Official` besitzen die Attribute `firstName` und `lastName`. Statt diese mehrfach zu speichern, wurde der gemeinsame Supertyp `Person` eingeführt. Dadurch bleibt das Modell übersichtlich und passt gut zu einer späteren gemeinsamen `Person`-Tabelle im logischen Design.

**`TargetDistance` als Assoziationsklasse.** Die maximale Schussdistanz hängt sowohl von der `TargetStation` als auch von der `CompetitionCategory` ab. Sie gehört daher zur Beziehung zwischen beiden Entitäten und nicht zu einer einzelnen Entität. Die Modellierung als eigene Assoziationsklasse verhindert komplizierte mehrwertige Attribute.

**Abgeleitete Attribute bleiben im Modell enthalten.** Werte wie `age`, `roundTotal`, `totalPoints` und `rankPosition` können zwar aus anderen Daten berechnet werden, wurden aber trotzdem im Datenwörterbuch beibehalten. Sie spiegeln wichtige Informationsbedürfnisse der Stakeholder wider und können später entweder gespeichert oder bei Bedarf berechnet werden.

---

## 3. Stakeholder-Konflikte und ihre Lösung

**Genauigkeit vs. Aufwand bei der Datenerfassung.** Die IFAA-Regeln verlangen die Erfassung jedes einzelnen Pfeils, da die Reihenfolge der Treffer den Punktwert beeinflusst. Für die Ergebnisbeauftragte bedeutet dies jedoch einen hohen Eingabeaufwand. Der Konflikt wurde zugunsten der Regelkonformität gelöst: `ShotResult` speichert jeden Pfeil einzeln. Das spätere Interface sollte den Aufwand durch eine benutzerfreundliche Oberfläche reduzieren.

**Vollständige Klassifizierungshistorie vs. praktische Umsetzbarkeit.** Der Turnierdirektor wollte eine komplette IFAA-Klassifizierungshistorie für etwa 1.200 Schützen speichern. Die Ergebnisbeauftragte hielt dies für eine einzelne Veranstaltung jedoch für nicht praktikabel. Deshalb speichert das System nur den überprüften Klassenstatus bei der Anmeldung und keine historischen Ergebnisse. Ein Flag in `Registration` (`classificationStatus`) zeigt an, ob die Karte geprüft wurde.

**Datenschutz vs. betriebliche Anforderungen.** Teilnehmer wollten kontrollieren können, welche persönlichen Daten öffentlich sichtbar sind, zum Beispiel das Geburtsdatum. Turnierdirektor und Ergebnisbeauftragte benötigen dagegen vollständigen Zugriff auf die Daten. Die Lösung war, alle Informationen vollständig im Modell zu speichern und die Zugriffsrechte später in der logischen oder Anwendungsschicht zu regeln.

**`Protest` wird mit `Registration` statt mit `Participant` verbunden.** Ein Protest bezieht sich auf eine konkrete Turnierteilnahme und nicht allgemein auf eine Person. Deshalb wurde `Protest` mit `Registration` verknüpft. Diese Lösung passt besser zur tatsächlichen Bedeutung der Daten.

---

## 4. Risiken und offene Fragen

- **Punktwert-Tabelle.** Die genaue IFAA-Bewertungsmatrix (hitZone × arrowNumber × roundType → pointValue) wurde noch nicht vollständig bereitgestellt. Vor dem logischen Design muss diese Tabelle dokumentiert und mit dem offiziellen IFAA-Regelwerk abgeglichen werden.
- **Tie-Break-Regeln im Detail.** Das Modell unterstützt Stechen, legt aber noch nicht fest, ob mehrere Shoot-off-Runden möglich sind oder wie genau der Sieger bestimmt wird. Dies muss noch mit dem Turnierdirektor geklärt werden.
- **Zugriffskontrolle.** Die Datenschutzanforderungen aus Abschnitt 3 sind noch nicht vollständig definiert. Vor der Fertigstellung des logischen Schemas muss ein rollenbasiertes Zugriffssystem ausgearbeitet werden.
- **Range-Zuweisung bei parallelen Runden.** Wenn mehrere Runden gleichzeitig stattfinden, muss verhindert werden, dass dieselbe `Range` doppelt vergeben wird. Dafür fehlt im aktuellen Modell noch ein passender Constraint.
