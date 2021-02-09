Skript zur DB-Migration nach MTH
================================

Exportiert Mitgliederdaten aus dem Graphen von [SKGB-intern][]
in das vom Vorstand verlangte Format.
Das Format des Vorstands ist bisher unvollständig spezifiziert
(siehe [Meilenstein][]), deswegen ist auch der Export bisher
noch unvollständig.

[SKGB-intern]: https://github.com/skgb/intern
[Meilenstein]: https://github.com/skgb/migration-intern-mth/milestone/1


Verwendung
----------

````sh
# Neo4j mit Daten befüllen
# (der bestehende Graph wird dabei gelöscht)
neo4j/bin/cypher-shell -u neo4j -f example.cypher

# Statistik über das Datenmodell
./model_stats.pl > model_stats.txt

# Tabelle ausgeben für LibreOffice etc. (zur Kontrolle)
./migration.pl --odf
./migration.pl --csv

# Tabelle ausgeben für MTH-Import
./migration.pl
````

Für die ausgegebene Tabelle wird der Dateiname `example` verwendet
(z. B. [example.csv][]).

[example.csv]: https://github.com/skgb/migration-intern-mth/blob/main/example.csv


Siehe auch
----------

- Beispieldatensatz für SKGB-intern: [example.cypher][]
- Altes Mockup von GS-Verein: [gs-verein-mockup][]

[example.cypher]: https://github.com/skgb/migration-intern-mth/blob/main/example.cypher
[gs-verein-mockup]: https://skgb.github.io/migration-intern-mth/gs-verein


Voraussetzungen
---------------

- Neo4j 3+
- Perl 5.24+ (mit u. a. [Neo4j::Driver][], [OpenOffice::OODoc][], [Text::CSV][])
- `Neo4j_Auth.pm` mit `sub neo4j_auth { ( neo4j => 'password' ) }`
- ggf. `intern.cypher`

[Neo4j::Driver]: https://metacpan.org/release/Neo4j-Driver
[Text::CSV]: https://metacpan.org/release/Text-CSV
[OpenOffice::OODoc]: https://metacpan.org/release/OpenOffice-OODoc


Weiterverwendung
----------------

(c) 2021 [Arne Johannessen](https://arne.johannessen.de/)

Dies ist freie Software, weiterverwendbar unter den Bedingungen der
[Artistic License 2.0](https://github.com/skgb/migration-intern-mth/blob/main/LICENSE).
