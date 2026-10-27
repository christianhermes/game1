class_name Inventory
extends Node

## Das Inventar speichert Gegenstände unabhängig von ihrer Darstellung.
## Dadurch können später beispielsweise Hotbar, Truhe und Inventarfenster
## dieselben Daten verwenden, ohne die Gegenstandslogik zu duplizieren.

# Ein Signal informiert interessierte Nodes darüber, dass sich eine Menge
# geändert hat. Die Hotbar verbindet sich mit diesem Signal.
signal inventory_changed(item_id: StringName, new_amount: int)

## TODO 56.1: Bereite das slotbasierte Inventar parallel zum bisherigen
## Dictionary vor, ohne die funktionierenden Systeme bereits umzustellen.
##
## Ergänze hier:
## - das Signal contents_changed ohne Parameter,
## - eine exportierte Referenz auf einen ItemCatalog,
## - eine exportierte slot_capacity mit dem Standardwert 20,
## - ein Array[InventoryStack] namens slots.
##
## Schreibe danach _ready():
## 1. Prüfe, dass der Katalog existiert und gültig ist.
## 2. Prüfe, dass slot_capacity größer als 0 ist.
## 3. Erzeuge genau slot_capacity neue InventoryStack-Instanzen.
## 4. Erzeuge jede Instanz einzeln mit InventoryStack.new(). Dieselbe Resource
##    darf niemals mehrfach im Array liegen, weil sich sonst mehrere Slots
##    gleichzeitig verändern würden.
##
## Lass items und die bestehenden Methoden zunächst unverändert. So bleiben
## Hotbar, Bauen, Farming und Werkstationen während dieses Schritts lauffähig.

# Das Dictionary ordnet jeder Gegenstands-ID ihre aktuelle Menge zu.
# Beispiel: { &"wheat_seed": 3, &"wheat": 1 }
var items: Dictionary = {}


## TODO 56.4: Stelle add_item erst um, nachdem 56.1 bis 56.3 geprüft wurden.
## Die Funktion soll dann int statt void zurückgeben. Der Rückgabewert ist die
## Menge, die wegen eines vollen Inventars NICHT eingelagert werden konnte.
##
## Reihenfolge:
## 1. Ungültige ID, unbekannte Definition oder amount <= 0 nicht einlagern.
## 2. Zuerst passende, noch nicht volle Stapel auffüllen.
## 3. Danach leere Slots einzeln mit neuen Stapeln belegen.
## 4. Die effektive Stapelgrenze der ItemDefinition niemals überschreiten.
## 5. Nur nach einer wirklichen Änderung contents_changed und inventory_changed
##    mit der neuen Gesamtmenge senden.
## 6. Die nicht eingelagerte Restmenge zurückgeben. 0 bedeutet voller Erfolg.
# Fügt die angegebene Menge eines Gegenstands hinzu.
func add_item(item_id: StringName, amount: int) -> void:
	var new_amount: int = get_amount(item_id) + amount
	items[item_id] = new_amount
	print("Du hast ", new_amount, "x ", item_id)

	# Erst nach der Änderung wird die neue Gesamtmenge gemeldet.
	inventory_changed.emit(item_id, new_amount)

## TODO 56.2: Stelle diese Abfragen auf slots um.
##
## get_amount(): Addiere amount aller nicht leeren Stapel mit passender item_id.
## get_used_slot_count(): Zähle alle Stapel, die nicht leer sind.
## get_total_item_count(): Addiere die Mengen aller nicht leeren Stapel.
## get_slots_snapshot(): Gib ein neues Array mit duplizierten Stapeln zurück.
## Das UI darf weder das echte slots-Array noch dessen Resources verändern.
# Liefert die aktuelle Gesamtmenge einer Item-ID.
func get_amount(item_id: StringName) -> int:
	return items.get(item_id, 0)


func get_used_slot_count() -> int:
	return 0


func get_total_item_count() -> int:
	return 0


func get_slots_snapshot() -> Array[InventoryStack]:
	return []


## TODO 56.3: Berechne, ob und wie viel von einem Item noch hineinpasst.
##
## get_add_capacity():
## 1. Hole die ItemDefinition aus dem Katalog. Ohne Definition ist das Ergebnis 0.
## 2. Addiere den freien Platz aller bereits passenden Stapel.
## 3. Addiere für jeden leeren Slot eine vollständige effektive Stapelgröße.
##
## can_add_item(): Liefere nur true, wenn amount positiv ist, die Definition
## existiert und get_add_capacity(item_id) mindestens amount beträgt.
func get_add_capacity(item_id: StringName) -> int:
	return 0


func can_add_item(item_id: StringName, amount: int) -> bool:
	return false


## TODO 56.6: Stelle remove_item erst nach add_item auf die Slots um.
## 1. Lehne amount <= 0 ab.
## 2. Prüfe vor jeder Änderung mit get_amount(), ob insgesamt genug vorhanden
##    ist. Die Entnahme soll vollständig gelingen oder gar nichts verändern.
## 3. Ziehe die Menge nacheinander von passenden Stapeln ab.
## 4. Rufe clear() auf jedem dadurch geleerten Stapel auf.
## 5. Sende beide Änderungssignale genau einmal und gib true zurück.
# Versucht, eine Menge zu entfernen, und meldet Erfolg oder Misserfolg zurück.
func remove_item(item_id: StringName, amount: int) -> bool:
	# Null und negative Mengen sind keine gültige Entnahme.
	if amount <= 0:
		return false

	var actual_amount: int = get_amount(item_id)
	if actual_amount >= amount:
		var new_amount: int = actual_amount - amount

		# Gegenstände mit Menge 0 müssen nicht im Dictionary gespeichert bleiben.
		if new_amount == 0:
			items.erase(item_id)
		else:
			items[item_id] = new_amount

		inventory_changed.emit(item_id, new_amount)
		return true

	# Es waren nicht genügend Gegenstände vorhanden.
	return false


## TODO 56.7: Abschluss im Godot-Editor und Funktionstest.
## - Weise beim Inventory-Kind des Players in main.tscn den gemeinsamen
##   ItemCatalog zu und setze slot_capacity auf 20.
## - Entferne das alte items-Dictionary erst, wenn alle Methoden mit slots laufen.
## - Prüfe: 100 Wood ergibt Stapel mit 99 und 1.
## - Prüfe: Zwei Hammer ergeben zwei Stapel mit jeweils 1.
## - Prüfe: Entfernen über Stapelgrenzen liefert die richtige Gesamtmenge.
## - Prüfe: Hotbar, Bauen, Pflanzen und Essen funktionieren weiterhin.


## TODO 58: Ergänze nach der Slot-Umstellung hier die verlustfreie Übertragung
## zwischen zwei Inventaren. Die Funktion soll die tatsächlich bewegte Menge
## zurückgeben und bei zu wenig Zielplatz niemals Gegenstände vernichten.
