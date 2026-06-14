## Task 5: Review, Optional Merge, and Future Growth

### Review mit Stakeholdern (Step 2.5)

Das logische Modell wurde gegen die drei Personas aus Assignment 01/02
gegengeprüft. **Terminologie:** Die Benennung ist durchgängig konsistent zum
konzeptuellen Modell (`Registration`, `CompetitionCategory`, `ScoreCard`,
`StartGroup` …); konzeptuelle Beziehungsnamen wurden als Assoziationslabels
übernommen, sodass Klaus Brenner (Turnierdirektor), Maria Weiss (Schützin) und
Sandra Klein (Ergebnisbeauftragte) dieselben Begriffe wiedererkennen.
**Constraints:** Die Domänen- und Geschäftsregeln (C1–C26) bestätigen die
Workflow-Zustände der Stakeholder, insbesondere Startzulassung (C24),
Doppelanmeldungssperre (C19) und Startgruppengröße (C22). **Transaktionsstütze:**
Die in Assignment 02 validierten Transaktionen T1–T8 bleiben durch das
Relationenschema abbildbar; die formale Transaktions-zu-Relation-Matrix wird in
Task 3 nachgereicht.

### Optionaler Merge lokaler Modelle (Step 2.6)

**Nicht anwendbar.** Das Team hat in Assignment 02 ein einziges, bereits
konsolidiertes konzeptuelles Modell über alle drei Stakeholder-Sichten erstellt
(keine getrennt gepflegten lokalen Views). Synonyme und Homonyme wurden schon
konzeptuell aufgelöst (z. B. „Score Category" → `CompetitionCategory`). Es liegt
folglich nur ein globales logisches Modell vor; ein Merge entfällt.

### Future-Growth-Check (Step 2.7)

Drei plausible zukünftige Anforderungen und ihre Auswirkung:

1. **Mehrere Veranstaltungen und Klassifizierungshistorie.** Aktuell ist das
   System bewusst auf die WBHC 2027 als einzelne `Event`-Instanz begrenzt (A02-
   Annahme). Eine Erweiterung auf eine Serie verlangt das Lösen der
   Single-Event-Annahme und eine neue Relation
   `ClassificationHistory(participantId, eventId, classLevel, verifiedDate)`. Der
   Großteil des Schemas (Event-bezogene FKs) ist bereits mehrfach-event-fähig,
   da `eventId` durchgängig geführt wird.

2. **IFAA-Bewertungsmatrix als Daten.** Der derzeit offene Punkt „Punktwert-
   Tabelle" (A02 §4) wird durch eine Lookup-Relation
   `ScoringRule(roundType, hitZone, arrowNumber, pointValue)` geschlossen.
   Auswirkung gering: `ShotResult.pointValue` (abgeleitet) referenziert dann diese
   Tabelle, und Constraint C21 wird über sie erzwingbar.

3. **Rollenbasierte Zugriffskontrolle / Datenschutz.** Der Datenschutzkonflikt
   (sichtbares Geburtsdatum) und die fehlende Zugriffskontrolle (A02 §4) erfordern
   neue Entitäten `User`, `Role`, `Permission` sowie Sichtbarkeits-Flags auf
   `Participant`. Dies betrifft die Anwendungs-/Sicherheitsschicht und lässt das
   Kernschema weitgehend unverändert.

Weitere absehbare Punkte (mehrstufige Shoot-offs; Verhinderung von Range-
Doppelbelegung bei parallelen Runden, C25) sind über zusätzliche Attribute bzw.
temporale Constraints lokal erweiterbar, ohne strukturellen Umbau.
