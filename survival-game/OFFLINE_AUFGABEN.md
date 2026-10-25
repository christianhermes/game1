# Offline-Aufgaben: Vollständiger zeitgesteuerter Bauauftrag

## Aktueller Meilenstein: Ein Auftrag baut eine Holzmauer vollständig

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

### Implementiert, manuell zu testen: Aufgabe 22 – BUILD-Auftrag abwarten und korrekt abschließen

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
