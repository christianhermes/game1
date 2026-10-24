# Datenfluss des aktuellen Spiel-Prototyps

Diese Datei erklärt, **wo die Daten im aktuellen Projekt entstehen, wem sie
gehören und wie sie zwischen den Nodes weitergegeben werden**.

Sie beschreibt bewusst nur den tatsächlich vorhandenen Stand. Geplante
Systeme wie Crafting, Speichern oder NPCs sind hier noch nicht enthalten.

---

## 1. Das wichtigste Gesamtbild

```text
main.tscn
│
├── Main (main.gd)
│   ├── kennt Camera3D
│   └── kennt Player
│
├── Player (player.gd)
│   ├── kennt seine InteractionArea
│   ├── kennt sein Inventory
│   └── merkt sich die ausgewählte item_id
│
├── Player/Inventory (inventory.gd)
│   ├── besitzt die tatsächlichen Gegenstandsmengen
│   └── sendet inventory_changed
│
├── UI/Hotbar (hotbar.gd)
│   ├── bekommt das Inventory im Editor zugewiesen
│   ├── zeigt dessen Gegenstände an
│   └── sendet selected_item_changed an den Player
│
├── FarmPlot (farm_plot.gd)
│   ├── besitzt seinen aktuellen Feldzustand
│   └── bekommt wheat.tres als CropData zugewiesen
│
└── ItemPickups (item_pickup.gd)
    └── besitzen jeweils item_id und amount
```

Der wichtigste Grundsatz lautet:

> Ein Wert sollte eine klare Hauptquelle besitzen. Andere Systeme bekommen
> Änderungen gemeldet oder fragen diese Quelle gezielt ab.

Beispiel: Die Hotbar zeigt Gegenstände an, aber die echten Mengen gehören dem
`Inventory`. Dadurch gibt es nicht zwei unabhängig voneinander gepflegte
Mengen, die sich widersprechen könnten.

---

## 2. Drei Arten von Daten im Projekt

### 2.1 Konfigurationsdaten

Diese Werte werden vor dem Spielen festgelegt und ändern sich normalerweise
nicht während einer Runde.

| Datum | Eigentümer | Beispiel |
|---|---|---|
| Pflanzeneigenschaften | `wheat.tres` / `CropData` | Saatgut-ID, Wachstumszeit, Erntemenge |
| Pickup-Inhalt | jeweiliger `ItemPickup` | `wood`, `stone`, Menge `1` |
| Kameraabstand | `main.gd` | `CAMERA_OFFSET` |
| Spielergeschwindigkeit | `player.gd` | `SPEED` |

`@export` macht eine Variable im Godot-Inspektor einstellbar. Der Wert kann
dadurch aus einer Szene oder Resource kommen, obwohl die Variable im Skript
definiert wurde.

### 2.2 Laufzeitdaten

Diese Werte verändern sich während des Spiels.

| Datum | Eigentümer | Beispiel |
|---|---|---|
| Gegenstandsmengen | `Inventory.items` | `{ wheat_seed: 3, wood: 1 }` |
| ausgewählter Slot | `Hotbar.selected_index` | `0` |
| Gegenstand pro Slot | `Hotbar.slot_item_ids` | `[wheat_seed, wood, stone, ...]` |
| ausgewähltes Item | `Player.selected_item_id` | `wheat_seed` |
| Feldzustand | `FarmPlot.state` | `EMPTY`, `GROWING`, `READY` |
| verbleibende Wachstumszeit | `GrowthTimer` | zum Beispiel `3.4` Sekunden |

Diese Daten existieren momentan nur im Arbeitsspeicher. Beim Beenden des
Spiels werden sie noch nicht gespeichert.

### 2.3 Darstellungsdaten

Diese Werte zeigen den Laufzeitstand für den Spieler an, sind aber nicht die
eigentliche Datenquelle.

Beispiele:

- Der Text eines Hotbar-Buttons zeigt Itemname und Menge.
- `StateLabel` zeigt `Leer`, `Wächst` oder `Erntereif`.
- `CropVisual.visible` bestimmt, ob die Pflanze sichtbar ist.
- `crop_material.albedo_color` zeigt Wachstums- oder Reifezustand.

Wenn die Hotbar `3x` anzeigt, bedeutet das also nicht, dass der Button die
Menge besitzt. Der Button stellt nur den Wert aus dem Inventar dar.

---

## 3. Verbindungen, die im Godot-Editor gespeichert sind

Nicht jede Verbindung steht sichtbar in einem Skript. Einige befinden sich in
[`main.tscn`](main.tscn).

### Hotbar bekommt das Inventar

```text
UI/Hotbar.inventory
        │
        └──> Player/Inventory
```

In der Szene steht dafür sinngemäß:

```text
inventory = NodePath("../../Player/Inventory")
```

Deshalb kann `hotbar.gd` später dieses Signal verbinden:

```gdscript
inventory.inventory_changed.connect(_on_inventory_changed)
```

### Hotbar meldet die Auswahl an den Player

```text
Hotbar.selected_item_changed
        │
        └──> Player._on_hotbar_selected_item_changed(...)
```

Diese Signalverbindung wurde ebenfalls in `main.tscn` gespeichert. Deshalb
muss sie nicht noch einmal per Code hergestellt werden.

### FarmPlot bekommt die Weizendaten

```text
FarmPlot.crop_data
        │
        └──> data/crops/wheat.tres
```

`wheat.tres` enthält aktuell:

```text
id             = wheat
display_name   = Weizen
seed_item_id   = wheat_seed
```

Nicht ausdrücklich gesetzte Werte kommen aus den Standardwerten in
`crop_data.gd`:

```text
growth_seconds = 5.0
harvest_amount = 1
planted_color  = grün
ready_color    = gelb
```

---

## 4. Ablauf beim Spielstart

### Schritt 1: Godot lädt `main.tscn`

Godot erzeugt alle Nodes aus der Szene, darunter Player, Inventory, FarmPlot,
Hotbar und die Pickups. Referenzen aus dem Inspektor und Signalverbindungen
aus der Szene werden dabei hergestellt.

### Schritt 2: Die einzelnen Nodes führen `_ready()` aus

Wichtige Vorbereitungen:

- Das FarmPlot tritt der Gruppe `interactable` bei.
- Das FarmPlot verbindet `GrowthTimer.timeout` mit
  `_on_growth_finished()`.
- Die Hotbar sammelt ihre neun Button-Kinder ein.
- Die Hotbar verbindet die Buttons mit `select_slots(index)`.
- Die Hotbar verbindet sich mit `Inventory.inventory_changed`.
- Die Pickups treten ebenfalls der Gruppe `interactable` bei.

### Schritt 3: `Main._ready()` gibt das Start-Saatgut aus

```text
Main._ready()
    │
    └──> Player.receive_item(wheat_seed, 3)
              │
              └──> Inventory.add_item(wheat_seed, 3)
```

Das Inventar berechnet:

```text
alte Menge 0 + neue Menge 3 = Gesamtmenge 3
```

Danach enthält das Dictionary:

```text
items = { wheat_seed: 3 }
```

### Schritt 4: Das Inventar meldet die Änderung

```text
Inventory
    │
    │ inventory_changed(wheat_seed, 3)
    ▼
Hotbar._on_inventory_changed(wheat_seed, 3)
```

Die Hotbar findet noch keinen Slot mit `wheat_seed`, sucht deshalb den ersten
freien Slot und trägt dort die ID ein:

```text
slot_item_ids = [wheat_seed, leer, leer, leer, ...]
```

Der Buttontext wird zu:

```text
Wheat Seed
3x
```

### Schritt 5: Die Hotbar meldet die aktive Auswahl

Weil der erste Slot ausgewählt ist, sendet die Hotbar:

```text
selected_item_changed(wheat_seed)
```

Der Player empfängt dieses Signal und speichert:

```text
selected_item_id = wheat_seed
```

Damit kennt der Player seine Auswahl, ohne selbst Hotbar-Buttons untersuchen
zu müssen.

---

## 5. Ablauf einer Hotbar-Auswahl

### Eingabe

Das Mausrad oder eine Zahlentaste erzeugt ein `InputEvent`. `hotbar.gd`
wandelt dieses Ereignis in einen Slot-Index um.

```text
Mausrad / Zahlentaste
        │
        ▼
Hotbar._input(event)
        │
        ▼
Hotbar.select_slots(index)
```

### Auswahl und Signal

`select_slots()` führt drei Aufgaben aus:

1. `selected_index` erhält den neuen Index.
2. Genau der passende Button wird als gedrückt dargestellt.
3. Die `item_id` dieses Slots wird als Signal gesendet.

```text
slot_item_ids[selected_index]
        │
        ▼
selected_item_changed(item_id)
        │
        ▼
Player.selected_item_id
```

Ein leerer Slot sendet eine leere ID `&""`. Der Player hat dann keinen
benutzbaren Gegenstand ausgewählt.

---

## 6. Gemeinsamer Ablauf jeder Interaktion

Wenn der Spieler `F` drückt, wird nicht direkt ein Feld oder Pickup
angesprochen. Der Player sucht zuerst ein geeignetes Objekt.

```text
F-Taste
   │
   ▼
Player._physics_process()
   │
   ▼
Player._try_interact()
   │
   ├── fragt überlappende Areas aus InteractionArea ab
   ├── behält nur Mitglieder der Gruppe "interactable"
   ├── behält nur Objekte mit einer interact()-Methode
   ├── sucht davon das nächstgelegene Objekt
   │
   ▼
gefundenes_objekt.interact(Player)
```

Der Player übergibt `self`. Das Weltobjekt erhält dadurch den Player als
`actor` und kann ihm einen Gegenstand geben oder ihn um einen Gegenstand
bitten.

Dieser gemeinsame Ablauf ermöglicht verschiedene Interaktionen, ohne dass
`player.gd` jede Objektart einzeln kennen muss.

---

## 7. Ablauf beim Aufheben eines Gegenstands

Beispiel: Der Spieler interagiert mit dem Holz-Pickup.

```text
Player._try_interact()
        │
        ▼
ItemPickup.interact(Player)
        │
        ▼
Player.receive_item(wood, 1)
        │
        ▼
Inventory.add_item(wood, 1)
        │
        ├──> items[wood] wird geändert
        │
        └──> inventory_changed(wood, neue_menge)
                        │
                        ▼
                 Hotbar aktualisiert Slot
```

Erst nachdem `receive_item()` aufgerufen wurde, entfernt sich das Pickup mit
`queue_free()` aus der Welt.

Die Verantwortung ist dabei aufgeteilt:

- `ItemPickup` weiß, **was** und **wie viel** aufgehoben wird.
- `Player` bietet einen gemeinsamen Eingang für erhaltene Items.
- `Inventory` besitzt und verändert die Menge.
- `Hotbar` stellt die neue Menge dar.

---

## 8. Ablauf beim Pflanzen

Voraussetzungen:

- Das Feld ist `EMPTY`.
- Der Player hat `wheat_seed` ausgewählt.
- Das Inventar enthält mindestens ein `wheat_seed`.

### Vollständiger Aufrufweg

```text
F-Taste
  │
  ▼
Player._try_interact()
  │
  ▼
FarmPlot.interact(Player)
  │ state == EMPTY
  ▼
FarmPlot._plant(Player)
  │
  ├── liest crop_data.seed_item_id
  │              Ergebnis: wheat_seed
  │
  ▼
Player.try_use_selected_item(wheat_seed, 1)
  │
  ├── vergleicht Player.selected_item_id mit wheat_seed
  │
  ▼
Inventory.remove_item(wheat_seed, 1)
  │
  ├── prüft die vorhandene Menge
  ├── zieht 1 ab
  └── sendet inventory_changed(wheat_seed, neue_menge)
```

Nur wenn `remove_item()` erfolgreich `true` liefert, macht das Feld weiter:

```text
FarmPlot.state = GROWING
GrowthTimer.start(crop_data.growth_seconds)
FarmPlot._update_visuals()
```

Dadurch wird das Pflanzen als eine kleine Transaktion behandelt:

```text
passendes Saatgut ausgewählt UND vorhanden
                    │
          ┌─────────┴─────────┐
          │                   │
         ja                  nein
          │                   │
 Saatgut verbrauchen      nichts verändern
 Wachstum starten         Hinweis anzeigen
```

### Änderung der Hotbar nach dem Verbrauch

Auch `remove_item()` sendet `inventory_changed`.

Bei einer Restmenge größer als null aktualisiert die Hotbar nur den Text. Bei
einer Restmenge von null passiert zusätzlich Folgendes:

1. Das Inventory entfernt die ID aus seinem Dictionary.
2. Die Hotbar leert den zugehörigen Slot.
3. War dieser Slot ausgewählt, sendet die Hotbar die leere ID.
4. `Player.selected_item_id` wird dadurch ebenfalls leer.

---

## 9. Ablauf während des Wachstums

Der `GrowthTimer` besitzt die verbleibende Zeit. Das FarmPlot fragt diese in
jedem Bild ab, solange sein Zustand `GROWING` ist:

```text
GrowthTimer.time_left
        │
        ▼
FarmPlot._process()
        │
        ▼
StateLabel.text = "Wächst\n... s"
```

Wenn der Timer abläuft, sendet Godot sein eingebautes `timeout`-Signal:

```text
GrowthTimer.timeout
        │
        ▼
FarmPlot._on_growth_finished()
        │
        ├── state = READY
        └── _update_visuals()
```

Das Feld wird gelb und zeigt `Erntereif` an.

Wird während des Wachstums erneut `F` gedrückt, bleibt der Zustand
unverändert. Es wird nur `Das Feld wächst noch.` ausgegeben.

---

## 10. Ablauf beim Ernten

Wenn das Feld `READY` ist, führt die nächste Interaktion zu `_harvest()`:

```text
FarmPlot._harvest(Player)
        │
        ├── liest crop_data.id             -> wheat
        ├── liest crop_data.harvest_amount -> 1
        │
        ▼
Player.receive_item(wheat, 1)
        │
        ▼
Inventory.add_item(wheat, 1)
        │
        ├──> Inventory.items wird geändert
        └──> inventory_changed(wheat, 1)
                         │
                         ▼
                  Hotbar zeigt Weizen
```

Danach setzt das FarmPlot sich selbst zurück:

```text
state = EMPTY
CropVisual wird unsichtbar
StateLabel zeigt "Leer / F: Pflanzen"
```

Wichtig: Bei der Ernte entsteht aktuell nur `wheat`. Neues `wheat_seed` wird
noch nicht erzeugt. Die später geplante Verarbeitung von Weizen zu Stroh und
Weizenkörnern ist noch kein Teil dieses Datenflusses.

---

## 11. Methodenaufruf oder Signal?

Im Projekt werden beide Wege bewusst für unterschiedliche Situationen benutzt.

### Direkter Methodenaufruf

```gdscript
inventory.add_item(item_id, amount)
```

Ein direkter Aufruf eignet sich, wenn ein System gezielt von einem anderen
System eine Aktion verlangt und häufig sofort ein Ergebnis benötigt.

Beispiele:

- Player bittet Inventory, ein Item hinzuzufügen.
- FarmPlot bittet Player, ein ausgewähltes Saatgut zu benutzen.
- Player ruft `interact(self)` am gefundenen Weltobjekt auf.

### Signal

```gdscript
inventory_changed.emit(item_id, new_amount)
```

Ein Signal eignet sich als Mitteilung: Etwas ist bereits passiert, und andere
Systeme dürfen darauf reagieren.

Beispiele:

- Inventory meldet eine geänderte Menge an die Hotbar.
- Hotbar meldet eine geänderte Auswahl an den Player.
- GrowthTimer meldet, dass seine Zeit abgelaufen ist.

Als Merksatz:

```text
Methodenaufruf: "Bitte führe diese Aktion aus."
Signal:         "Dieses Ereignis ist gerade passiert."
```

---

## 12. Wer darf welchen Wert ändern?

| Wert | Hauptverantwortlicher | Andere Systeme |
|---|---|---|
| `Inventory.items` | Inventory | dürfen über Methoden hinzufügen, entfernen oder abfragen |
| `FarmPlot.state` | FarmPlot | reagieren nur durch `interact()` auf das Feld |
| `Player.selected_item_id` | Player | Hotbar meldet nur die neue Auswahl |
| `Hotbar.selected_index` | Hotbar | Eingaben lösen eine Änderung aus |
| `CropData` | Resource-Datei | FarmPlot liest die Werte |
| Buttontexte | Hotbar | werden aus Inventaränderungen abgeleitet |
| Pflanzenmodell und Farbe | FarmPlot | werden aus dem Feldzustand abgeleitet |

Diese Aufteilung verhindert, dass beispielsweise FarmPlot, Hotbar und Player
alle selbst die Inventarmenge verändern.

---

## 13. Wichtige Godot-Begriffe in diesem Projekt

### Node

Ein Baustein in einer Szene. Beispiele sind `Player`, `Inventory`, `Hotbar`
und `GrowthTimer`.

### Scene

Eine gespeicherte Zusammenstellung von Nodes. `main.tscn` ist die Spielwelt;
`farm_plot.tscn` und `item_pickup.tscn` sind wiederverwendbare Teilszenen.

### Resource

Ein Datenobjekt ohne eigene Position in der Spielwelt. `wheat.tres` beschreibt
die Werte der Pflanze Weizen.

### `@onready`

Die Variable wird befüllt, sobald der Node und seine Kinder in der Szene bereit
sind. `$Inventory` ist eine Kurzform für den Pfad zum Kind-Node `Inventory`.

### `@export`

Die Variable erscheint im Inspektor. Dadurch kann eine Szene oder Resource
einen Wert festlegen, ohne das Skript zu verändern.

### Gruppe

Ein frei wählbares Etikett für Nodes. `interactable` sagt dem Player, welche
Areas grundsätzlich für eine Interaktion infrage kommen.

### Signal

Eine Nachricht über ein Ereignis. Sender und Empfänger müssen dadurch weniger
voneinander wissen.

### `StringName`

Der Typ der IDs wie `&"wheat_seed"`. Dieselbe ID muss überall exakt gleich
geschrieben sein, damit Vergleiche und Suchen funktionieren.

---

## 14. Aktuelle Grenzen des Systems

Diese Punkte sind keine unmittelbaren Fehler, sondern der aktuelle Umfang des
Prototyps:

- Inventar und Feldzustand werden noch nicht gespeichert.
- Die Hotbar hat neun Plätze und kann höchstens neun verschiedene Item-IDs
  gleichzeitig anzeigen.
- Es gibt noch keine allgemeine Item-Datenbank mit deutschen Anzeigenamen und
  Icons. Deshalb erzeugt die Hotbar Namen momentan direkt aus der ID.
- Das Stein-Pickup verwendet dieselbe Pickup-Szene wie Holz. Der Text des
  `Label3D` ist in dieser Basisszene noch fest auf `Holz` gesetzt und wird nicht
  automatisch aus `item_id` erzeugt.
- Geernteter Weizen wird noch nicht in Stroh und Weizenkörner verarbeitet.
- `CropData` beschreibt bisher eine Pflanzenart, während jedes FarmPlot genau
  eine fest zugewiesene Pflanzenart verwendet.

Diese Grenzen zeigen zugleich sinnvolle spätere Erweiterungspunkte. Sie müssen
aber nicht alle gleichzeitig gelöst werden.

---

## 15. Kurze Anleitung zum Nachverfolgen eines Fehlers

Wenn etwas nicht funktioniert, verfolge die Daten in dieser Reihenfolge:

### Ein Item erscheint nicht

```text
Wurde receive_item() aufgerufen?
        ↓
Hat Inventory.items die richtige Menge?
        ↓
Wurde inventory_changed gesendet?
        ↓
Ist Hotbar.inventory im Inspektor zugewiesen?
        ↓
Hat die Hotbar noch einen freien Slot?
```

### Pflanzen funktioniert nicht

```text
Ist das FarmPlot in Reichweite?
        ↓
Ist es in der Gruppe interactable?
        ↓
Ist state wirklich EMPTY?
        ↓
Ist wheat_seed in der Hotbar ausgewählt?
        ↓
Enthält Inventory mindestens ein wheat_seed?
        ↓
Stimmt crop_data.seed_item_id exakt mit wheat_seed überein?
```

### Die Auswahl kommt nicht beim Player an

```text
Ändert Hotbar.selected_index sich?
        ↓
Enthält der Slot eine item_id?
        ↓
Wird selected_item_changed gesendet?
        ↓
Existiert die Signalverbindung in main.tscn?
        ↓
Ändert sich Player.selected_item_id?
```

---

## 16. Die wichtigsten Quelldateien

- [`scripts/main.gd`](scripts/main.gd): Spielstart und Kamera
- [`scripts/player.gd`](scripts/player.gd): Bewegung und Interaktionsvermittlung
- [`scripts/inventory/inventory.gd`](scripts/inventory/inventory.gd): echte Itemmengen
- [`scripts/ui/hotbar.gd`](scripts/ui/hotbar.gd): Darstellung und Auswahl
- [`scripts/items/item_pickup.gd`](scripts/items/item_pickup.gd): Items aus der Welt aufnehmen
- [`scripts/farming/farm_plot.gd`](scripts/farming/farm_plot.gd): Feldzustand und Farmingablauf
- [`scripts/farming/crop_data.gd`](scripts/farming/crop_data.gd): Aufbau von Pflanzendaten
- [`data/crops/wheat.tres`](data/crops/wheat.tres): konkrete Weizenwerte
- [`main.tscn`](main.tscn): Node-Aufbau und Editor-Verbindungen

Wenn du einen Ablauf verstehen möchtest, beginne am besten mit einem sichtbaren
Ereignis wie `F drücken` und folge den Pfeilen in dieser Datei von Methode zu
Methode. So wird aus vielen einzelnen Skripten ein zusammenhängendes System.
