============================================================
PROJEKTANWEISUNGEN – WICHTIGE ARBEITSREGELN
============================================================

Dieses Dokument enthält die DAUERHAFTE Vision und die grundlegenden
Entwicklungsregeln des Projekts.

Es enthält absichtlich KEINEN dauerhaft festgeschriebenen technischen
Projektstand.

Der tatsächliche Code ist immer die maßgebliche Quelle dafür,
was bereits implementiert wurde.


============================================================
AKTUALISIERTER VERBINDLICHER DESIGNRAHMEN – 2026-10-25
============================================================

DIESE NEUEREN BESCHLÜSSE HABEN VORRANG VOR ÄLTEREN
THIRD-PERSON-, ESEL-, NPC-SPÄTER- UND BASE-DEFENSE-PASSAGEN
WEITER UNTEN. Für Details siehe ENTWICKLUNGSPLAN.md, Abschnitte 1 und 4.

- BASIS: stilisierte Low-Poly-3D-Ruinenstadt, isometrische
  Going-Medieval-artige Kamera, Mausauswahl, Bauplanung,
  NPC-Aufträge statt permanenter direkter Charaktersteuerung.
- SPIELERFIGUR: erster autonom arbeitender Siedlungsbewohner
  mit denselben Auftragsmechaniken wie spätere NPCs.
- ABENTEUER: dieselbe Figur wird direkt gesteuert, in
  Stardew-Valley-artiger Top-down-/Schrägansicht; 3D bleibt
  vorläufig bestehen.
- BASIS LÄUFT WÄHREND EXPEDITIONEN WEITER: NPC-Arbeit,
  Transporte, Pflanzen und Produktion. Abwesender Held
  kann nicht gleichzeitig in der Basis arbeiten. Vereinfachte
  Hintergrundsimulation ist zulässig.
- ARBEIT/LOGISTIK: NPCs bergen, sammeln, bauen, transportieren,
  bewirtschaften und bedienen aktive Werkstationen. Physische
  Kisten und reale Transporte bleiben Pflicht.
- KEIN ESEL IM KERNSPIEL: Esel, Kühe, Hühner und weitere
  Nutztiere sind mögliche spätere Erweiterungen.
- NPC-TIEFE B: überschaubare individuelle Fähigkeiten,
  Prioritäten, Vorlieben und wenige Bedürfnisse. Neue
  Bewohner reisen an oder werden durch Expeditionen/Quests
  gewonnen; besondere ehemalige Bewohner können Hinweise
  und Fähigkeiten mitbringen.
- FUNKTIONSRÄUME (REGEL C): Ein geschlossener Raum kann genau
  eine Hauptfunktion (z. B. Schmiede, Küche, Zimmermannswerkstatt)
  haben; andere Tätigkeiten und Stationen bleiben erlaubt.
  Spezialisierung setzt bestimmte nutzbare Raumobjekte voraus;
  genaue Anforderungen/Boni sind noch offen.
- ARBEITSZUWEISUNG: NPCs werden Räumen bzw. konkreten
  Arbeitsplätzen zugeteilt und führen Produktionsaufträge aus.
  Parallelität richtet sich nach vorhandenen Arbeitsplätzen.
- RAUMLAGER: echte Kisten/Regale mit lokalem Inventar,
  kein unsichtbares gemeinsames Rauminventar. Transport-NPCs
  füllen Bedarf auf; andernfalls holen Handwerker selbst
  Material. Blockaden und fehlende Ressourcen anzeigen.
- SPÄTER: Produktionsketten, Reihenfolge der Räume,
  automatische Zielbestände und optional Transporttiere.
  Diese Features nicht vorzeitig implementieren.
- BAUSYSTEM: Einzelbauteile und komplette, nachträglich
  bearbeitbare Gebäudevorlagen nutzen dieselben Bau-/Raster-/
  Baustellenregeln. Vorlagen bleiben modular editierbar.
- MAUERBAU B: Hauswände auf Rasterkanten; Holzpalisaden aus
  Pfählen als ziehbare Linien; massive Steinmauern aus größeren
  stapelbaren Rasterblöcken, nicht aus Einzelsteinen.
  Steinblock-Oberseiten bei gültigem Zugang grundsätzlich
  begehbar; Wehrgänge/Plattformen, Brüstungen, Zinnen, Treppen,
  Türme und Torhäuser separat und schrittweise ergänzen.
  Linien erzeugen reguläre einzelne Baustellen.
- MAUER-FORTSCHRITT: Palisaden reparieren/abbauen, Holz
  teilweise wiederverwenden; später Steinmauern mit optionalen
  Wehrgängen und Zinnen. Zuerst Höhenbelegung/Validierung,
  dann Linienbau, dann Stapelung/Navigation. Keine frühe
  komplexe Statik oder komplette Festungsverteidigung.
- STARTWELT: zerstörte Stadt; Ruinen können Ressourcen,
  restaurierbare Gebäude, Wege und Fundstellen enthalten.
- STIMMUNG: gemütlicher Wiederaufbau mit düsterer Vergangenheit.
  Ermittlung als spätere Mechanik denkbar (Hinweise, Zeugnisse,
  Ermittlungsbuch), aber konkrete Story, Täter und Figuren
  sind ausdrücklich NICHT beschlossen.
- BASISANGRIFFE: sehr spät, zunächst isometrisch mit NPCs.
  Direkte Übernahme des Helden während Schlachten erst
  viel später optional.
- ENTWICKLUNG: zuerst Godot-Iststand prüfen, dann isometrische
  Kamera/Maussteuerung und einen autonomen Arbeitsauftrag
  als kleinen vertikalen Schnitt. Keine ungefragten Änderungen.
- PROJEKTFOKUS: Die alten HTML/CSS/JavaScript-Dateien vollständig
  ignorieren. Nicht lesen, ändern, testen oder als Referenz verwenden,
  solange der Nutzer sie nicht ausdrücklich wieder aktiviert.


============================================================
VERBINDLICHE ZWEI STEUERUNGSMODI – 2026-11-05
============================================================

DIESE NEUE ENTSCHEIDUNG PRÄZISIERT UND ERSETZT ÄLTERE PASSAGEN
ZUR BASIS- UND CHARAKTERSTEUERUNG.

MODUS 1 – AUTONOMER BASIS-/SIEDLUNGSMODUS:

- Die Spielerfigur ist derselbe Bewohner wie im Direktmodus, wird hier
  aber grundsätzlich wie jeder andere NPC gesteuert.
- Vorbilder sind Going Medieval und Stranded: Alien Dawn.
- Der Spieler plant, priorisiert und stellt Arbeit in Warteschlangen.
  Bewohner wählen geeignete offene Aufgaben selbstständig aus und
  führen sie vollständig aus.
- Dazu gehören insbesondere Sammeln/Bergen, Ressourcenabbau, Farming,
  Transport, Einlagern, Bauen, Crafting, Produktion und Reparaturen.
- Physische Ressourcen, Kisten, Inventare und tatsächliche Laufwege
  bleiben verpflichtend. Die Automatisierung darf keine Gegenstände
  teleportieren oder Bestände nur vortäuschen.
- Der Spieler soll NICHT jeden Transport einzeln befehlen müssen. Ein
  Ablauf wie "Pickup anklicken, danach Zielkiste anklicken" ist für den
  normalen Basismodus zu viel Micromanagement und daher kein Zielbild.
- Kontextbefehle dürfen Aufgaben erzeugen oder priorisieren. Ein
  Rechtsklick auf einen Gegner erzeugt beispielsweise einen Angriffsbefehl;
  die ausgewählte Figur navigiert zum Gegner und bekämpft ihn autonom.
- Direkte Einzelbefehle sind Ausnahmen für Priorisierung, Notfälle oder
  taktische Entscheidungen, nicht der normale Ablauf jeder Routinearbeit.
- Die Spielerfigur verwendet dieselbe Auftrags-, Prioritäts-, Wegfindungs-
  und Arbeitslogik wie alle späteren Bewohner. Keine dauerhafte Sonder-KI
  nur für den ersten Charakter bauen.

MODUS 2 – DIREKTER CHARAKTERMODUS:

- Der Spieler steuert dieselbe Figur selbst, ungefähr im Stil von Fae Farm:
  direkt laufen, zu Weltobjekten gehen, interagieren, Werkzeuge benutzen,
  Ressourcen sammeln, arbeiten und kämpfen.
- Inventar, Ausrüstung, Werte, Position und Weltzustand bleiben zwischen
  beiden Modi erhalten. Es ist keine getrennte Abenteuerfigur.
- Während der direkten Kontrolle erledigt diese Figur nicht gleichzeitig
  einen autonomen Auftrag. Andere Bewohner arbeiten weiterhin selbstständig.
- Ob ein beim Moduswechsel laufender Auftrag pausiert, freigegeben oder neu
  eingereiht wird, wird beim Ausbau der Warteschlange konkret festgelegt.

ARCHITEKTURFOLGE:

- Manuelle und autonome Bedienung sollen nach Möglichkeit dieselben
  Gameplay-Aktionen verwenden. Beispiel: Sowohl der direkte Tastendruck als
  auch ein NPC-Auftrag rufen dieselbe eigentliche Ernte-/Bau-/Angriffslogik auf.
- Der nächste Ausbau des Basismodus priorisiert deshalb einen gemeinsamen
  Arbeitsvorrat, autonome Auftragswahl und nachvollziehbare Prioritäten statt
  weiterer kleinteiliger Rechtsklick-Transportbefehle.


============================================================
TECHNISCHE PRÄZISIERUNG DER ZWEI MODI – 2026-11-05
============================================================

DIES IST EINE AUSARBEITUNG DER OBIGEN ENTSCHEIDUNG, KEIN
AUFTRAG ZUR SOFORTIGEN IMPLEMENTIERUNG. Unentschiedene
Designfragen bleiben ausdrücklich offen.

GEMEINSAME SPIELLOGIK:
- Charaktermodus und Basismodus sind zwei Steuerungsarten derselben
  Spielfigur und derselben Welt, keine getrennten Spielstände.
- Gameplay-Regeln für Ernte, Ressourcenentnahme, Lieferung,
  Bauen, Produktion und später Kampf sollen in wiederverwendbaren
  Aktionen/Services liegen. Manuelle Interaktion und NPC-Aufträge
  lösen dieselben Regeln aus, auch wenn Animation/Input abweichen.
- Ein Arbeitsauftrag beschreibt ein Ziel und seinen Bedarf; er
  erzeugt keine Ressourcen. Tatsächliche Materialien müssen in
  Inventaren, Welt-Pickups oder physischen Lagern existieren.
- Zustandsänderungen müssen eindeutig erfolgen: keine doppelte
  Entnahme, doppelte Belohnung oder Fertigstellung bei Abbruch,
  Szenenwechsel oder gleichzeitigem Zugriff.

AUTONOMER BASISMODUS:
- Spieler markiert Arbeiten oder legt Produktions-/Bauaufträge an,
  statt jedem Bewohner jede Teilbewegung vorzugeben.
- Ein gemeinsamer Auftragsvorrat unterscheidet offene, reservierte,
  laufende, blockierte und abgeschlossene/abgebrochene Arbeit.
  Die exakten Datenstrukturen sind nach Codeprüfung festzulegen.
- Geeignete freie Bewohner suchen selbst Aufgaben anhand einfacher
  Prioritäten, Erreichbarkeit, Voraussetzungen und Verfügbarkeit.
  Für die erste Version genügt eine transparente, deterministische
  Auswahl; spätere Fähigkeiten und persönliche Prioritäten
  können sie erweitern.
- Ein vollständiger Auftrag darf mehrere Teilaktionen erfordern:
  z. B. Holzquelle finden -> hinlaufen -> Holz entnehmen ->
  Baustelle erreichen -> Material liefern -> Bauarbeit ausführen.
  Teilaktionen sind interne Ausführungsschritte, keine Pflicht
  zu einzelnen Spielerbefehlen.
- Für normale Lagerlogistik werden Lieferbedarfe aus echten
  Baustellen-/Produktions-/Lageranforderungen abgeleitet.
  Fehlen Transport-NPCs, darf ein arbeitender Bewohner bei
  Bedarf selbst Material holen (entsprechend Raumregel C).
- Bei fehlendem Material, Werkzeug, Lagerplatz oder erreichbarem
  Weg wird ein Auftrag nachvollziehbar blockiert und später
  erneut geprüft, nicht endlos ohne Fortschritt wiederholt.
- Kontextbefehle können gezielt priorisieren oder zuweisen.
  Ein Gegner-Rechtsklick ist ein künftiger taktischer Angriffsbefehl,
  der autonome Bewegung und Kampf auslöst, keine sofortige
  Fernwirkung. Kampf ist kein verpflichtender Teil des ersten
  Arbeitswarteschlangen-Meilensteins.

DIREKTER CHARAKTERMODUS:
- Eingaben bewegen und bedienen dieselbe Figur unmittelbar;
  die Figur darf währenddessen keinen autonomen Job ausführen.
- Bei einem Moduswechsel müssen aktuelle Bewegung, asynchrone
  Arbeit und Reservierungen konsistent behandelt werden.
  Die genaue Entscheidung (pausieren, freigeben, neu einreihen)
  bleibt offen und ist vor Implementierung festzulegen.
- Andere Bewohner setzen ihre autonomen Arbeiten unabhängig vom
  Wechsel der Spielersteuerung fort.
- Inventar, Ausrüstung, Gesundheit, Hunger, Position und bereits
  ausgeführte Weltänderungen bleiben unverändert erhalten.

IMPLEMENTIERUNGSLEITLINIE FÜR CODEX:
1. Aktuelle Godot-Skripte für Main/Input, Player, JobManager,
   Navigation, Inventar, Baustelle und Ressourcenquelle prüfen.
2. Bestehende manuelle Einzelbefehle als Iststand dokumentieren,
   aber nicht als Zielbild der autonomen Siedlung fortschreiben.
3. Einen kleinen vertikalen Schnitt vorschlagen: markierte
   Ressourcenarbeit -> offener Auftrag -> freie Spielfigur als
   erster NPC wählt ihn -> läuft hin -> erledigt ihn -> Ergebnis
   ist physisch vorhanden -> verständlicher Status.
4. Erst danach automatischen Materialtransport und mehrstufige
   Baustellenversorgung als eigene testbare Meilensteine planen.
5. Tutor-/Ausführungsmodus aus diesem Dokument beachten;
   niemals allein aufgrund dieser Spezifikation Code ändern.

============================================================
AKTUELLEN PROJEKTSTAND BESTIMMEN
============================================================

Bevor du eine neue Entwicklungsaufgabe planst:

1. Lies die relevanten vorhandenen Projektdateien.

2. Ermittle anhand des tatsächlichen Codes:
   - welche Systeme bereits existieren
   - welche Systeme funktionieren
   - welche Systeme gerade im Umbau sind
   - welche Architektur aktuell verwendet wird

3. Verlasse dich NICHT auf alte Statusangaben aus vorherigen Gesprächen.

4. Implementiere nichts erneut, nur weil es in der langfristigen
   Roadmap aufgeführt ist.

Die Roadmap beschreibt eine Entwicklungsrichtung und keine Checkliste,
die blind von oben nach unten abgearbeitet werden muss.


============================================================
AKTUELLER FOKUS
============================================================

Der aktuelle Fokus ist NICHT dauerhaft Bestandteil der Spielvision.

Er ergibt sich aus:

1. meiner letzten ausdrücklichen Entscheidung
2. dem aktuellen Code
3. dem nächsten sinnvollen Entwicklungsschritt

Meine letzte ausdrückliche Entscheidung hat dabei Vorrang.

Wenn ich beispielsweise sage:

"Ich möchte jetzt die Heimatbasis anfangen."

darfst du mich nicht deshalb zurück zu einem älteren Combat-Meilenstein
schicken, weil dieser noch irgendwo in einer Roadmap steht.

Wenn kein aktueller Fokus eindeutig genannt wurde:

- analysiere den Code
- ordne den aktuellen Entwicklungsstand ein
- schlage den nächsten sinnvollen Meilenstein vor
- beginne nicht automatisch mit der Implementierung


============================================================
AKTUELLER DESIGNFOKUS DES SPIELS
============================================================

Die derzeitige langfristige Spielrichtung lautet:

ACTION-SURVIVAL-RPG
+
BASE BUILDING
+
BASE DEFENSE
+
EXPLORATION
+
DUNGEONS
+
CRAFTING / FARMING / PRODUCTION
+
NPC-RECRUITMENT

Die dauerhafte Heimatbasis ist inzwischen ein zentraler Bestandteil
der Spielvision.

Der Spieler soll:

- seine Basis aufbauen
- Gebäude errichten
- craften
- Pflanzen anbauen
- Produktionssysteme entwickeln
- NPCs anwerben
- Verteidigungen errichten
- seine Basis gegen Angriffe verteidigen

Gleichzeitig verlässt er die Basis für:

- Dungeons
- andere Maps
- seltene Ressourcen
- Loot
- Bosse
- neue NPCs
- neue Technologien
- Storyfortschritt

Combat soll weiterhin eines der wichtigsten und spaßigsten Systeme sein.

Die Base ersetzt Combat und Exploration NICHT.

Sie gibt ihnen einen langfristigen Zusammenhang.


============================================================
DER ZENTRALE SPIELKREISLAUF
============================================================

BASE
↓
bauen / produzieren / craften / vorbereiten
↓
EXPEDITION
↓
erkunden / kämpfen / Dungeon
↓
Loot / seltene Ressourcen / NPCs
↓
BASE
↓
neue Gebäude / Waffen / Verteidigungen
↓
ANGRIFF
↓
Basis aktiv verteidigen
↓
Schäden beheben / Belohnungen nutzen
↓
stärkere Expedition
↓
stärkere Base
↓
größere Bedrohung


============================================================
TUTOR-MODUS
============================================================

Standardmäßig bist du mein Programmier-Tutor.

Ich soll möglichst viel selbst programmieren.

Deshalb:

- Erkläre neue Konzepte.
- Gib mir sinnvolle Programmieraufgaben.
- Lass mich Lösungen ausprobieren.
- Prüfe anschließend meinen Code.
- Erkläre Fehler und deren Ursache.
- Gib zunächst Hinweise, wenn ich selbst weiterkommen kann.
- Refactoring soll ebenfalls Teil des Lernprozesses sein.

ABER:

Der Tutor-Modus darf die Entwicklung nicht künstlich verlangsamen.

Eine Aufgabe soll einen sichtbaren und zusammenhängenden Fortschritt
am Spiel erzeugen.

Eine Aufgabe darf mehrere eng zusammengehörige Teilschritte enthalten.

Beispiel:

GUT:

"Wir bauen jetzt eine einfache Holzmauer:
- Wall-Klasse
- Position
- HP
- Darstellung"

Das ist ein zusammenhängendes Feature.

NICHT GUT:

Heute:
"Erstelle eine Variable wallHealth."

Danach:
"Jetzt gib ihr den Wert 100."

Danach:
"Jetzt schreibe eine Funktion."

Aufgaben sollen Lernfortschritt UND sichtbaren Spielfortschritt erzeugen.


============================================================
DATEIÄNDERUNGEN IM TUTOR-MODUS
============================================================

Im Tutor-Modus veränderst du meine Dateien nicht selbstständig.

Direkte Dateiänderungen erfolgen nur im ausdrücklich angeforderten
Ausführungs-Modus.

Behalte vorhandene Kommentare, Benennungen und Codestrukturen möglichst bei.

Ändere sie nur, wenn:

- sie fehlerhaft sind
- sie das aktuelle Feature behindern
- Refactoring ausdrücklich Teil der Aufgabe ist

Wenn ich nach einer Programmieraufgabe nur mit:

- "ok"
- "done"
- "fertig"
- oder einer ähnlichen kurzen Bestätigung antworte

prüfe zuerst meine aktuelle Umsetzung,
bevor du die nächste Aufgabe stellst.

Wenn ich ausdrücklich nur um eine Prüfung bitte,
verändere die Dateien dabei nicht.


============================================================
AUSFÜHRUNGS-MODUS
============================================================

Wenn ich ausdrücklich sage:

- "setz das um"
- "implementiere das"
- "repariere das"
- "ändere die Dateien"
- "mach das für mich"
- "passe den Code an"

darfst und sollst du die entsprechenden Dateien direkt bearbeiten.

In diesem Fall musst du nicht darauf warten,
dass ich den Code selbst schreibe.

Nach einer direkten Implementierung:

1. Erkläre kurz, was geändert wurde.
2. Erkläre wichtige neue Konzepte.
3. Weise auf relevante Architekturentscheidungen hin.
4. Nenne mögliche Probleme oder offene Punkte.

So kann ich auch aus Code lernen,
den du direkt implementiert hast.


============================================================
TESTEN NACH ÄNDERUNGEN
============================================================

Nach direkten Codeänderungen:

- JavaScript-Syntax prüfen
- offensichtliche Laufzeitfehler prüfen
- relevante HTML/DOM-Verbindungen prüfen
- relevante CSS-Verbindungen prüfen
- vorhandene Tests ausführen, falls vorhanden
- keine funktionierenden bestehenden Systeme unnötig beschädigen

Danach kurz angeben:

GETESTET:
Was tatsächlich überprüft wurde.

MANUELL TESTEN:
Was ich im Browser selbst ausprobieren sollte.

Behaupte niemals,
etwas im Browser getestet zu haben,
wenn du es nicht tatsächlich testen konntest.


============================================================
ARCHITEKTURREGEL
============================================================

Behalte die langfristige Vision im Hinterkopf.

Wir benötigen langfristig unter anderem:

- viele Gegner
- große Angriffswellen
- Gebäude
- Verteidigungsanlagen
- NPCs
- Dungeons
- mehrere Maps
- Farming
- Produktion
- Inventar
- Save Games

ABER:

Entwickle keine unnötig komplizierte Architektur
nur aufgrund zukünftiger Möglichkeiten.

Grundprinzip:

EINFACH
→ FUNKTIONIEREND
→ TESTEN
→ VERSTEHEN
→ ERWEITERN
→ REFACTORING WENN NÖTIG

Wenn die bestehende Architektur für ein neues System problematisch wird:

1. Problem konkret zeigen.
2. Ursache erklären.
3. Alternativen nennen.
4. sinnvolle Lösung empfehlen.
5. Refactoring gemeinsam durchführen.


============================================================
FEATURE-CREEP-REGEL
============================================================

Die langfristige Vision ist KEINE aktuelle To-do-Liste.

Wenn wir beispielsweise gerade Base Building entwickeln,
implementiere nicht gleichzeitig:

- Farming
- NPC-Berufe
- Angriffswellen
- Produktionsketten
- Pathfinding
- Jahreszeiten

nur weil diese Systeme später miteinander verbunden sind.

Baue zuerst die kleinste Version,
mit der das aktuelle System tatsächlich spielbar getestet werden kann.


============================================================
DESIGNENTSCHEIDUNGEN
============================================================

Bei neuen Features frage:

1. Macht das Feature das Spiel interessanter?
2. Unterstützt es Combat, Exploration oder Base Defense?
3. Erzeugt es Entscheidungen?
4. Interagiert es sinnvoll mit bestehenden Systemen?
5. Erzeugt es unnötigen Grind?
6. Können wir zunächst eine einfachere Version bauen?

Features werden nicht nur eingebaut,
weil vergleichbare Spiele sie besitzen.


============================================================
WICHTIGE DESIGNPHILOSOPHIE
============================================================

Combat, Exploration und Base Defense bilden gemeinsam den Kern.

Farming, Crafting und Produktion unterstützen diesen Kern.

Die Basis soll mit wachsendem Fortschritt zunehmend automatisierbar werden.

Der Spieler soll NICHT irgendwann jeden Tag:

- 80 Pflanzen einzeln gießen
- 30 Maschinen einzeln anklicken
- jeden Bewohner einzeln verwalten

müssen.

Neue NPCs, Gebäude und Technologien sollen Routinearbeit zunehmend
automatisieren.

Dadurch kann der Spieler mehr Zeit mit:

- Kämpfen
- Dungeons
- Exploration
- strategischem Base Building
- großen Verteidigungsschlachten

verbringen.


============================================================
NPC-DESIGN
============================================================

NPCs sind eine besonders wichtige Belohnung für Exploration.

NPCs können:

- in anderen Maps gefunden werden
- gerettet werden
- durch Quests angeworben werden
- nach Bosskämpfen freigeschaltet werden

Sie sollen einen konkreten Nutzen besitzen.

Beispiele:

Schmied:
verbessert Waffen

Farmer:
automatisiert Landwirtschaft

Baumeister:
verbessert Mauern / Reparaturen

Bogenschütze:
kann Wachtürme bemannen

Magier:
verteidigt die Basis mit Magie

Heiler:
unterstützt Verteidiger

Besondere NPCs dürfen einzigartige Boni besitzen.

Dadurch entsteht:

EXPLORATION
→ NPC ENTDECKEN
→ NPC ANWERBEN
→ BASE VERBESSERN
→ STÄRKERE ANGRIFFE ÜBERLEBEN


============================================================
BASE-DEFENSE-PHILOSOPHIE
============================================================

Base Defense soll NICHT nur passiv ablaufen.

Zwischen angekündigten Angriffen ist die Heimat sicher und ruhig.

Basisangriffe dürfen Farming, Crafting und Bauen nicht ständig unterbrechen.

Der Spieler soll ausreichend Zeit zur Vorbereitung erhalten.

Die Bedrohung steigt hauptsächlich durch:

- Storyfortschritt
- abgeschlossene Expeditionen
- freigeschaltete Regionen
- bewusst erreichte Progressionsmeilensteine

Eine stärkere Basis soll dem Spieler insgesamt einen Vorteil geben.

Der Ausbau der Basis darf nicht allein dazu führen,
dass unverhältnismäßig stärkere Angriffe entstehen
und sich Verbesserungen wie eine Bestrafung anfühlen.

Für die erste Basisverteidigung bleiben Kamera und Steuerung isometrisch;
NPCs verteidigen anhand von Befehlen. Direkte Spielerübernahme
während Angriffen ist eine optionale, sehr späte Erweiterung.

Ein guter Angriff erzeugt Entscheidungen:

- Welche Front verteidige ich persönlich?
- Welcher Spezialgegner ist am gefährlichsten?
- Muss ich einen Mauerdurchbruch verhindern?
- Muss ich einen explodierenden Gegner stoppen?
- Unterstütze ich meine NPCs?
- Kann ich eine andere Front kurz alleine lassen?

Spätere Gegner sollen unterschiedliche Verteidigungsprobleme erzeugen.

Beispiel:

Zombie:
Masse

Läufer:
Geschwindigkeit

Stink-Blopp:
explodiert an Mauern

Tank:
zerstört Verteidigungen

Fernkämpfer:
greift Verteidiger an

Boss:
verändert den Ablauf der gesamten Angriffswelle


============================================================
SESSION-START
============================================================

Bei einer neuen Entwicklungsaufgabe:

1. Lies den relevanten aktuellen Code.

2. Ermittle den tatsächlichen Projektstand.

3. Beachte meine letzte ausdrückliche Zielsetzung.

4. Prüfe, ob das gewünschte Feature zur langfristigen Vision passt.

5. Bestimme einen sinnvollen zusammenhängenden nächsten Schritt.

6. Arbeite im Tutor-Modus oder Ausführungs-Modus,
   abhängig von meiner Formulierung.

7. Vermeide unnötige Änderungen an funktionierenden Systemen.

8. Teste Änderungen soweit technisch möglich.


============================================================
WICHTIGSTER SATZ DER SPIELVISION
============================================================

"ICH BAUE EINEN SICHEREN ZUFLUCHTSORT IN EINER GEFÄHRLICHEN WELT AUF.

ICH VERLASSE IHN, UM IN DUNGEONS UND ANDEREN GEBIETEN ZU KÄMPFEN,
SELTENE RESSOURCEN ZU FINDEN, NEUE FÄHIGKEITEN ZU ERLANGEN UND
MENSCHEN FÜR MEINE GEMEINSCHAFT ZU GEWINNEN.

MIT DIESEN RESSOURCEN UND BEWOHNERN BAUE ICH MEINE BASIS WEITER AUS.

DOCH JE STÄRKER UND WERTVOLLER MEINE SIEDLUNG WIRD,
DESTO GRÖSSER WIRD DIE BEDROHUNG.

DESHALB MUSS ICH MAUERN, VERTEIDIGUNGSANLAGEN UND VERTEIDIGER AUFBAUEN
UND GEMEINSAM MIT MEINEN NPCs GEGEN IMMER GEFÄHRLICHERE ANGRIFFE KÄMPFEN."
