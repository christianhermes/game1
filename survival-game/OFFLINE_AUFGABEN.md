# Offline-Aufgaben: Bauen V1

## Aktueller Meilenstein: Gemeinsames Blockraster für alle Bauarten

Bevor Fundamente, Böden oder Werkbänke hinzukommen, wird die bisherige
wandbezogene Platzierung in eine zentrale `BuildGrid`-Klasse überführt. Eine
Rasterposition ist ein `Vector3i`: X und Z bestimmen die Bodenfläche, Y das
Stockwerk. Fundament, Boden und Einrichtung besitzen getrennte Schichten und
dürfen deshalb dieselbe Zelle sinnvoll gemeinsam verwenden. Wände bleiben
dünne Kanten zwischen Zellen.

Der bestehende Wandbau bleibt während der Aufgaben zunächst aktiv. Entferne
alte Hilfsfunktionen erst in Aufgabe 38 nach erfolgreichen Vergleichstests.

### Abgeschlossen: Aufgabe 33 – Platzierungsdaten eines Rezepts validieren

Dateien:

- `godot/scripts/building/build_recipe.gd`
- `godot/scripts/building/construction_site.gd`

`BuildRecipe` besitzt bereits `placement_type`, `footprint`, `height_levels`
und `can_rotate`. Implementiere `is_placement_data_valid()` wie im TODO
beschrieben:

1. Breite und Tiefe der Grundfläche müssen mindestens 1 sein.
2. Die Höhe muss mindestens eine Ebene betragen.
3. Eine Wandkante verwendet in V1 exakt `Vector2i.ONE`.
4. Erst nach allen Prüfungen folgt `return true`.

Ergänze am Ende von `ConstructionSite._is_recipe_valid()` außerdem:

```gdscript
return recipe.is_placement_data_valid()
```

Entferne dafür das bisherige abschließende `return true`. Das vorhandene
Holzwand-Rezept verwendet durch die Standardwerte weiterhin `WALL_EDGE` und
eine Grundfläche von 1×1.

### Abgeschlossen: Aufgabe 34 – Weltposition und Rasterzelle umrechnen

Datei: `godot/scripts/building/build_grid.gd`.

Die beiden Umwandlungsfunktionen sind fertig. `world_to_cell()` findet die
logische Zelle einer Weltposition. `cell_to_world()` liefert die Mitte dieser
Zelle zurück. Die Umrechnung funktioniert auch mit negativen Koordinaten.

### Abgeschlossen: Aufgabe 35 – drehbare mehrzellige Grundflächen berechnen

Datei: `godot/scripts/building/build_grid.gd`, Funktion
`get_footprint_cells()`.

Das vollständige Funktionsgerüst steht bereits im Code. Drehung, Größe, Array
und Schleifen sind vorbereitet. Ergänze ausschließlich die mit `TODO 35.1`
markierte Stelle: Erzeuge dort aus den drei direkt darüber erklärten Werten
eine `Vector3i`-Zelle und füge sie mit `append()` zu `occupied_cells` hinzu.

Tests:

- 1×1 ergibt immer genau eine Zelle.
- 2×1 bei Drehung 0 ergibt zwei Zellen entlang X.
- 2×1 bei Drehung 1 ergibt zwei Zellen entlang Z.
- Alle Ergebnisse behalten `origin.y` als Stockwerk.

### Abgeschlossen: Aufgabe 36 – Kanten und Belegungsschichten prüfen

Datei: `godot/scripts/building/build_grid.gd`.

Das Gerüst teilt die Aufgabe in zwei kleine Stellen:

1. `TODO 36.1` baut aus der bereits bestimmten Richtung und dem Ursprung einen
   eindeutigen Namen für eine Wandkante. Das gewünschte Format und die dafür
   benötigten Werte stehen unmittelbar an der Stelle im Code.
2. `TODO 36.2` befindet sich in einer fertigen Schleife über alle benötigten
   Zellen. Prüfe dort nur, ob die aktuelle Zelle bereits als Key in
   `occupancy` existiert. Bei einem Treffer muss sofort `false` folgen.

Fundament, Boden und Werkbank dürfen so dieselbe Koordinate besitzen, während
zwei Böden oder zwei Werkbänke auf derselben Schicht kollidieren.

### Abgeschlossen: Aufgabe 37 – Platzierungen registrieren und übertragen

Datei: `godot/scripts/building/build_grid.gd`.

Auch diese Funktionen besitzen jetzt fertige Schleifen und Prüfungen. Ergänze
die drei markierten Stellen nacheinander:

1. `TODO 37.1`: Speichere den `owner` unter dem aktuellen Zell-Key.
2. `TODO 37.2`: Sammle alle Keys, deren gespeicherter Wert `owner` ist. Das
   eigentliche Entfernen ist bereits implementiert.
3. `TODO 37.3`: Ersetze bei übereinstimmendem `current_owner` nur den Wert durch
   `new_owner`. Der Key bleibt unverändert.

Teste insbesondere, dass eine fehlgeschlagene Registrierung kein Dictionary
teilweise verändert.

### Abgeschlossen: Aufgabe 38 – BuildManager auf BuildGrid umstellen

Datei: `godot/scripts/building/build_manager.gd`.

Dieser Schritt verbindet die zuvor isoliert getesteten Bausteine. Der
`BuildManager` speichert jetzt Rasterursprung und Vierteldrehung, berechnet je
nach Rezept eine Wandkante oder Zelle und verwendet `BuildGrid.can_place()`
für Vorschaufarbe und Platzierung. Neue Baustellen werden erst nach dem
Einfügen in die Szene registriert; bei einem Fehlschlag werden sie entfernt.

Die vorherigen Hilfsfunktionen für reine Wandbelegung wurden nach erfolgreichen
Integrationstests entfernt. Bereits in der Hauptszene vorhandene Baustellen
werden beim Start ebenfalls im zentralen Raster registriert.

### Abgeschlossen: Aufgabe 39 – Baustelle und fertiges Gebäude übertragen

Datei: `godot/scripts/building/construction_site.gd`.

Die Baustelle prüft vor dem Fertigstellen, ob ihre Rasterreservierung übertragen
werden kann. Nach dem Einfügen und Positionieren übernimmt das fertige Gebäude
den bisherigen Raster-Key, bevor die Baustelle entfernt wird.

Abschlusstest des Rasterfundaments:

1. Holzwände lassen sich weiterhin drehen und zu einem Raum schließen.
2. Identische Wandkanten bleiben blockiert.
3. Testweise registrierte Boden- und Fundamentschicht dürfen dieselbe Zelle
   gemeinsam verwenden.
4. Zwei Objekte derselben Schicht dürfen sich nicht überschneiden.
5. Eine 2×1-Grundfläche belegt nach 90 Grad die korrekten Zellen.
6. Eine Baustelle überträgt ihre Belegung auf das fertige Gebäude.
7. Negative Koordinaten und Stockwerk 1 erzeugen eindeutige Keys.

Bewusst noch nicht Teil dieses Meilensteins:

- sichtbare Boden- und Fundament-Szenen,
- Bauauswahlmenü,
- automatische Raumdetektion,
- dynamische Navigation nach jedem Bauteil,
- freie Dekorationsplatzierung außerhalb des Rasters.

---

## Aktueller Meilenstein: Baustelle abbrechen und Material zurückgeben

Nach dem kantenbasierten Wandraster können geschlossene Räume gebaut werden.
Als nächster zusammenhängender Schritt soll eine falsch gesetzte, noch
unfertige Baustelle im Baumodus mit Rechtsklick abgebrochen werden. Bereits
angelieferte Materialien erscheinen anschließend als physische Pickups neben
der Baustelle; fertige Wände bleiben davon unberührt.

### Abgeschlossen: Aufgabe 40 – Aufträge eines Weltziels abbrechen

Datei: `godot/scripts/jobs/settlement_job_manager.gd`, Funktion
`cancel_jobs_for_target()`.

Durchlaufe die Schlüssel des `jobs`-Dictionary. Vergleiche bei jedem Auftrag
dessen `target_id` mit dem Parameter. Nur bei gleicher ID rufst du die bereits
vorhandene Funktion `cancel_job(job_id)` auf. Zähle erfolgreiche Abbrüche und
gib die Anzahl zurück.

Wichtig: Entferne die Aufträge nicht aus dem Dictionary. Der Status
`CANCELLED` bleibt als nachvollziehbarer Lebenszyklus erhalten und stoppt auch
einen eventuell wartenden asynchronen Bauablauf.

### Abgeschlossen: Aufgabe 41 – gelieferte Materialien als Pickups zurückgeben

Datei: `godot/scripts/building/construction_site.gd`, Funktion
`_spawn_refund_pickups()`.

Das benötigte `refund_pickup_scene` ist bereits im Inspector der
Baustellenszene zugewiesen. Erzeuge je Eintrag in `delivered_materials` genau
ein `ItemPickup` mit der dort gespeicherten Gesamtmenge. Setze Exportwerte vor
`add_child()` und die globale Position erst danach.

Nutze einen laufenden Index, um:

- eindeutige `world_id`-Werte zu bilden,
- mehrere Materialarten leicht versetzt nebeneinander abzulegen.

Materialien gehen nicht direkt in ein Inventar zurück. Sie bleiben als reale
Objekte in der Welt und können anschließend wieder eingesammelt werden.

### Abgeschlossen: Aufgabe 42 – Baustelle kontrolliert entfernen

Datei: `godot/scripts/building/construction_site.gd`, Funktion
`cancel_construction()`.

Die ausgeführte Reihenfolge ist:

1. Alle Aufträge mit derselben `world_id` abbrechen.
2. Gelieferte Materialien als Pickups erzeugen.
3. Die Rasterreservierung freigeben.
4. Erst danach die Baustelle mit `queue_free()` entfernen.

Eine fertige Wand besitzt diese Funktion nicht und kann daher nicht
versehentlich über diesen Ablauf entfernt werden.

### Abgeschlossen: Aufgabe 43 – Rechtsklick im Baumodus verbinden

Dateien:

- `godot/scripts/building/build_manager.gd`
- `godot/scripts/main.gd`

`try_cancel_construction_site()` trifft bewusst auch `Area3D`-Baustellen und
schließt Bauobjekte bei diesem Raycast nicht aus. Nur eine erfolgreich
abgebrochene `ConstructionSite` liefert `true`. Im Rechtsklick-Zweig von
`Main._input()` hat dieser Abbruch im Baumodus Vorrang; bei anderen Treffern
bleibt der bestehende Bewohnerbefehl erhalten.

Abschlusstest für Aufgaben 40 bis 43:

1. Leere Baustelle rechtsklicken: Sie verschwindet ohne Rückgabe.
2. Einen Teil der Materialien liefern und abbrechen: Nur diese Menge erscheint.
3. Vollständig belieferte, aber unfertige Baustelle abbrechen: Alles erscheint.
4. Während der Bauarbeit abbrechen: Keine weiteren Hammerschläge danach.
5. Fertige Wand rechtsklicken: Sie bleibt bestehen.
6. Rückgabe-Pickups lassen sich als normale Aufträge einsammeln.
7. Ein normaler Rechtsklick außerhalb des Baumodus steuert den Bewohner weiter.

Bewusst noch nicht enthalten:

- fertige Gebäude abreißen,
- nur einen prozentualen Materialanteil zurückgeben,
- Abbruchbestätigung oder Auswahlwerkzeug,
- reservierte Materialien aus entfernten Kisten.

---

## Implementiert: Zentrales Informationsfenster für Weltobjekte

Die früheren `Label3D`-Beschriftungen wurden durch das Fenster
`WorldInfoPanel` links im HUD ersetzt. Ein Linksklick im Basismodus zeigt dort
die Informationen des getroffenen Objekts, beispielsweise Leben, Feldzustand,
Materiallieferung, Bauarbeit oder die Produktionswarteschlange. Die Objekte
stellen diese Daten über `get_world_info_title()` und `get_world_info_text()`
bereit; das gemeinsame Fenster muss deshalb keine konkreten Objektklassen
kennen und aktualisiert veränderliche Werte live.

Ein Klick auf leeren Boden oder der Wechsel in den Charaktermodus schließt das
Fenster. Werkstationen öffnen zusätzlich weiterhin ihr Produktionsmenü.

## Historischer Zwischenschritt: Belegte Bauzellen erkennen

Die Aufgaben 27 bis 29 führten zunächst eine Belegungsprüfung pro Rasterzelle
ein. Dieses einfache Modell verhinderte jedoch saubere Hausecken. Es wurde
deshalb anschließend durch das aktuelle kantenbasierte Wandraster ersetzt.
Die folgenden Aufgaben bleiben als Lernprotokoll erhalten; maßgeblich ist der
aktuelle Code mit `BuildGrid.wall_edge_occupancy` und den getrennten
Belegungsschichten.

Das damalige Ziel war ein klarer Platzierungsfehler, den du direkt im Spiel
sehen und testen kannst: Eine neue Baustelle darf nicht auf einer vorhandenen
Baustelle oder einer fertigen Wand entstehen. Die Vorschau bleibt auf der
Rasterzelle sichtbar, wird dort aber rot.

Die Szenen `construction_site.tscn` und `WoodWall.tscn` gehören bereits zur
Gruppe `build_occupant`. Dadurch muss der `BuildManager` weder konkrete
Szenennamen noch Klassen kennen. Spätere Bodenbauteile können dieselbe Gruppe
verwenden.

### Abgeschlossen: Aufgabe 27 – belegte Rasterzelle erkennen

Datei: `godot/scripts/building/build_manager.gd`, Funktion
`_is_build_cell_occupied()`.

Eine Rasterzelle wird hier als `Vector2i` aus X und Z dargestellt. Berechne
zuerst die gesuchte Zelle:

```gdscript
var target_cell := Vector2i(
	roundi(position.x / GRID_SIZE),
	roundi(position.z / GRID_SIZE),
)
```

Durchlaufe danach alle Nodes aus:

```gdscript
get_tree().get_nodes_in_group(BUILD_OCCUPANT_GROUP)
```

Prüfe mit `if not occupant is Node3D:`, ob der Eintrag eine räumliche Position
besitzt. Berechne für gültige Nodes aus `occupant.global_position` ebenfalls
einen `Vector2i`. Bei gleicher Zelle gibst du sofort `true` zurück. Wird die
Schleife beendet, ohne etwas zu finden, folgt `return false`.

Warum vergleichen wir Rasterkoordinaten statt Abstände? Zwei Objekte gehören
damit eindeutig zu derselben Bauzelle, auch wenn ihre sichtbaren Meshes
unterschiedlich breit oder gedreht sind.

Test nach Aufgabe 27:

1. Setze vorübergehend einen `print()` direkt vor `return true`.
2. Bewege die Vorschau über die vorhandene Baustelle am Weltursprung.
3. Die Ausgabe muss den Treffer melden.
4. Entferne die Testausgabe danach wieder.

### Abgeschlossen: Aufgabe 28 – gültige und ungültige Vorschau anzeigen

Datei: `godot/scripts/building/build_manager.gd`.

Ergänze die markierte Stelle in `_process()`:

1. Rufe `_is_build_cell_occupied(current_placement_position)` auf.
2. Speichere das Gegenteil in `current_placement_valid`, denn **nicht belegt**
   bedeutet **gültig**.
3. Übergib den gespeicherten Wert an
   `_update_placement_preview_color(current_placement_valid)`.

Implementiere anschließend `_update_placement_preview_color()`:

```gdscript
var preview_material := placement_preview.material_overlay as StandardMaterial3D
```

Falls `preview_material == null` ist, beendest du die Funktion. Andernfalls
setzt du `preview_material.albedo_color` abhängig von `is_valid` auf
`VALID_PREVIEW_COLOR` oder `INVALID_PREVIEW_COLOR`.

Test nach Aufgabe 28:

1. Freie Zellen zeigen eine grüne Vorschau.
2. Die vorhandene Baustelle zeigt eine rote Vorschau.
3. Eine fertig gebaute Wand zeigt ebenfalls eine rote Vorschau.
4. Die Vorschau folgt weiterhin sauber dem 2-Meter-Raster.

### Abgeschlossen: Aufgabe 29 – Platzierung auf belegter Zelle verhindern

Datei: `godot/scripts/building/build_manager.gd`, Funktion
`try_place_construction_site()`.

Ergänze die vorhandene Abbruchbedingung um:

```gdscript
or not current_placement_valid
```

Damit ist die Farbe nicht nur eine Anzeige: Dieselbe Zustandsvariable schützt
auch die eigentliche Platzierung. Verändere das Gruppen-Array oder die Welt
nicht direkt in dieser Prüfung.

Abschlusstest nach Aufgabe 29:

1. Platziere eine Baustelle auf einer freien grünen Zelle.
2. Bewege die Vorschau genau auf diese Baustelle: Sie wird rot.
3. Linksklick darf dort keine zweite Baustelle erzeugen.
4. Baue die Wand fertig und versuche dieselbe Zelle erneut: weiterhin gesperrt.
5. Direkt benachbarte Rasterzellen bleiben grün und bebaubar.
6. Drehen mit `R`, Beenden mit `B` und Moduswechsel mit `Tab` funktionieren
   weiterhin.

Bewusst noch nicht Teil dieses Meilensteins:

- mehrzellige Gebäude und unterschiedliche Grundflächen,
- Stockwerke und getrennte Höhenebenen,
- Geländegefälle oder Fundamentregeln,
- automatische Wandanschlüsse,
- Baustellenabbruch und Materialrückgabe.

---

## Abgeschlossener Meilenstein: Mehrmaterial-Baustellen und sichere Rezepte

Dieser Meilenstein erweitert Baustellen so, dass sie nicht nur Holz, sondern
mehrere Materialarten korrekt anzeigen und prüfen können. Außerdem verursacht
ein leeres oder fehlerhaftes `BuildRecipe` keinen Array- oder
Nullzugriffsfehler mehr.

### Abgeschlossen: Aufgabe 30 – Bau-Rezept vollständig validieren

Datei: `godot/scripts/building/construction_site.gd`, Funktion
`_is_recipe_valid()`.

Prüfe nacheinander die im TODO genannten Fehlerfälle. Verwende frühe
Rückgaben: Sobald ein Fehler gefunden wurde, gibst du `false` zurück. Für die
Materialien brauchst du eine Schleife über `recipe.required_materials`.

Beispiele für die Schreibweise:

```gdscript
if recipe == null:
	return false

if recipe.required_materials.is_empty():
	return false
```

Innerhalb der Materialschleife prüfst du den Eintrag selbst, dessen `item_id`
und dessen `amount`. Erst ganz am Ende der Funktion folgt `return true`.

Test nach Aufgabe 30:

1. Das normale Holzwand-Rezept muss `true` ergeben.
2. Ein fehlendes Rezept muss `false` ergeben.
3. Ein Rezept mit leerer Materialliste muss `false` ergeben.
4. Temporäre `print()`-Ausgaben nach der Prüfung wieder entfernen.

### Abgeschlossen: Aufgabe 31 – Statuszeile für alle Materialien erzeugen

Datei: `godot/scripts/building/construction_site.gd`, Funktion
`_get_material_status_text()`.

Lege eine leere Liste aus Strings an:

```gdscript
var lines: Array[String] = []
```

Durchlaufe alle Materialien des Rezepts. Lies für jedes Material die bisher
gelieferte Menge genauso aus `delivered_materials`, wie es `_has_all_materials()`
bereits vormacht. Formatiere je Material eine Zeile und füge sie mit
`lines.append(...)` an. Der Rückgabewert ist:

```gdscript
return "\n".join(lines)
```

Die Funktion baut nur Text. Sie verändert weder Inventar noch Baustelle.

### Abgeschlossen: Aufgabe 32 – Label und Bauablauf gegen ungültige Rezepte absichern

Datei: `godot/scripts/building/construction_site.gd`.

Arbeite die vier nummerierten Hinweise direkt über `_update_label()` ab:

1. `_update_label()` zeigt zuerst Rezeptname und sämtliche Materialzeilen.
2. Werkzeug und Arbeitsfortschritt erscheinen erst, wenn
   `_has_all_materials()` wahr ist.
3. `_ready()` verwendet `_is_recipe_valid()` statt nur `recipe == null`.
4. `_deliver_all_materials()`, `perform_build_job()` und
   `_complete_building()` prüfen das Rezept, bevor sie auf dessen Daten
   zugreifen.

Für den Test mit zwei Materialarten kannst du dem Holzwand-Rezept im Inspector
vorübergehend zusätzlich `stone` hinzufügen. Notiere dir vorher den
Originalzustand oder verwende eine separate Testressource. Erwartet wird zum
Beispiel:

```text
Holzmauer
Wood: 2/3
Stone: 1/2
```

Die Arbeitsanzeige darf erst erscheinen, wenn beide Zeilen vollständig sind.
Stelle das produktive Rezept nach einem temporären Test wieder zurück.

Bewusst noch nicht Teil dieses Meilensteins:

- Materialien automatisch aus Kisten holen,
- Materialreservierungen zwischen mehreren Baustellen,
- Baustellen abbrechen oder Ressourcen zurückgeben,
- mehrere Bewohner gleichzeitig bauen lassen.

---

## Abgeschlossener Meilenstein: Vorschau, Baustelle und fertige Wand drehen

Die freie Rasterplatzierung und der vollständige zeitgesteuerte BUILD-Auftrag
funktionieren. Das Ziel der Aufgaben 23 bis 26 ist ein kleiner, sichtbarer
Abschluss von Bauen V1: Mit `R` wird die Holzwand vor dem Platzieren in festen
90-Grad-Schritten gedreht. Vorschau, Baustelle und fertige Wand müssen dabei
dieselbe Ausrichtung besitzen.

### Abgeschlossen: Aufgabe 23 – Input-Aktion im Godot-Editor anlegen

Diese Aufgabe findet absichtlich im Editor und nicht im Skript statt:

1. Öffne `Projekt > Projekteinstellungen > Eingabezuordnung`.
2. Lege die Aktion `rotate_building` an.
3. Klappe die neue Aktion auf und füge ein Tastenereignis hinzu.
4. Drücke die physische Taste `R` und bestätige die Zuweisung.
5. Kontrolliere, dass `rotate_building` nur einmal in der Liste existiert.
6. Speichere das Projekt.

Warum über die Projekteinstellungen? Alle veränderbaren Tasten bleiben damit
an einer Stelle sichtbar. Es wird keine parallele Code-Zuweisung angelegt, die
später zu `An action with this name already exists` führen könnte.

Prüfung nach Aufgabe 23:

- `rotate_building` steht in der Eingabezuordnung.
- Unter der Aktion wird `R` angezeigt.
- Godot startet weiterhin ohne Fehlermeldung über eine unbekannte Aktion.

### Abgeschlossen: Aufgabe 24 – Rotationszustand und Vorschau drehen

Datei: `godot/scripts/building/build_manager.gd`.

Die Variablen `PLACEMENT_ROTATION_STEP` und `placement_rotation_y` sind bereits
als verständliches Gerüst eingefügt. Ergänze die beiden markierten Stellen:

1. `_unhandled_input()` reagiert nur bei aktivem `build_mode` auf
   `rotate_building`.
2. Bei einem Treffer wird `_rotate_placement()` aufgerufen und das Event als
   verarbeitet markiert.
3. `_rotate_placement()` addiert einen 90-Grad-Schritt.
4. `wrapf(..., 0.0, TAU)` hält den Winkel zwischen 0 und einer vollständigen
   Umdrehung.
5. `placement_preview.rotation.y` erhält den gespeicherten Winkel.

`PI / 2` entspricht 90 Grad. `TAU` entspricht 360 Grad. Godot speichert
Drehungen intern in Radiant, auch wenn der Inspector Gradwerte anzeigt.

Test nach Aufgabe 24:

1. In den Basismodus und anschließend in den Baumodus wechseln.
2. `R` viermal einzeln drücken.
3. Die Vorschau muss nacheinander 90, 180, 270 und wieder 0 Grad erreichen.
4. Die Kamera darf sich durch `R` nicht drehen.

### Abgeschlossen: Aufgabe 25 – Drehung auf die Baustelle übertragen

Datei: `godot/scripts/building/build_manager.gd`, Funktion
`try_place_construction_site()`.

Setze nach `add_child()` und der globalen Position auch:

```gdscript
site.global_rotation.y = placement_rotation_y
```

Warum erst nach `add_child()`? Eine globale Transformation bezieht sich auf
den Szenenbaum und den Transform des Parents. Nach dem Einfügen ist diese
Beziehung eindeutig vorhanden.

`ConstructionSite._complete_building()` kopiert bereits den gesamten
`global_transform`. Darin stecken Position, Drehung und Skalierung. Deshalb
benötigt die fertige Wand keine zweite eigene Rotationslogik.

Test nach Aufgabe 25:

1. Vorschau einmal mit `R` drehen und platzieren.
2. Die orange Baustelle muss genau wie die Vorschau ausgerichtet sein.
3. Den Bauauftrag vollständig ausführen lassen.
4. Die fertige Wand darf beim Abschluss nicht in die Ausgangsrichtung springen.

### Abgeschlossen: Aufgabe 26 – Rotation sauber zurücksetzen und anzeigen

Dateien:

- `godot/scripts/building/build_manager.gd`
- `godot/scripts/main.gd`

Implementiere `_reset_placement_rotation()` so, dass gespeicherter Winkel und
Vorschau jeweils auf `0.0` gesetzt werden. Rufe die Funktion auf:

- wenn `B` einen aktiven Baumodus beendet,
- wenn `set_control_enabled(false)` den gesamten Basismodus beendet.

Ergänze außerdem im sichtbaren Hinweis des Basismodus:

```text
R: Bauteil drehen
```

Abschlusstest nach Aufgabe 26:

1. Wand drehen, platzieren und vollständig bauen.
2. Baumodus beenden und erneut öffnen: Vorschau startet wieder bei 0 Grad.
3. Wand drehen und direkt mit `Tab` in den Charaktermodus wechseln.
4. Nach Rückkehr in Basis- und Baumodus startet sie ebenfalls bei 0 Grad.
5. Zwei unterschiedlich gedrehte Wände bauen; beide behalten ihre Ausrichtung.
6. Versuche auf einer bestehenden Baustelle und einer fertigen Wand erneut zu
   platzieren. Notiere, ob eine Überlappung möglich ist. Falls ja, wird die
   robuste Raster-Belegungsprüfung der nächste gezielte Bugfix.

Bewusst noch nicht Teil dieses Meilensteins:

- freie Drehwinkel statt 90-Grad-Schritten,
- Bauauswahl mit mehreren Rezepten,
- Baustellenabbruch und Materialrückgabe,
- Kistenlogistik und automatische Auftragswahl,
- komplexe Anschluss- oder Raumregeln.

---

# Abgeschlossener Meilenstein: Vollständiger zeitgesteuerter Bauauftrag

## Ergebnis: Ein Auftrag baut eine Holzmauer vollständig

Die Aufgaben 11 bis 18 sind abgeschlossen und im Spiel geprüft:

- Holzmauer-Baustellen lassen sich im 2-Meter-Raster platzieren.
- Jede Baustelle besitzt eine stabile Ziel-ID und erzeugt einen BUILD-Auftrag.
- Der ausgewählte Bewohner läuft selbstständig zur Baustelle.
- Material und Werkzeug werden direkt im Inventar geprüft, unabhängig von der
  ausgewählten Hotbar-Position.

Das Ziel der Aufgaben 19 bis 22: Ein einziger Rechtsklick liefert alle beim
Bewohner vorhandenen Materialien und führt anschließend sichtbare
Hammerschläge mit zeitlichem Abstand aus. Der Auftrag bleibt bis zum Ende
aktiv und lässt sich durch einen neuen Befehl abbrechen.

### Abgeschlossen: Aufgabe 19 – alle Baumaterialien in einem Auftrag liefern

Datei: `godot/scripts/building/construction_site.gd`.

Der ausführliche TODO-Kommentar vor `interact()` beschreibt zwei neue Helfer:

- `_has_all_materials()` prüft alle Einträge des Rezepts.
- `_deliver_all_materials(actor)` überträgt mit einer `while`-Schleife alle
  noch fehlenden Stücke aus dem Bewohnerinventar.

Wichtige Regel: Wenn der Bewohner nur einen Teil der benötigten Materialien
besitzt, wird dieser Teil trotzdem abgeliefert. Die Funktion liefert danach
`false`, und ein späterer Auftrag kann die restlichen Materialien ergänzen.
Bereits abgeliefertes Material geht nicht verloren.

`interact()` soll anschließend nur noch:

1. `_deliver_all_materials(actor)` aufrufen,
2. bei `false` abbrechen,
3. bei `true` einmal `_try_build(actor)` aufrufen.

Test nach Aufgabe 19:

1. Bewohner muss drei Holz im Inventar besitzen.
2. Ein Rechtsklick auf die Baustelle muss sofort `Wood: 3/3` ergeben.
3. Derselbe Auftrag darf zunächst höchstens einen Arbeitsschritt ausführen.
4. Godot darf keinen Parser- oder Laufzeitfehler melden.

### Abgeschlossen: Aufgabe 20 – laufenden Auftrag eindeutig prüfen

Datei: `godot/scripts/player.gd`.

Ergänze `is_current_job(job_id: int) -> bool` an der markierten Stelle. Die
Funktion liefert nur dann `true`, wenn:

- `current_job_id` mit dem Parameter übereinstimmt,
- der Auftrag im Manager noch existiert und
- sein Status `SettlementJobManager.JobStatus.RUNNING` ist.

Warum reicht der Vergleich der IDs allein nicht? Ein Auftrag könnte im Manager
bereits abgebrochen sein, obwohl ein asynchroner Timer noch auf sein Signal
wartet. Beide Zustände müssen deshalb geprüft werden.

Test nach Aufgabe 20:

1. Godot starten und einen gewöhnlichen Pickup-Auftrag erteilen.
2. Während des laufenden Auftrags muss die Funktion für dessen ID `true`
   liefern; nach Abschluss oder Abbruch `false`.
3. Eine vorübergehende `print()`-Ausgabe nach dem Test wieder entfernen.

### Abgeschlossen: Aufgabe 21 – sichtbare Hammerschläge über Zeit ausführen

Datei: `godot/scripts/building/construction_site.gd`.

Ergänze die im TODO beschriebene asynchrone Funktion:

```gdscript
func perform_build_job(actor: Node3D, job_id: int) -> bool:
	# Materialien liefern, Werkzeug prüfen und zeitgesteuert arbeiten.
```

`await get_tree().create_timer(0.75).timeout` pausiert nur diese Funktion. Das
Spiel, die Kamera und andere Nodes laufen weiter. Prüfe den aktiven Auftrag
sowohl vor als auch nach jedem `await`, damit ein neuer Befehl keinen alten
Hammerschlag mehr ausführt.

Die Funktion liefert:

- `true`, wenn die Wand vollständig gebaut wurde,
- `false`, wenn Material oder Werkzeug fehlt oder der Auftrag abgebrochen wurde.

Aufgabe 21 ist erst nach Aufgabe 22 vollständig im Spiel testbar, weil der
Player die asynchrone Funktion zunächst noch aufrufen und abwarten muss.

### Abgeschlossen: Aufgabe 22 – BUILD-Auftrag abwarten und korrekt abschließen

Datei: `godot/scripts/player.gd`, Funktion `_complete_current_job()`.

BUILD erhält einen eigenen Zweig vor der bisherigen synchronen
`interact()`-Behandlung. Speichere die aktive Job-ID vor `await`, warte auf
`target.perform_build_job(self, active_job_id)` und prüfe danach erneut, ob
dieselbe Job-ID noch aktiv ist.

- Ergebnis `true`: `finish_job(active_job_id)`.
- Ergebnis `false`: `cancel_job(active_job_id)`.
- Wurde zwischenzeitlich ein neuer Auftrag vergeben, darf der alte Ablauf
  weder den neuen Auftrag beenden noch `current_job_id` zurücksetzen.

Abschlusstest nach Aufgabe 22:

1. Holz per Pickup-Auftrag einsammeln.
2. Holzmauer-Baustelle platzieren und Baumodus beenden.
3. Bewohner auswählen und die Baustelle genau einmal rechtsklicken.
4. Der Bewohner läuft zur Baustelle und liefert alle drei Holz.
5. Danach steigt die Arbeitsanzeige ungefähr alle 0,75 Sekunden von 0 bis 5.
6. Erst nach dem letzten Schritt erscheint die fertige Holzmauer.
7. Zweiten Test starten und während der Bauarbeit ein anderes Laufziel
   rechtsklicken: Der Bewohner muss die Arbeit spätestens vor dem nächsten
   Hammerschlag beenden und dem neuen Befehl folgen.
8. Ein alter asynchroner Ablauf darf den neuen Auftrag nicht abschließen.

Bewusst noch nicht Teil dieses Meilensteins:

- Material selbstständig aus Kisten holen oder reservieren.
- Einen blockierten Auftrag automatisch wieder aufnehmen.
- Mehrere Bewohner gleichzeitig an einer Baustelle.
- Animation, Ton und sichtbarer Hammer.
- Drehen, Abbrechen und Materialrückgabe einer Baustelle.
- Speichern und Laden dynamisch platzierter Baustellen.

---

# Abgeschlossene Aufgaben: Ressourcen und Produktionswarteschlange

Die Aufgaben 1 bis 10 sind abgeschlossen. Das Workstation-Menü besitzt damit
gestapelte, nach Priorität sortierbare und einzeln abbrechbare
Produktionsaufträge.
Starte nach jeder Aufgabe das Projekt und behebe Parserfehler, bevor du mit der
nächsten Aufgabe beginnst. Fertige TODO-Kommentare werden durch dauerhafte
Dokumentation ersetzt.

## Abgeschlossen: Aufgabe 6 – Wiederholungen im Rezeptauftrag stapeln

Datei: `godot/scripts/workstation/processing_station.gd`, Funktion
`enqueue_recipe()`.

Jedes Rezept kommt höchstens einmal in der Liste vor. Ein erneuter Klick erhöht
nur `amount` dieses Auftrags. Seine Position und damit seine Priorität bleibt
unverändert.

## Abgeschlossen: Aufgabe 7 – Auftrag anhand seiner ID entfernen

Datei: `godot/scripts/workstation/processing_station.gd`, Funktion
`remove_queued_order()`.

Jeder Auftrag besitzt eine ID. Suche diese ID und entferne genau den gefundenen
Eintrag, unabhängig davon, wo er in der Queue steht.

## Abgeschlossen: Aufgabe 8 – Priorität eines Auftrags verschieben

Datei: `godot/scripts/workstation/processing_station.gd`, Funktion
`move_queued_order()`.

Verschiebe den gewählten Auftrag genau eine Position hoch oder herunter. Die
Array-Reihenfolge ist gleichzeitig die Ausführungspriorität: Index 0 kommt
immer zuerst, unabhängig von der Wiederholungsmenge.

## Abgeschlossen: Aufgabe 9 – sichtbare Prioritätszeile bauen

Datei: `godot/scripts/ui/workstation_menu.gd`, Funktion `_create_queue_row()`.

Jeder ProductionOrder erhält eine Zeile mit Position, Rezeptname, Menge sowie
Hoch-, Runter- und Abbrechen-Button. Am oberen und unteren Listenrand ist die
jeweils unmögliche Verschiebung deaktiviert.

## Abgeschlossen: Aufgabe 10 – Buttons an die Station delegieren

Datei: `godot/scripts/ui/workstation_menu.gd`, Funktionen
`_on_cancel_order_pressed()` und `_on_move_order_pressed()`.

Das UI übergibt nur die im Button gespeicherte ID und gegebenenfalls die
Richtung an die Station. Es verändert niemals selbst das Queue-Array.

Test für Aufgaben 6 bis 10:

1. Workstation im Basismodus öffnen.
2. Dasselbe Rezept dreimal hinzufügen.
3. Die Anzeige muss genau einen Stapel `Mehl mahlen x3` enthalten.
4. Einen anderen Rezepttyp hinzufügen und danach erneut Mehl wählen, sobald
   eine Station testweise mehrere Rezepte besitzt: Es bleiben zwei Zeilen und
   nur die Menge des vorhandenen Mehlauftrags steigt.
5. Den unteren Auftrag mit `Hoch` an die erste Position verschieben.
6. Das Fenster schließen und erneut öffnen: Die Priorität muss erhalten sein.
7. Den Abbrechen-Button eines Auftrags anklicken.
8. Genau dieser Auftrag muss vollständig verschwinden.

---

## Abgeschlossene Aufgaben 1 bis 5

## Aufgabe 1: Namen von ItemPickups anzeigen

Datei: `godot/scripts/items/item_pickup.gd`, Funktion `_update_label()`.

Ziel:

- Leere `item_id` zeigt `Unbekannte Ressource`.
- `&"stone"` zeigt `Stone`.
- `&"wheat_seed"` zeigt `Wheat Seed`.

Benötigte Bausteine:

- `if item_id.is_empty():`
- `String(item_id).capitalize()`
- `item_label.text = ...`

Test:

1. Spiel starten.
2. Das vorhandene Holz muss `Wood` anzeigen.
3. Der vorhandene Stein muss `Stone` anzeigen.

## Aufgabe 2: Schutthaufen erzeugt physische Steine

Datei: `godot/scripts/world/rubble_pile.gd`, Funktion `interact()`.

Halte dich genau an die sechs Schritte im TODO-Kommentar. Die wichtigsten
Regeln sind:

- Erst prüfen, dann erzeugen.
- Exportwerte vor `add_child()` auf das neue Pickup übertragen.
- Erst nach erfolgreichem Erzeugen `queue_free()` aufrufen.
- Die Belohnung geht nicht direkt ins Inventar.

Test:

1. In den Basismodus wechseln und den Bewohner auswählen.
2. Schutthaufen mit Rechtsklick beauftragen.
3. Bei Ankunft verschwindet der Schutthaufen.
4. Daneben erscheint `Stone` mit der Menge 3.
5. Das neue Pickup mit einem zweiten Rechtsklick einsammeln.

Wenn beim Spawn `Invalid set index` erscheint, prüfe, ob das Ergebnis von
`instantiate()` als `ItemPickup` typisiert oder gecastet wurde.

## Aufgabe 3: Rezept zur Station-Warteschlange hinzufügen

Datei: `godot/scripts/workstation/processing_station.gd`, Funktion
`enqueue_recipe()`.

Die Funktion verändert nur die Planung. Sie verbraucht keine Zutaten und
produziert keine Gegenstände. Nutze den ausführlichen TODO-Kommentar in der
Funktion.

Erwartete Rückgabewerte:

- `null` -> `false`
- stationsfremdes Rezept -> `false`
- verfügbares Rezept -> anhängen, Signal auslösen, `true`

## Aufgabe 4: Rezeptbutton mit der Station verbinden

Datei: `godot/scripts/ui/workstation_menu.gd`, Funktion
`_on_recipe_button_pressed()`.

Der Button bekommt sein Rezept bereits über `bind()`. Du musst nur prüfen, ob
eine Station geöffnet ist, und anschließend deren `enqueue_recipe()` aufrufen.
Das Signal der Station übernimmt die Aktualisierung der Anzeige.

## Aufgabe 5: Warteschlange im Fenster anzeigen

Datei: `godot/scripts/ui/workstation_menu.gd`, Funktion `_refresh_queue()`.

Diese erste Queue-Anzeige ist abgeschlossen und wird in den Aufgaben 6 bis 9
auf gestapelte `ProductionOrder`-Einträge mit eigenem Abbrechen-Button
umgestellt.

Test für Aufgaben 3 bis 5:

1. Mit `Tab` in den Basismodus wechseln.
2. Mühlstein, Dreschplatz oder Ofen mit Linksklick anklicken.
3. Das Fenster muss den Stationsnamen und einen Rezeptbutton zeigen.
4. Den Rezeptbutton anklicken.
5. Der Auftrag muss in der Warteschlange erscheinen.
6. Fenster über `Schließen` schließen und dieselbe Station erneut öffnen.
7. Der Auftrag muss noch vorhanden sein.

## Bewusst noch nicht Teil dieser Aufgaben

- Die Warteschlange wird noch nicht automatisch abgearbeitet.
- Es werden noch keine Materialien reserviert oder transportiert.
- Die Aufgaben 6 bis 10 ergänzen manuelle Prioritäten und eine feste
  Wiederholungsmenge. Modi wie `Unendlich` oder `Bis Bestand X` sind noch nicht
  enthalten.
- Der bisherige direkte Gebrauch einer Station mit `F` existiert vorläufig
  parallel weiter.

Diese Punkte folgen erst, nachdem Auswahl und Warteschlange zuverlässig
funktionieren.
