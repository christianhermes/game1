# ENTWICKLUNGSPLAN – Fantasy-Siedlungsspiel (Godot)
**Stand:** 2026-10-26 · **Typ:** Lebende technische Roadmap und Arbeitsanweisung für Codex
**Projekt:** `survival-game/godot/` · **Status:** Planung; kein automatischer Implementierungsauftrag

> **Für Codex:** Lies zuerst `AGENTS.md`, dann dieses Dokument, danach die relevanten **aktuellen** Godot-Dateien. Dieser Plan ist keine Aufforderung, alle Phasen nacheinander ungefragt zu implementieren. Die letzte ausdrückliche Entscheidung des Nutzers hat Vorrang. Arbeite standardmäßig als Tutor, ändere Dateien nur auf ausdrückliche Aufforderung gemäß `AGENTS.md`.

## 0. Zweck, Prioritäten und Quellen der Wahrheit

Dieses Dokument verbindet die langfristige Vision mit überprüfbaren, kleinen technischen Meilensteinen. Ziel ist ein spielbares stilisiertes 3D-Fantasy-Siedlungs- und Abenteuerspiel: isometrische, NPC-gesteuerte Ruinenstadt im Aufbau; direkte Charaktersteuerung bei Expeditionen; lokale Logistik durch Bewohner; Erkundung, Kampf und später isometrische Basisverteidigung.

**Priorität bei Widersprüchen:**
1. Neueste ausdrückliche Nutzerentscheidung im aktuellen Gespräch.
2. Aktueller, tatsächlich geprüfter Code für Aussagen darüber, was implementiert ist.
3. Verbindliche Designbeschlüsse aus dem Game-Design-Master (sofern im Arbeitskontext verfügbar).
4. `AGENTS.md` für Tutor-/Ausführungsmodus und langfristige Spielphilosophie.
5. Dieser Plan für vorgeschlagene technische Reihenfolge und Akzeptanzkriterien.
6. Ältere Prototypen, README-Dateien und Roadmaps als historische Referenz.

**Wichtige Unterscheidung:** Der Code ist Quelle der Wahrheit über die *Implementierung*, nicht über künftige Designwünsche. Die neueren expliziten Designentscheidungen sind Quelle der Wahrheit über *gewünschtes Verhalten*. Bei Konflikten nachfragen, nicht stillschweigend entscheiden.

**Statusnotation:** `[ ]` ungeprüft/offen, `[~]` teilweise, `[x]` durch Codeprüfung und möglichst Laufzeittest bestätigt. Status niemals allein aufgrund dieses Dokuments setzen. Jede Phase muss am aktuellen Repository erneut validiert werden.

**Abgrenzung:** Die alten HTML/CSS/JavaScript-Dateien werden vollständig ignoriert: nicht lesen, ändern oder testen und nicht als Referenz für neue Systeme verwenden. Die aktive Entwicklung erfolgt ausschließlich in Godot, solange der Nutzer den Browser-Prototyp nicht ausdrücklich wieder aktiviert.

## 1. Verbindliche Spielregeln für die Planung (aktualisiert 2026-10-25)

### Beschlossen: Perspektive, Spielfigur und Welt
- **Basis im Stil von Going Medieval:** isometrische/freie Übersichtskamera, Zoom/Rotation und Mausinteraktion; keine permanente Third-Person-Steuerung in der Siedlung.
- **Abenteuer im Stil der Steuerungs-/Kameraperspektive von Stardew Valley:** direkte Kontrolle des eigenen Charakters in einer Top-down-/schrägen Übersichtsperspektive; vorläufig weiterhin **stilisiertes Low-Poly-3D**, kein beschlossener Wechsel zu Pixel-Art/2D.
- **Dieselbe Figur in beiden Modi:** in der Basis der erste autonom arbeitende Bewohner/NPC mit Aufgaben und Wegfindung, bei Expeditionen direkt gesteuerter Held. Einheitliche Identität, Ausrüstung, Inventar und Stats.
- **Basis läuft während Expeditionen weiter (Variante B):** NPCs arbeiten, Transporte, Pflanzenwachstum, Verderb und passive Produktion laufen fort. Technisch darf eine vereinfachte ereignis-/zeitbasierte Hintergrundsimulation verwendet werden; keine aufwendige Offscreen-3D-Simulation nötig. Der auf Expedition befindliche Held steht für Basisaufträge nicht zur Verfügung.
- **Basisangriffe:** sehr spät, zunächst isometrische taktische Ansicht mit NPC-Verteidigung. Direktes Übernehmen des Charakters während einer Basisschlacht ist ausdrücklich **weit hinten** und kein frühes Ziel.
- **Spielstart:** in einer zerstörten ehemaligen Stadt. Ruinen sind verwertbare Ressourcenquellen, restaurierbare/abbaubare Bauobjekte und Fundorte für Hinweise; Freiräumen kann Keller/Wege/Fundstellen freilegen.
- **Atmosphäre:** gemütlicher, hoffnungsvoller Wiederaufbau mit düsterer Vergangenheit und optionaler Kriminal-/Fantasy-Ermittlung. **Konkrete Story, Täter, Stadtname, Figuren, Beweisabfolge und Enden sind NICHT beschlossen und werden nicht jetzt implementiert.**

### Beschlossen: Bewohner, Rekrutierung und Arbeit
- Der eigene Charakter ist **NPC Nr. 1**; anfangs erledigt er Arbeiten nacheinander. Zusätzliche Bewohner erlauben parallele Arbeit.
- Gemeinsames Auftragssystem für Bewohner: bewegen, Ressourcen bergen/sammeln, Holzfällen, Transportieren, Bauen, Landwirtschaft und Werkstationen bedienen; Prioritäten und nachvollziehbare Blockadegründe.
- **NPC-Tiefe B:** individuell, aber überschaubar: Fähigkeiten, Arbeitsprioritäten, Vorlieben/Eigenschaften und wenige Bedürfnisse (zunächst Nahrung/Schlaf als spätere Stufe). Keine frühe komplexe Sozial-/Stimmungssimulation.
- Rekrutierung **kombiniert** gewöhnliche anreisende Bewohner (Wohnraum/Versorgung als mögliche Voraussetzungen) und besondere ehemalige Bewohner/Personen aus Expeditionen und Quests. Spezielle NPCs können Wissen/Rezepte/Bonusfähigkeiten bringen; keine endgültigen Namen/Berufe/Quoten.
- Arbeit und Materialtransporte werden durch **NPCs** erledigt. Keine magische Materialteleportation. Arbeits- und Transportaufträge müssen dieselben realen Bestände verwenden.
- **Esel gestrichen aus dem Kernspiel und der frühen/mittleren Roadmap.** Eventuell später als Nutztier/Transporttier wie Kühe, Hühner usw.; kein anfänglicher Transportesel, keine eselspezifischen Prioritäten oder Ladepunkte.
- Aktive Werkstationen erfordern **Arbeit eines zugewiesenen Bewohners**, nicht zwingend direkte Eingabe des Spielers. Passive Stationen verarbeiten nach Belieferung/Start selbstständig.

### Beschlossen: Funktionsräume, Arbeit und lokale Versorgung (2026-10-25)
- **Raumregel C:** Jeder erkannte, geschlossene Raum kann **eine Hauptfunktion** erhalten (z. B. Zimmermannswerkstatt, Schmiede, Küche, Vorratskammer). Andere Tätigkeiten und Werkstationen im selben Raum bleiben erlaubt; keine exklusive Funktionssperre.
- **Voraussetzungen:** Eine Hauptfunktion wird erst betriebsbereit, wenn die erforderlichen konkreten Objekte/Stationen vorhanden und nutzbar sind (z. B. Werkbank für Zimmermann, Esse und Amboss für Schmiede). Exakte Objektlisten und Boni werden je Raumtyp später definiert.
- **Spezialisierung:** Hauptfunktion kann klar kommunizierte, moderate Vorteile bieten; nicht spezialisierte Räume/Mehrzweckwerkstätten bleiben grundsätzlich nutzbar. Keine Pflicht, jedem Raum einen Typ zuzuweisen.
- **Raum-Arbeitszuweisung:** Ein oder mehrere Bewohner können einem Raum bzw. dessen Arbeitsplätzen zugeordnet werden. Produktionsaufträge werden an geeigneten Stationen durch zugewiesene Bewohner abgearbeitet; die Anzahl gleichzeitiger Tätigkeiten hängt von realen Arbeitsplätzen ab, nicht nur vom Raumlabel.
- **Lokale Lager:** Kisten, Regale, Stapel etc. sind echte physische Behälter mit eigenen Beständen/Kapazitäten; ein Raum erhält **kein unsichtbares magisches Inventar**. Geeignete lokale Lager können dem Raum/Stationen zugeordnet werden. Bestandsziel und Filter je Lager oder Raum sind als späterer Konfigurationskomfort vorgesehen.
- **Materialversorgung:** Verfügbare Transport-NPCs bringen Materialien aus physisch erreichbaren Lagern. Fehlt ein Transporteur, dürfen zugewiesene Arbeiter erforderliche Materialien **selbst holen**. Fehlen Materialien/Platz/Wege, wird die Arbeit nachvollziehbar pausiert. Entnahme, Reservierung und Transport verhindern Doppelverwendung, Verlust und endloses Pendeln.
- **Produktionswarteschlangen:** Jedes Rezept besitzt höchstens einen sichtbaren Auftrag mit einer Wiederholungsmenge. Die Liste ist manuell nach Priorität sortierbar; der oberste ausführbare Auftrag wird unabhängig von seiner Wiederholungsmenge zuerst berücksichtigt. Jeder Auftrag kann gezielt abgebrochen werden.
- **Transporttiere:** Esel können **später optional** dieselbe allgemeine Logistik unterstützen; weder Starttier noch Voraussetzung für Funktionsräume oder frühe Transportlogik.
- **Später optional:** Raumübergreifende Produktionsketten, Auftragsreihenfolgen, Zielbestände wie „20 Brote halten“, automatische Zwischenproduktplanung. **Nicht** Teil der ersten Raumversion.
- **Umbauten:** Raumgrenzen, fehlende Pflichtobjekte, Raumteilungen/-zusammenlegungen und unzugängliche Arbeitsplätze müssen Status/Zuordnung aktualisieren; Materialien bleiben in ihren realen Behältern.

### Beschlossen: Mauerbau B – modulare massive Steinbefestigungen (2026-10-27)
- **Drei Bauarten:** gewöhnliche Haus-/Werkstattwände auf Rasterkanten für Räume; frühe, per Ziehen planbare Holzpalisaden aus eingerammten Stämmen; später massive Stadt-/Wehrmauern aus großen Steinblöcken auf echten Rasterflächen.
- **Steinmauer Variante B:** Steinblöcke sind größere modulare Mauerabschnitte, **keine einzeln gesetzten Minecraft-Steine**. Abschnitte können in der Höhe gestapelt und per Ziehen als Linie geplant werden. Benachbarte Segmente sollen optisch sauber anschließen.
- **Begehbarkeit:** Die Oberseite ausreichend breiter Steinblöcke soll grundsätzlich begehbar sein, **sofern ein gültiger Zugang** (z. B. Treppe) besteht und die Navigation funktioniert. Zusätzliche Wehrgang-/Plattformbauteile erweitern schmale oder besondere Abschnitte; Brüstungen und Zinnen sind optional separat platzierbare Schutzaufbauten.
- **Ausbau:** zunächst Steinmauer ohne Wehrgang nutzbar; später Treppen, Wehrgänge, Zinnen, Türme und Torhäuser. Palisaden können repariert, verstärkt, abgebaut und Materialien teilweise wiederverwendet werden; keine automatische Aufwertung/Materialteleportation.
- **Einheitliches Bausystem:** Einzelbauteile und komplette, nachträglich veränderbare Gebäudevorlagen nutzen dieselben BuildRecipe-/BuildGrid-/ConstructionSite-Regeln. Linienziehen erzeugt einzelne reguläre Baustellen, keine unteilbare Sondermauer.
- **Technische Reihenfolge:** zuerst Raster-/Höhenbelegung und Bauvalidierung absichern, dann Palisaden-Linienwerkzeug, massive Steinblock-Segmente und Anschlüsse; anschließend Stapelung, Treppen, dynamische Navigation und begehbare Mauern; Deckung/Kampf und komplexe Befestigungen später. Kleine, separat testbare Meilensteine; keine vorzeitige Vollimplementierung.
- **Offen:** genaue Blockabmessungen, Kosten, Haltbarkeit, Bauboni, Wiederverwendungsquote und Detailregeln für Statik/Deckung.

### Weiterhin gültige Kernregeln
- Stilisiertes Low-Poly-3D; kleine, testbare Entwicklungsschritte; wenig Grind.
- Spielerinventar: begrenzte Slots und Stapel, Rucksack-Upgrades, **kein Gewichtssystem**.
- Physische, voneinander unabhängige Kisten; Siedlungsübersicht ist nur lesend. Kein globaler, ortsunabhängiger Materialzugriff.
- Werkstationen: Zugriff auf Kisten im selben geschlossenen Raum bzw. in einem kleinen lokalen Außenradius; weitere Wege erfordern physischen NPC-Transport.
- Materialreservierungen verhindern Doppelverwendung, Transporte verlieren/duplizieren nichts.
- Lebensmittel-Frische: frisch, normal, alt, verdorben; Lagerbehälter/Raumtyp beeinflussen Haltbarkeit.
- Forschung über Entdeckungen und Meilensteine; Zweige Bau, Handwerk, Landwirtschaft, Versorgung, Arkane Künste als langfristige Designrichtung.
- Ruhige Bauphasen ohne ständige Überfälle; Kampf/Expedition bleiben wichtig, ohne den Siedlungsaufbau zu dominieren.

## 2. Repository-Stand: überprüfte Ausgangsbasis (statisch, 2026-10-24)

Die folgenden Beobachtungen stammen aus gelesenen Dateien und sind **keine bestätigten Laufzeittests**:

| System | Nachweis | Beobachteter Zustand |
|---|---|---|
| Hauptszene/Kamera | `godot/main.tscn`, `scripts/main.gd` | Orthografische Kamera folgt Spieler, Startitems werden ausgegeben |
| Spieler/Interaktion | `scripts/player.gd` | WASD, Interaktionsradius, Item-Auswahl, Essen, Respawn |
| Stats | `scripts/player_stats.gd` | Gesundheit, Mana, Hunger, Regeneration, Hunger-/Todesschaden |
| Inventar | `scripts/inventory/inventory.gd` | Dictionary aus Item-ID und Menge; keine Slots/Stackgrenzen |
| Hotbar | `scripts/ui/hotbar.gd` | Neun Slots, Mengenanzeige, Auswahl; kein vollständiges Inventar-UI |
| Auswahl-Info | `scripts/ui/world_info_panel.gd` und Objektskripte | Zentrales, live aktualisiertes Fenster für Bewohner, Ressourcen, Felder, Werkstationen, Baustellen und fertige Gebäude; keine schwebenden Weltlabels |
| Landwirtschaft | `scripts/farming/farm_plot.gd` | Ein Feld: leer, wächst, erntereif; Timer und Ernte |
| Rezepte | `scripts/workstation/processing_recipe.gd`, `scripts/inventory/item_amount.gd` | Datenressourcen für eine Zutat und mehrere Ausgaben |
| Werkstationen | `scripts/workstation/processing_station.gd` und Szenen | Sofortverarbeitung direkt mit Spielerinventar |
| Bau | `scripts/building/build_manager.gd`, `scripts/building/build_grid.gd` | Zentrales 3D-Blockraster steuert Wandkanten und getrennte Schichten für Fundamente, Böden und Objekte; drehbare mehrzellige Grundflächen sind vorbereitet |
| Baustelle | `scripts/building/construction_site.gd` | Autonomer BUILD-Auftrag liefert Material und arbeitet zeitgesteuert; Fertigstellung überträgt die Rasterbelegung, Abbruch gibt gelieferte Materialien als Pickups zurück |
| Bau-Rezept | `scripts/building/build_recipe.gd`, `data/buildings/wood_wall.tres` | Holzmauer mit Holzbedarf und Hammer |
| Speichern, Kisten, Esel, Raumdetektion, Verderb | in geprüften Skripten nicht vorhanden | Für diese Systeme noch keine Implementierung nachgewiesen |
| Browser-Altbestand | `game.js`, `enemies.js`, `home.js` usw. | Älterer 2D-Kampf-/Wellen-/Heimatprototyp |

**Wichtige technische Risiken aus der Codeprüfung:**
1. `Inventory.add_item()` akzeptiert Mengen ohne Kapazitäts- und Positivprüfung; `receive_item()` meldet keinen Einlagerungserfolg. Vor begrenzten Inventaren/Pickups klären.
2. Baustellen lassen sich im Baumodus per Rechtsklick abbrechen und geben gelieferte Materialien zurück; Abreißen oder Reparieren fertiger Gebäude ist bewusst noch nicht implementiert.
3. `BuildGrid` unterstützt die logischen Schichten für Fundament, Boden und Objekt, sichtbar getestet ist bisher jedoch nur das Wandrezept. Vor neuen Bauarten sind passende Szenen und Vorschaugeometrien erforderlich.
4. `ProcessingStation` überträgt Produkte sofort ins Spielerinventar; für passive Stationen, Queues und Logistik braucht es später explizite Eingabe-/Ausgabepuffer.
5. `Hotbar` und `Inventory` sind noch kein gemeinsames Slot-/Stack-Modell.
6. `FarmPlot` verwendet einen laufenden `Timer`; Persistenz und Szenenwechsel erfordern später ein Zeitmodell.
7. `godot/README.md` beschreibt noch einen älteren Minimalstand und muss bei Meilensteinen aktualisiert werden.
8. `godot/project.godot` nennt Feature-Version `4.7`; lokal installierte Godot-Version vor Laufzeitdiagnosen prüfen.
9. Es existieren mehrere Baustellen-Szenenpfade; vor Bereinigung Referenzen prüfen, keine Dateien vorschnell löschen.

**Vor jedem Schritt neu prüfen:** Git-Stand, Szenenreferenzen, Script-Klassen, aktuelle Implementierung, offene Änderungen und tatsächlich ausgeführte Tests. Nicht auf diese Momentaufnahme verlassen.

## 3. Arbeitsprotokoll für Codex (verpflichtend)

### 3.1 Start jeder neuen Aufgabe
1. Nutzerziel in einem Satz wiedergeben.
2. Relevante Dateien und Szenen lesen; nicht allein auf Dateinamen oder Dokumentation vertrauen.
3. Feststellen: bereits vorhanden / teilweise / fehlt / unklar.
4. Relevante Abhängigkeiten, Regressionen und offene Designfragen nennen.
5. **Eine** zusammenhängende, sichtbare und testbare Ausbaustufe vorschlagen.
6. Bei Tutor-Modus: konkrete Aufgabe + Hinweise + Abnahmekriterien; nicht ungefragt editieren.
7. Bei ausdrücklich angefordertem Ausführungsmodus: gezielt implementieren, testen, Änderungen erklären.
8. Bei `fertig`/`done`/`ok`: zuerst die aktuelle Umsetzung prüfen, **danach** neue Aufgabe stellen.

### 3.2 Definition of Done (für jeden Meilenstein)
- Funktion aus Spielersicht nutzbar, nicht nur Klasse oder Variable vorhanden.
- Vorhandene Mechaniken bleiben funktionstüchtig.
- Fehler- und Grenzfälle sind definiert (leer, voll, ungültige ID, fehlendes Material, Unterbrechung).
- Szenen/Signale/Exports/Resources passen zusammen.
- Test in Godot dokumentiert, falls ausführbar; sonst ausdrücklich `NICHT LAUFZEITGETESTET`.
- Keine unbeabsichtigten Änderungen am Browser-Prototyp.
- Nur relevante Dateien verändert; Änderungen kurz nachvollziehbar erklärt.
- Dokumentation und Status erst nach Prüfung aktualisiert.
- Ein klarer nächster Schritt genannt, aber nicht automatisch begonnen.

### 3.3 Testbericht
Jede Implementierung endet mit:
`GEÄNDERT:` Dateien und Verhalten;
`GETESTET:` konkret ausgeführte statische/automatische/Editor-Tests;
`MANUELL TESTEN:` konkrete Schritte in Godot;
`OFFEN:` Risiken, Grenzen, Folgeentscheidungen.
Keine Tests erfinden.

### 3.4 Architekturregeln
- Godot-typisch: Szenen/Nodes für Weltobjekte, Resources für Stammdaten, Signale für Zustandsänderungen.
- Ein Zustand hat eine klare verantwortliche Datenquelle; UI zeigt ihn nur an.
- Keine große globale Allzweck-Klasse, kein vorschnelles generisches Framework.
- Zuerst einfacher vertikaler Gameplay-Schnitt, danach Generalisierung bei nachgewiesenem Bedarf.
- Gegenstandsbewegungen möglichst über überprüfbare Transaktionen: Entnahme nur bei ausreichender Menge, Einlagerung nur bei Platz, kein stiller Verlust oder Duplikation.
- Bei späterer Zeit-/Speicherarchitektur eindeutige IDs für persistente Weltobjekte vorsehen.
- Neue Systeme nicht unbemerkt an alte Browser-Globals koppeln.

## 4. Aktualisierte Roadmap auf einen Blick (Vorschlag zur Reihenfolge)

| Phase | Ergebnis | Priorität |
|---|---|---|
| P0 | Bestehenden Godot-Code testen, Kamera-/Input-Abhängigkeiten prüfen | Sofort |
| P1 | Isometrische Basiskamera, Mausauswahl, Befehls-UI | **Nächster empfohlener Meilenstein** |
| P2 | Eigener Charakter als erster NPC: Gehen, Auftrag annehmen, ausführen, abbrechen | Sehr hoch |
| P3 | Ruinen-V1: ein abtragbarer Schutthaufen mit Ressourcen, ein restaurierbarer Bauplatz | Hoch |
| P4 | Bauplan/Raster/Materiallieferung und Bauarbeit durch NPC; Materialvalidierung korrigieren | Hoch |
| P5 | Slots/Stacks, physische Kisten, verlustfreie Transaktionen | Hoch |
| P6 | NPC-Transport zwischen Fundstelle, Kiste, Baustelle und Werkstation; Reservierungen | Hoch |
| P7 | Zeitmodell, Save/Load und Hintergrundfortschritt bei Szenenwechsel | Hoch |
| P8 | Werkstationen: Bewohnerarbeit vs. passive Zeitproduktion, lokale Materialquellen | Hoch |
| P9 | Zusätzlicher NPC, Prioritäten, einfache Fähigkeiten; Rekrutierung als separater kleiner Schnitt | Mittel |
| P10 | Expedition mit direkter Steuerung; Basis läuft im Hintergrund weiter | Mittel |
| P11 | Raumdetektion und Funktionsräume (Hauptfunktion C, Pflichtobjekte, NPC-Arbeitsplätze, lokale Lager), danach Nahrung, Landwirtschaft, Forschung und besondere Rekrutierung | Später; frühere kleine Raum-V1 möglich, sobald Bauen/NPCs/Lager stehen |
| P12 | Isometrische NPC-Basisverteidigung | Sehr spät |
| P13 | Tiere, komplexere NPC-Beziehungen, direkte Übernahme bei Basisschlachten | Zukunft |

**Wichtig:** Die nachfolgenden historischen Detailkapitel P1–P13 wurden für den alten Third-Person-/Esel-Plan geschrieben. Sie sind **nicht mehr die verbindliche Implementierungsreihenfolge**. Nur allgemeingültige technische Abnahmeregeln (z. B. Materialintegrität, Raster, Inventar) weiterverwenden. Eselspezifische und spieler-manuelle Arbeitsanweisungen sind überholt. Die neuen Phasen oben haben Vorrang. Vor Implementierung jeweils nur den aktuellen Meilenstein im Detail spezifizieren und Code erneut prüfen.

---

## 5. HISTORISCHE DETAILKAPITEL (vor dem Perspektiv-/NPC-Pivot) – P0

**Ziel:** Das aktuelle Godot-Projekt startet reproduzierbar, und wir kennen den Ist-Zustand.

### Aufgaben
- [ ] Tatsächliche lokale Godot-Version und Projektimport prüfen.
- [ ] `main.tscn` starten; Parser-/Ressourcen-/Signalfehler erfassen.
- [ ] Bewegung, Kamera, F-Interaktion, E-Essen, Hotbar, Statusleisten prüfen.
- [ ] Weizen pflanzen, wachsen lassen, ernten; Dreschen → Mahlen → Brot backen → Essen prüfen.
- [ ] Holz-Pickup, Baustelle, Hammer, fünf Arbeitsschritte, fertige Holzmauer prüfen.
- [ ] Vorhandene Warnungen/Fehler nach Schwere priorisieren, nicht pauschal refactoren.
- [ ] README-Steuerung und vorhandene Gameplay-Funktionen korrekt dokumentieren.
- [ ] Testprotokoll anlegen (manuell oder automatisiert); bei fehlendem Godot keine Laufzeittests behaupten.

**Abnahme:** Bestehende vertikale Kette ist nachvollziehbar testbar; Fehlerliste liegt vor. **Nicht** schon hier Kisten, NPCs oder Esel einbauen.

## 6. P1 – Modulares Bauen V1: freie Holzmauer

**Spielerziel:** B drücken, eine gültige Stelle wählen, eine Holzmauer als Baustelle setzen, Holz liefern und mit Hammer fertigbauen.

### P1.1 Bauzustand und Vorschau
- [ ] Bestehenden `BuildManager` lesen und minimal erweitern.
- [ ] B aktiviert/deaktiviert Bauansicht; Abbruch funktioniert zuverlässig.
- [ ] Position unter Cursor mit Kamera-Ray und Bodenkollision bestimmen.
- [ ] Position auf konfigurierbares Raster runden; keine hartcodierten Weltkoordinaten.
- [ ] Bauvorschau folgt Rasterposition; gültig/ungültig visuell unterscheidbar.
- [ ] Drehung um definierte Schritte (z. B. 90°) als explizite Steuerung.
- [ ] Platzierung darf nicht auf bereits belegten Zellen erfolgen; Gelände-/Abstandsprüfung für V1 einfach halten.
- [ ] Maus-/UI-Eingaben sollen nicht versehentlich Bauten platzieren.
- [ ] Korrekte Behandlung fehlender `selected_recipe`, `construction_site_scene` oder Kamera.

### P1.2 Baustelle erzeugen
- [ ] Bestätigung erzeugt die vorhandene `construction_site.tscn` an Zieltransform.
- [ ] `BuildRecipe` wird korrekt übergeben.
- [ ] Mehrere Baustellen dürfen parallel bestehen.
- [ ] Nicht versehentlich doppelt platzieren bei einem Tastendruck.
- [ ] Der Spieler kann weiterlaufen/interagieren, sobald Bauansicht beendet ist.

### P1.3 Material- und Arbeitslogik korrigieren
- [ ] Vor Arbeitsbeginn **alle** `required_materials` prüfen, nicht nur ersten Eintrag.
- [ ] Anzeige für jedes benötigte Material und dessen gelieferten Bestand.
- [ ] Materialabgabe entnimmt nur bei Erfolg und niemals mehr als benötigt.
- [ ] Fehlendes Werkzeug/Material führt nicht zu Baufortschritt.
- [ ] Arbeitsfortschritt zählt nur bei gültigem Werkzeug.
- [ ] Nach Abschluss: genau ein fertiges Bauteil, korrekte Position/Drehung, Baustelle verschwindet.
- [ ] Leere/ungültige Rezepte robust behandeln.
- [ ] Materialien sind an Baustelle physisch geliefert; keine automatische Entnahme aus entfernten Kisten.

### P1.4 Abnahmeszenario
1. Holz aufsammeln; Hammer in Hotbar auswählen.
2. Baumodus aktivieren; Vorschau auf Raster bewegen und drehen.
3. An gültiger Stelle Baustelle platzieren; belegte Stelle wird abgelehnt.
4. Drei Holzstücke nacheinander liefern; Fortschritt korrekt anzeigen.
5. Ohne Hammer keine Bauarbeit; mit Hammer fünf Arbeitsschritte.
6. Fertige Mauer erscheint exakt am Ort der Baustelle.
7. Zweite Mauer bauen, ohne erste zu verändern.
8. Ein Testrezept mit **zwei** Materialarten darf nicht vorzeitig fertig werden.

**Nicht Teil von P1:** Dächer, Stockwerke, Raumdetektion, Esel, Gebäudeschäden, große Bau-UI.

## 7. P2 – Inventar V1 und physische Kiste

**Spielerziel:** Items besitzen reale Slots und Stapel; eine platzierte Kiste speichert eigene Bestände, und Transfers sind verlustfrei.

### P2.1 Inventarmodell
- [ ] Vorhandene `Inventory`-API und alle Aufrufstellen inventarisieren.
- [ ] Item-Stammdaten-Konzept nur soweit nötig: ID, Name, Kategorie, maximale Stapelgröße.
- [ ] Slots statt nur globalem Mengen-Dictionary, mit klarer Trennung zwischen Slotindex, Item-ID und Menge.
- [ ] Anfangskapazität als konfigurierbarer Wert; **20 Slots nur Vorschlag**, nicht ungefragt als endgültigen Beschluss festlegen.
- [ ] Add/Remove/Transfer liefern nachvollziehbaren Erfolg und ggf. Restmenge.
- [ ] Stapel zuerst auffüllen, dann freie Slots verwenden; keine negativen oder Nullmengen.
- [ ] Vollständiges Inventar: Pickup bleibt in der Welt bzw. nicht aufgenommene Restmenge bleibt erhalten.
- [ ] Bestehende Hotbar, Essen, Farming und Baustellen nach API-Änderungen prüfen.
- [ ] Hotbar ist Schnellzugriff, nicht das komplette Inventar; Auswahl nach Umordnung konsistent halten.

### P2.2 Kiste V1
- [ ] Wiederverwendbare `StorageContainer`-Szene mit eigenem Inventar.
- [ ] Konfigurierbare Slot-/Stackkapazität.
- [ ] Öffnen, anzeigen, Items hineinlegen und herausnehmen.
- [ ] Transfers atomar bzw. mit garantiertem Rollback/Restmengen-Verhalten.
- [ ] Zwei Kisten nebeneinander besitzen wirklich unabhängige Bestände.
- [ ] Kiste zeigt voll/leer/Teilbelegung korrekt an.
- [ ] Optional erste Filterstruktur vorbereiten, aber noch keine komplexe Sortier-Automatik.

### P2.3 Abnahme
- [ ] Zwei Kisten, je eigene Inhalte; Spieler verschiebt Holz von A nach B.
- [ ] Volle Kiste nimmt nichts zusätzlich an, ohne Itemverlust.
- [ ] Inventar voll → Pickup bleibt.
- [ ] Vorhandene Spielmechaniken funktionieren weiterhin.

**Wichtig:** Kein globales Siedlungsinventar als Zugriffspool. Kein Gewichtssystem.

## 8. P3 – Bauen V2: echte Räume vorbereiten

**Spielerziel:** Eine kleine Hütte aus mehreren Bauteilen selbst zusammenstellen.

### Arbeitspakete (jeweils separat testbar)
- [ ] Bauteilkatalog: Wand, Boden/Fundament, Tür, Dach/Decke als eigene Rezepte und Szenen.
- [ ] Rasterkoordinaten, Drehung, Belegungsregeln und eindeutige Zellzuordnung.
- [ ] Einheitliche Bauteilabmessungen und Anschlusspunkte.
- [ ] Mehrere Stockwerke als **spätere Teilstufe**, nicht zwingend schon V2.
- [ ] Vorschau für Wand-/Boden-/Dachtypen; stabile Platzierungsregeln.
- [ ] Einfache Abbruch-/Rückbauentscheidung (Ressourcenrückgabe zunächst ausdrücklich klären).
- [ ] Baustellen-Materiallieferung und Fertigstellung auch bei verschiedenen Bauteilen.
- [ ] Persistente eindeutige Objektidentität für spätere Saves vorsehen.

**Abnahme:** Kleine Hütte mit Tür und Dach manuell errichtbar; Baustellen und fertige Bauteile blockieren sich nicht inkonsistent. **Raumerkennung erst P8**, aber Datenstruktur soll sie später ermöglichen.

**Später:** Treppen, Stockwerk-Schnittansicht, Türme, Geländeebnung, Grundstückskauf und umfangreiche Verteidigungsbauten.

## 9. P4 – Lokale Lager und Werkstationen

**Spielerziel:** Eine Werkstation verarbeitet Ressourcen aus nahe gelegenen Kisten, nicht aus magisch erreichbaren Fernlagern.

### P4.1 Lagerregeln
- [ ] Kisteneinstellungen: Name, erlaubte Items/Kategorien, automatische Einlagerung, Priorität.
- [ ] Konfigurationskopie zwischen Kisten als späterer Komfortschritt.
- [ ] Noch keine Raumerkennung: zunächst klar definierter **lokaler Radius** als Übergangslösung.
- [ ] Trennung: Spielerinventar, Kisteninventar, Stations-Eingabe, Stations-Ausgabe.
- [ ] Explizite Materialentnahme nur aus zulässigen Quellen.
- [ ] Keine doppelte Entnahme bei gleichzeitigem Zugriff.
- [ ] Lager-UI zeigt verfügbare, reservierte und belegte Mengen (Reservierung zunächst nur soweit bereits benötigt).

### P4.2 Verarbeitung V2
- [ ] `ProcessingRecipe` auf mehrere Zutaten erweitern, sobald ein Rezept es braucht.
- [ ] Stations-Eingabe-/Ausgabepuffer und Zustände (bereit, blockiert, verarbeitet, Ausgabe voll).
- [ ] Aktive Station: Spieler führt Arbeit aus; automatische Lieferung ersetzt keine Spieleraktion.
- [ ] Passive Station: nach Start/Beladung zeitgesteuerte Verarbeitung.
- [ ] Ergebnis landet am Ort der Station, nicht automatisch im Spielerinventar.
- [ ] Warteschlange zunächst nur für **eine** Station und kleine Stückzahl, dann verallgemeinern.
- [ ] Bei zu wenig Input warten statt negative Bestände zu erzeugen.
- [ ] Bei vollem Output pausieren statt Produkte zu löschen.
- [ ] Bestehende Rezepte Dreschen → Mahlen → Brot mit neuer Logik testen.

### P4.3 Abnahme
- [ ] Holz/Weizen in lokaler Kiste kann verwendet werden.
- [ ] Dieselbe Ressource in weit entfernter Kiste ist **nicht** sofort verfügbar.
- [ ] Volle Ausgabe stoppt Produktion ohne Verlust.
- [ ] Aktive Station produziert nicht selbsttätig.

## 10. P5 – Esel V1: sichtbarer Einzeltransport

**Spielerziel:** Der Esel bringt einen Holzstapel sichtbar von Kiste A nach Kiste B.

### Minimaler vertikaler Schnitt
- [ ] Ein Esel in der Heimatbasis, ohne Hunger-/Schlafsimulation.
- [ ] Einfaches Ziel-/Quellobjekt und klarer Auftrag mit Item-ID und Menge.
- [ ] Begrenzte Tragkapazität; Überschuss bleibt an Quelle für weitere Fahrt.
- [ ] Physische Bewegung entlang eines erreichbaren Wegs; keine Sofort-Teleportation.
- [ ] Aufladen erst bei Quelle, Abladen erst bei Ziel.
- [ ] Transportzustände: wartet, läuft zur Quelle, lädt, läuft zum Ziel, entlädt, abgeschlossen/blockiert.
- [ ] Wenn Ziel voll oder Quelle leer: Auftrag sicher abbrechen/pausieren; nichts duplizieren/verlieren.
- [ ] Unterbrechung bei blockiertem Weg behandeln; keine Endlosschleife.
- [ ] Transportgut während der Fahrt dem Esel zuordnen, nicht gleichzeitig Quelle und Ziel.
- [ ] Kiste B erhält exakt die Menge, die A verliert, unter Berücksichtigung der Ladung des Esels.

### Abnahme
- [ ] Holz von A nach B, Esel ist sichtbar unterwegs.
- [ ] Zweite Fahrt bei zu großer Menge.
- [ ] Volles Ziel und entfernte Quelle werden korrekt behandelt.
- [ ] Kein Materialteleport, keine Duplikation, kein Verlust.

**Nicht Teil von P5:** Automatische Optimierung, Dutzende Jobs, komplexe NPC-KI, Karren, magische Helfer.

## 11. P6 – Esel V2: automatische Aufträge und Reservierungen

**Spielerziel:** Der Esel organisiert sinnvoll Nachschub, ohne das physische Lagerkonzept auszuhebeln.

### P6.1 Auftragsmodell
- [ ] Zentraler Auftragsplaner für **Transportaufträge**, nicht für globales Inventar.
- [ ] Jobfelder: Typ, Quelle, Ziel, Item, benötigte Menge, reservierte Menge, Priorität, Status.
- [ ] Jobtypen: Baustellenmaterial, Produktionsnachschub, Mindestbestand, Stationsausgabe, freigegebene Pickups, sinnvolles Einsortieren.
- [ ] Aufträge zusammenfassen, wenn Quelle/Ziel und Weg kompatibel.
- [ ] Jobs pausieren, wenn Materialien fehlen, statt ständig neu zu erzeugen.
- [ ] Nutzer darf Prioritäten einstellen; Default nur Vorschlag: blockierte Produktion, Baustellen, volle Ausgaben, Einsammeln, Mindestbestände.
- [ ] Laufende Fahrt möglichst beenden, bevor Priorität gewechselt wird.

### P6.2 Ressourcenreservierung
- [ ] Verfügbare Menge = tatsächlicher Bestand minus bereits zugesagte Menge.
- [ ] Reservierung und Freigabe bei Jobstart, Teiltransport, Abbruch und Zielausfall.
- [ ] Niemals dieselben zehn Bretter gleichzeitig zwei Baustellen versprechen.
- [ ] Reservierungen sind keine physischen Transfers; Bestände bleiben in Quellkiste bis Abholung.
- [ ] Beim Aufladen Quellbestand tatsächlich reduzieren; während Fahrt Fracht beim Esel führen; bei Abladen Zielbestand erhöhen.
- [ ] Bei Fehler Fracht erhalten oder kontrolliert an gültigem Ort ablegen.

### P6.3 Mindestbestand + Produktionsbedarf (beides verbindlich)
- [ ] Kiste hat optionalen Mindestbestand pro Item.
- [ ] Fehlbestand erzeugt Transportbedarf, sofern anderswo Bestand verfügbar.
- [ ] Produktionsqueue erzeugt zusätzlichen **konkreten** Inputbedarf.
- [ ] Bereits am Ziel vorhandene, reservierte oder unterwegs befindliche Mengen gegen Bedarf rechnen.
- [ ] Wenn Produktionsqueue 40 Bretter braucht und lokal 15 verfügbar sind: bis zu 25 nachliefern, nicht blind 40.
- [ ] Keine Doppelaufträge durch gleichzeitigen Mindestbestand und Queue.
- [ ] Möglichst direkt zur Werkstatt liefern, nicht unnötig über Zwischenlager.
- [ ] Kistenfilter, Kapazität und Spielerprioritäten respektieren.
- [ ] Keine sinnlosen Kreisfahrten zwischen gleichwertigen Lagern.

### P6.4 Baustellen und Pickups
- [ ] Baustelle bietet explizite Lieferbedarfe an; Esel liefert Material, **baut nicht selbst**.
- [ ] Spieler kann jederzeit selbst Material bringen; Jobbedarf passt sich an.
- [ ] Nur freigegebene, erreichbare Pickups im Siedlungsgebiet einsammeln.
- [ ] Keine automatische Ernte, kein Holzfällen, kein Mining.
- [ ] Fertige Stationsprodukte abholen, wenn geeignetes Ziel existiert.

### P6.5 Abnahme
- [ ] Zwei Baustellen konkurrieren um knappe Bretter: keine Doppelzusage.
- [ ] Mindestbestand 30, Istbestand 10: sinnvoll 20 nachliefern.
- [ ] Queue 40, lokal 15: maximal 25 fehlende nachliefern.
- [ ] Ein und derselbe Bedarf erzeugt nicht endlos neue Jobs.
- [ ] Spieler liefert während Esel unterwegs ist: Mengen und Reservierungen bleiben korrekt.
- [ ] Ziel voll/Quelle leer/Transport unterbrochen: kein Itemverlust.
- [ ] Globalübersicht zeigt Bestände und Standorte nur an; kein Fernzugriff.

## 12. P7 – Speichern, Laden und Spielzeit

**Zeitpunkt:** Spätestens bevor zahlreiche Gebäude, Kisten, Frischewerte und Eselaufträge existieren. Bei Bedarf früher umsetzen.

### P7.1 Einheitliche Spielzeit
- [ ] Zentrale Zeitquelle für Wachstum, passive Produktion, Haltbarkeit und Transportfortschritt.
- [ ] Konkrete Dauer eines Spieltags als **offene Designentscheidung** behandeln.
- [ ] Pause-/Zeitskalierungsregeln festlegen.
- [ ] Nicht auf viele unabhängige Timer als alleinige persistente Datenquelle verlassen.
- [ ] Zeitdifferenzen bei Szenenwechseln für simulierte Hintergrundprozesse berechnen.
- [ ] Keine unbegrenzte Echtzeit-Offline-Simulation ohne ausdrückliche Entscheidung.

### P7.2 Savegame V1
- [ ] Versioniertes Speicherformat mit Migrations-/Fehlerstrategie.
- [ ] Spielerposition, Stats, Inventar, ausgewählte Hotbar-Items.
- [ ] Felder: Pflanze, Zustand, Wachstumsfortschritt.
- [ ] Gebaute Elemente und offene Baustellen inklusive Material-/Arbeitsfortschritt.
- [ ] Kisten: Position, Einstellungen, physischer Inhalt.
- [ ] Stationsqueues, Eingaben, Ausgaben und Produktionsfortschritt.
- [ ] Esel: Position, Fracht, aktueller Auftrag, Reservierungen.
- [ ] Spielzeit und spätere Frischewerte.
- [ ] Beim Laden keine doppelt gespawnten Weltobjekte.
- [ ] Sicheres Schreiben (z. B. temporäre Datei + Ersatz), Fehler bei beschädigtem Save abfangen.

### P7.3 Abnahme
- [ ] Während Wachstum, Baustelle und Eseltransport speichern; laden; genau derselbe Zustand.
- [ ] Mehrfaches Laden dupliziert keine Items oder Bauten.
- [ ] Beschädigte Datei beendet Spiel nicht unkontrolliert.

## 13. P8 – Räume, Lagerbonus und Frische

### P8.1 Raumdetektion
- [ ] Zuerst **eine** kleine geschlossene Hütte erkennen; Türen/Fenster gelten als Begrenzungen.
- [ ] Eindeutig bestimmen, ob Kiste und Werkstation zum selben Raum gehören.
- [ ] Öffnung im Dach/Wand: Raum verliert ggf. Status; Regeln explizit festlegen.
- [ ] Kisten draußen erhalten nur Radiuszugriff; keine Fernentnahme.
- [ ] Raumtyp: gewöhnlicher Innenraum, Vorratsraum/Keller, später magischer Raum.
- [ ] Kellerbau und Raumklassifizierung als offene Designpunkte gesondert klären.
- [ ] Keine detaillierte Temperatur-, Luftfeuchtigkeits- oder Wärmesimulation.

### P8.2 Lebensmittelstapel
- [ ] Für verderbliche Items Frische pro Stapel/Charge, nicht bloß pro Item-ID.
- [ ] Frische intern 0–100, Anzeige: frisch → normal → alt → verdorben.
- [ ] Grenzwerte und Basis-Haltbarkeit je Item als konfigurierbare Daten.
- [ ] Stapelzusammenführung nur nach klarer Regel; keine künstliche Frischeverbesserung.
- [ ] Teilentnahme bevorzugt älteste noch essbare Charge (FIFO nach Verderb).
- [ ] Verdorbenes Essen nicht verzehrbar, später für Kompost nutzbar.
- [ ] Alte Lebensmittel können reduzierten Nutzen haben (Balancing später).

### P8.3 Behälter- und Raum-Boni
- [ ] Normale Kiste, Vorratskiste, spätere magische Kiste mit Haltbarkeitsmultiplikator.
- [ ] Gewöhnlicher Innenraum, Keller, magischer Raum mit Multiplikator.
- [ ] Kombinierte Wirkung mit definierter Obergrenze; Zahlen sind vorläufiges Balancing.
- [ ] Umräumen ändert nur künftige Verderbsrate, niemals bereits verlorene Frische.
- [ ] UI zeigt Frische, geschätzte Resthaltbarkeit und aktive Boni.
- [ ] Esel bevorzugt geeignete Lebensmittelbehälter unter Beachtung ausdrücklicher Filter/Spielerregeln.

### P8.4 Abnahme
- [ ] Zwei identische Brotchargen altern in gewöhnlicher Kiste und Keller unterschiedlich.
- [ ] Kiste aus Keller tragen: bestehende Frische bleibt, zukünftiger Verderb beschleunigt.
- [ ] Teilen/Zusammenlegen erzeugt keine Frische.
- [ ] Verdorbenes Brot kann nicht gegessen werden.
- [ ] Werkstation kann keine Zutaten aus geschlossenem **anderen** Raum magisch nutzen.

## 14. P9 – Landwirtschaft und Produktionsketten

**Ziel:** Nahrung und Materialien versorgen Abenteuer und Basis, ohne tägliches Mikromanagement.

### Reihenfolge
- [ ] Mehrere Pflanzentypen über `CropData` statt neue Skripte pro Pflanze.
- [ ] Saatgut, Wachstum, Ernte, Erträge, begrenzte Anbauflächen.
- [ ] Einbindung in Spielzeit und Saves.
- [ ] Landwirtschaftliche Weiterverarbeitung: Weizen → Dreschen → Mahlen → Brot.
- [ ] Passive Prozesse: Backofen mit Zeit und Ausgabe; Spieler bedient aktive Stationen.
- [ ] Ernte/Produkte in physische Lager transferieren; Esel sammelt **nicht selbst Pflanzen ab**.
- [ ] Später Bewässerung, Dünger/Kompost, Bodenqualität und Jahreszeiten nur bei konkretem Gameplay-Nutzen.
- [ ] Rezeptlisten, kleine Produktionswarteschlangen, Nebenprodukte und klare Blockiergründe.
- [ ] Keine riesigen Produktionsketten ohne spielerischen Mehrwert.

**Abnahme:** Spieler kann Nahrung anbauen, verarbeiten, lagern und für Expeditionen mitnehmen; Esel transportiert passende Vorräte zwischen Gebäuden.

## 15. P10 – Forschung und Progression

- [ ] Wissen als eigenständige Ressource (keine Inventar-Teleport-Ressource).
- [ ] Einmalige Entdeckungs-/Erstherstellungs-/Meilensteinbelohnungen, begrenzte Wiederholungsboni.
- [ ] Forschungstisch und freischaltbare Technologien mit Voraussetzungen.
- [ ] Fünf Zweige: Baukunst, Handwerk, Landwirtschaft, Versorgung, Arkane Künste.
- [ ] Forschung schaltet konkrete Rezepte, Bauteile, Verbesserungen und Logistikoptionen frei.
- [ ] Einfache UI: gesperrt / verfügbar / erforscht, Voraussetzungen sichtbar.
- [ ] Persistenz und keine mehrfachen Erstbelohnungen.
- [ ] Keine künstlichen Wartezeiten ohne Designentscheidung.
- [ ] Erste Technologie demonstriert einen realen Nutzen (z. B. bessere Lagerkiste).

**Abnahme:** Eine Entdeckung erzeugt Wissen; Forschung verbraucht es korrekt und schaltet ein im Spiel nutzbares Feature frei.

## 16. P11 – Abenteuer und Kampf in Godot

**Nicht voreilig aus dem Browser-Prototyp kopieren.** Neu als kleine Godot-Vertikalschnitte umsetzen.

- [ ] Ein einfaches Ziel und Treffer-/Schadensmodell.
- [ ] Ein Gegner mit verständlicher Bewegung, Angriff und Tod.
- [ ] Spieler-Nahkampf, später Fernkampf/Mana.
- [ ] Schadensfeedback, Trefferfenster, Abklingzeiten, Ausweichen.
- [ ] Eine getrennte Abenteuerkarte und sicherer Übergang Heimat ↔ Abenteuer.
- [ ] Loot, begrenztes Inventar und Rücktransport zur Basis.
- [ ] Ein kleiner Dungeon mit Ziel, Belohnung und Rückkehr.
- [ ] Später Gegnervarianten, Bosse, seltene Ressourcen und Fortschrittsfreischaltungen.
- [ ] Sterben/Verlust-/Rückholregeln mit Nutzer abstimmen, bevor endgültig implementiert.

**Abnahme:** Spieler bereitet sich in Basis vor, betritt Abenteuergebiet, besiegt Gegner, nimmt Beute mit und nutzt sie zuhause.

## 17. P12 – Basisverteidigung

- [ ] Zunächst **ein** angekündigter Angriff mit klarer Vorbereitungszeit.
- [ ] Gegner greifen Basisbauteile an; Gebäudeschaden/Reparatur.
- [ ] Spieler verteidigt aktiv, Mauern/Verteidigungen helfen.
- [ ] Bedrohungsanstieg hauptsächlich durch bewusst erreichte Meilensteine/Expeditionen, nicht durch beliebig starkes Bauen.
- [ ] Unterschiedliche Gegnerrollen später: Masse, schnell, explosiv, schwer, Fernkampf, Boss.
- [ ] Keine ständigen Unterbrechungen friedlicher Aufbauphasen.
- [ ] NPC-Verteidiger erst nach gesonderter Nutzerfreigabe.

**Abnahme:** Angekündigte Angriffswelle ist spielbar und macht Bauentscheidungen sinnvoll.

## 18. P13 – Langfristige Erweiterungen, NICHT aktuelle Aufgaben

- Grundstückskauf und Erweiterung des Heimatlands.
- Mehrstöckige Häuser, Treppen, Türme, Burgarchitektur, Terrain-Anpassungen.
- Verbesserte Eselkarren, mehrere Esel, Stall, eventuell magische Transporthelfer.
- Magische Forschung, besondere Behälter, Runen, Alchemie.
- Neue Regionen, Bosse, seltene Beute, komplexere Dungeons.
- NPC-Rekrutierung, Berufe und automatisierte Arbeit **erst wenn der Nutzer dieses Thema wieder freigibt**.
- Balancing, UI-Politur, Performance, Accessibility, Content-Pipeline und Release.

## 19. Querschnittliche Testfälle (immer wieder prüfen)

### Inventar und Materialintegrität
- [ ] Kein Item mit negativer Menge.
- [ ] Volle Inventare/Kisten vernichten keine Items.
- [ ] Materialentnahme erfolgt nur aus physisch erlaubter Quelle.
- [ ] Reservierte Menge kann nicht doppelt verwendet werden.
- [ ] Aufteilung und Zusammenführung von Stapeln erhalten Gesamtmenge und Frische.
- [ ] Transport zwischen A, Esel und B erhält Gesamtmenge zu jedem Zeitpunkt.

### Bau und Welt
- [ ] Bauplatzierung nicht auf belegten Zellen.
- [ ] Baustellen mit mehreren Materialarten bauen nicht vorzeitig.
- [ ] Position/Drehung nach Fertigstellung und Save/Load korrekt.
- [ ] Raumzuordnung reagiert auf Änderungen am Gebäude.

### Produktion und Zeit
- [ ] Aktive Station benötigt Spieleraktion.
- [ ] Passive Station produziert nur mit Input, Zeit und Outputplatz.
- [ ] Queue-Bedarf berücksichtigt lokale Bestände, Reservierungen und ankommende Lieferungen.
- [ ] Spielpause, Szenenwechsel und Laden erzeugen keine unkontrollierte Mehrfachproduktion.
- [ ] Frischeboni verändern Rate, nicht Vergangenheit.

### UX und Performance
- [ ] Spieler sieht, **warum** eine Station/Logistikaufgabe blockiert ist.
- [ ] Kistenfilter und Eselprioritäten sind nachvollziehbar.
- [ ] Keine dauernden Esel-Kreisfahrten.
- [ ] Keine unnötigen pro-Frame-Vollscans aller Kisten und Baustellen.
- [ ] Bei größerer Siedlung zeitgesteuerte oder ereignisbasierte Bedarfsprüfung bevorzugen.

## 20. Offene Entscheidungen – nicht stillschweigend festlegen

1. Exakte Rastergröße, Bauteilmaße, Bauabbruch und Materialrückgabe.
2. Inventar-Startslots, Stackgrößen, Kistenkapazitäten und Upgrades.
3. Regeln für lokale Zugriffe im Freien (Radius) und für sehr große Räume.
4. Raumdetektion, Kellerbau, Untergeschosse und offene Dachkonstruktionen.
5. Spieltaglänge, Zeit bei Szenenwechseln, Offline-Fortschritt.
6. Esel-Tragkapazität, Ladepunkte, Wegfindung und Blockadeverhalten.
7. Konfliktregeln zwischen Mindestbestand und Produktionsbedarf.
8. Frische-Schwellen, Basishaltbarkeit und Stapelzusammenführung.
9. Konkrete Farming-Tiefe, Jahreszeiten und Bewässerung.
10. Schwierigkeit, Tod, Itemverlust und Angriffsfrequenz.
11. Exakte Reihenfolge späterer Kampf-/Bau-/Forschungsmeilensteine.

**Codex-Regel:** Bei offenem Designpunkt eine einfache reversible V1-Lösung *vorschlagen*, als Vorschlag kennzeichnen und bei relevanter Auswirkung den Nutzer entscheiden lassen.

## 21. Meilenstein-Protokoll (bei jeder abgeschlossenen Aufgabe ergänzen)

```text
Datum:
Phase / Teilaufgabe:
Nutzerauftrag:
Geprüfte Dateien:
Ist-Zustand vor Änderung:
Änderungen:
Getestet (tatsächlich):
Manuell zu testen:
Offene Probleme:
Nächster vorgeschlagener Schritt:
```

**Nicht** alte Einträge stillschweigend umschreiben; neue Erkenntnisse datiert ergänzen. Fortschritt nur als abgeschlossen markieren, wenn Abnahmekriterien tatsächlich geprüft wurden.

## 22. Aktualisierter Startprompt für Codex

> Lies `AGENTS.md` und `ENTWICKLUNGSPLAN.md`, insbesondere die neuen Beschlüsse in Abschnitt 1 und die Roadmap in Abschnitt 4. Prüfe den aktuellen Godot-Code auf Kamera, Input, Player, Navigation und Hauptszene. Schlage als **ersten** kleinen vertikalen Schritt eine isometrische Basiskamera mit Mausauswahl und danach den eigenen Charakter als NPC mit einem einzigen Weg-/Arbeitsauftrag vor. Nenne Konflikte mit Third-Person-Steuerung, direktem Spieler-Crafting und alten Esel-Phasen. **Verändere noch keine Godot-Dateien**, bis ich ausdrücklich die Umsetzung verlange. Nutze die historischen Kapitel nur als technische Referenz, nicht als verbindliche Reihenfolge.

## 23.1 Zusatzbeschluss 2026-10-25 – Funktionsräume

- Raumtyp C: genau eine **Hauptfunktion** je Raum; andere Tätigkeiten erlaubt.
- Funktionsfähigkeit abhängig von benötigten Raumobjekten; moderate Spezialisierungsboni möglich.
- NPCs werden Räumen/Arbeitsplätzen zugewiesen und bearbeiten dort Produktionsaufträge.
- Physische lokale Lager, Versorgung durch Transport-NPCs; Arbeiter holen Material ersatzweise selbst.
- Esel allenfalls später optionaler Transporthelfer; kein Rückfall zum alten Esel-Kernsystem.
- Raumübergreifende Produktionsketten/Reihenfolgen/Zielbestände bleiben später und offen.
- **Kleiner Testpfad für die spätere Implementierung:** einen geschlossenen Raum erkennen → Hauptfunktion Zimmermannswerkstatt wählen → Werkbank als Pflichtobjekt erkennen → einen NPC zuweisen → Holz aus einer realen Kiste entnehmen oder holen → Bretter produzieren → fehlende Werkbank/Materialien/Wege verständlich anzeigen. Nicht alles in einem frühen Meilenstein implementieren.
- Konkrete Raumobjekte, Raumgrößen, Boni, Arbeitsplatzzahlen und Transportprioritäten sind noch zu spezifizieren.

## 23. Änderungsprotokoll 2026-10-25 – Design-Pivot

- Produktionswarteschlangen auf je einen Auftrag pro Rezept, Wiederholungsmengen, manuelle Hoch-/Runter-Priorisierung und gezieltes Abbrechen festgelegt.
- Basisperspektive auf Going-Medieval-artige Übersicht geändert; Abenteuer top-down direkt gesteuert.
- Eigener Held ist erster autonomer Siedlungs-NPC; NPC-Arbeit und -Transport ersetzen Esel-Logistik.
- Esel/Tiere auf unbestimmte spätere Erweiterung verschoben.
- Basis läuft während Expeditionen weiter; Held ist dort abwesend.
- NPC-Tiefe B; Rekrutierung durch Anreise und Expeditionen; besondere Bewohner können Hintergründe/Hinweise besitzen.
- Spielstart in zerstörter Stadt; Ruinen als Ressourcen-/Restaurierungs-/Entdeckungsobjekte.
- Mystery als optionale mechanische Perspektive: untersuchbare Fundstücke, Hinweise, Zeugenaussagen, Ermittlungsbuch und spätere Freischaltungen. **Kein Storyskript festgelegt**.
- Direkte Charakterübernahme bei Basisangriffen weit nach hinten verschoben.
- Bestehender Godot-Code wurde durch diese Dokumentänderung **nicht implementiert oder laufzeitgetestet**.

---
**Pflege:** Dieser Plan soll mit dem Code mitwachsen, aber nie unbemerkt Designentscheidungen ersetzen. Bei neuer Nutzerentscheidung gezielt betroffene Abschnitte ändern, Widersprüche bereinigen und den Änderungsgrund dokumentieren.
