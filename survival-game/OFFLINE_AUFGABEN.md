# Offline-Aufgaben: Ressourcen und Produktionswarteschlange

Die Aufgaben 1 bis 5 sind abgeschlossen. Die aktuell offenen Aufgaben 6 bis 10
erweitern das Workstation-Menü um gestapelte, nach Priorität sortierbare und
einzeln abbrechbare Produktionsaufträge.
Starte nach jeder Aufgabe das Projekt und behebe Parserfehler, bevor du mit der
nächsten Aufgabe beginnst. Fertige TODO-Kommentare werden durch dauerhafte
Dokumentation ersetzt.

## Aktuell: Aufgabe 6 – Wiederholungen im vorhandenen Rezeptauftrag stapeln

Datei: `godot/scripts/workstation/processing_station.gd`, Funktion
`enqueue_recipe()`.

Jedes Rezept kommt höchstens einmal in der Liste vor. Ein erneuter Klick erhöht
nur `amount` dieses Auftrags. Seine Position und damit seine Priorität bleibt
unverändert.

## Danach: Aufgabe 7 – Auftrag anhand seiner ID entfernen

Datei: `godot/scripts/workstation/processing_station.gd`, Funktion
`remove_queued_order()`.

Jeder Auftrag besitzt eine ID. Suche diese ID und entferne genau den gefundenen
Eintrag, unabhängig davon, wo er in der Queue steht.

## Danach: Aufgabe 8 – Priorität eines Auftrags verschieben

Datei: `godot/scripts/workstation/processing_station.gd`, Funktion
`move_queued_order()`.

Verschiebe den gewählten Auftrag genau eine Position hoch oder herunter. Die
Array-Reihenfolge ist gleichzeitig die Ausführungspriorität: Index 0 kommt
immer zuerst, unabhängig von der Wiederholungsmenge.

## Danach: Aufgabe 9 – sichtbare Prioritätszeile bauen

Datei: `godot/scripts/ui/workstation_menu.gd`, Funktion `_create_queue_row()`.

Erzeuge pro ProductionOrder eine Zeile mit Position, Rezeptname, Menge sowie
Hoch-, Runter- und Abbrechen-Button. Der ausführliche TODO-Kommentar erklärt
auch, wie der oberste beziehungsweise unterste Verschiebebutton deaktiviert
wird.

## Danach: Aufgabe 10 – Buttons an die Station delegieren

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
