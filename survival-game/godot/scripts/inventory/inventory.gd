class_name Inventory
extends Node

## Das Inventar speichert Gegenstände unabhängig von ihrer Darstellung.
## Dadurch können später beispielsweise Hotbar, Truhe und Inventarfenster
## dieselben Daten verwenden, ohne die Gegenstandslogik zu duplizieren.

# Ein Signal informiert interessierte Nodes darüber, dass sich eine Menge
# geändert hat. Die Hotbar verbindet sich mit diesem Signal.
signal inventory_changed(item_id: StringName, new_amount: int)

# Das Dictionary ordnet jeder Gegenstands-ID ihre aktuelle Menge zu.
# Beispiel: { &"wheat_seed": 3, &"wheat": 1 }
var items: Dictionary = {}


# Fügt die angegebene Menge eines Gegenstands hinzu.
func add_item(item_id: StringName, amount: int) -> void:
	var new_amount: int = get_amount(item_id) + amount
	items[item_id] = new_amount
	print("Du hast ", new_amount, "x ", item_id)

	# Erst nach der Änderung wird die neue Gesamtmenge gemeldet.
	inventory_changed.emit(item_id, new_amount)


# Liefert die aktuelle Menge. Für unbekannte IDs liefert get() den Wert 0.
func get_amount(item_id: StringName) -> int:
	return items.get(item_id, 0)


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
