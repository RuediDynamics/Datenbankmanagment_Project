## Task 7: Reflection & Handover {#sec-task7-reflection}

**Exercise 7 – Explain Physical Design Decisions and Operational Risks**

### Wichtigste Trade-offs und ihre Begründung

Der prägendste Trade-off betrifft die **Repräsentation abgeleiteter Daten**. Das
Team hat `roundTotal` bewusst *zweistufig* entworfen: zunächst als bedarfsberechnete
View, dann — nach der Performance-Beobachtung an der Rangliste — als gespeicherte,
trigger-gepflegte Spalte (Iteration A). Diese Entscheidung folgt dem Kernkriterium
von Kap. 18: Lesefrequenz gegen Schreibkosten und Konsistenzrisiko. Da die
Live-Rangliste (T5) von allen drei Stakeholder-Rollen häufig gelesen wird, die
Rohschüsse (T4) aber nur einmal geschrieben werden, überwiegt der Lese-Nutzen die
zusätzliche O(1)-Schreiblast klar. `totalPoints`/`rankPosition` gehen einen Schritt
weiter und sind **materialisiert** mit kontrolliertem Batch-Refresh — ein bewusster
Verzicht auf Sofort-Konsistenz zugunsten von Leselatenz, vertretbar, weil Ranglisten
fensterweise (nicht schussweise) aktualisiert werden.

Der zweite Trade-off ist die **kontrollierte Denormalisierung** `score_card.range_id`
(aus A03 übernommen): eine minimale Redundanz, die den 4-fach-Join für jeden der
~201.600 Schuss-Inserts vermeidet und zugleich die Voraussetzung für die
atTarget-Prüfung (Iteration B) schafft. Der dritte betrifft **Indizierung**: `shot_result`
erhält bewusst nur einen einzigen Sekundärindex (`tie_break_id`), um den kritischen
Insert-Pfad T4 nicht zu verteuern — Leseanforderungen dieser Tabelle werden vom
zusammengesetzten Primärschlüssel bedient.

### Testergebnisse und Wirkung der Iteration

Alle 14 Testfälle (8 funktional, 6 Constraint über vier Kategorien) bestehen. Zwei
Iterationen wurden im Test *sichtbar*: PT-14 deckte auf, dass der zusammengesetzte
atTarget-Verweis ohne Trigger nicht erzwungen wurde (Korrektheitslücke → Iteration B);
die Plan-Analyse an T5 motivierte die Umstellung von `roundTotal` (Performance →
Iteration A). Nach der Revision lehnt PT-14 ungültige Ziele ab, und die Rangliste
summiert 4.800 statt 201.600 Zeilen. Damit ist der geforderte Nachweis „initial vs.
revised" durch ausführbare Tests und getrennte Migrationsskripte belegt.

### Bekannte Grenzen und operative Risiken

- **Zeilenübergreifende Regeln nur teilweise DBMS-erzwungen.** C26 (round_date im
  Event-Fenster), C103 (start_target ≤ Ziele der Range), C105 (lückenlose
  Pfeil-Sequenz) und C110 (Protest-Fenster) sind derzeit als Wertebereichs-`CHECK`
  plus Anwendungslogik abgesichert. Risiko: fehlerhafte App-Schicht könnte
  Teilverletzungen einschleusen. Minderung: Triggerisierung analog atTarget bei Bedarf.
- **Trigger-Konsistenz von `round_total`.** Bulk-Korrekturen an `shot_result` unter
  Umgehung des Triggers (z. B. `COPY` mit deaktivierten Triggern) würden die Summe
  divergieren lassen; ein periodischer Abgleich gegen `v_score_card_total` ist als
  Kontrolle empfohlen.
- **Kein RBAC / Datenschutz im Schema** (A02-Konflikt bewusst ausgelagert): das
  sichtbare `birth_date` erfordert anwendungsseitige Sichtbarkeitskontrolle.

### Empfehlungen für die nächste Phase (Handover)

1. **Monitoring/Tuning:** `pg_stat_statements` aktivieren; die Refresh-Dauer von
   `mv_tournament_ranking` und die T4-Insert-Rate beobachten; `autovacuum` auf
   `shot_result` prüfen.
2. **Security-Härtung:** Rollen (`director`, `results_officer`, `read_public`) mit
   spaltenweiser Sicht (Verbergen von `birth_date` für öffentliche Rollen), sowie
   Least-Privilege-`GRANT`s.
3. **Backup/Recovery:** tägliches `pg_dump` plus WAL-Archivierung (PITR) während der
   Turniertage; Wiederherstellung vor jedem Scoring-Tag testen.
4. **Zukünftiges Wachstum:** bei einer Mehr-Event-Serie zuerst `shot_result` nach
   `event_id`/`round_id` **partitionieren** und die Rangliste je Event refreshen;
   das Schema ist dank durchgängigem `event_id` bereits vorbereitet (A03 Task 5).
