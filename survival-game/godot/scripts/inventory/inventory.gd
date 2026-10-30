class_name Inventory
extends Node

## Das Inventar speichert Gegenstände unabhängig von ihrer Darstellung.
## Dadurch können später beispielsweise Hotbar, Truhe und Inventarfenster
## dieselben Daten verwenden, ohne die Gegenstandslogik zu duplizieren.

# Ein Signal informiert interessierte Nodes darüber, dass sich eine Menge
# geändert hat. Die Hotbar verbindet sich mit diesem Signal.
signal inventory_changed(item_id: StringName, new_amount: int)
signal contents_changed()
@export var item_catalog: ItemCatalog
@export var slot_capacity: int = 20
var slots: Array[InventoryStack] = []


## Erzeugt für jeden Inventarplatz eine unabhängige Stapel-Resource.
func _ready() -> void:
	if not item_catalog or not item_catalog.is_valid():
		return
	if slot_capacity <= 0:
		return
	for _index in range(slot_capacity):
		var stack = InventoryStack.new()
		slots.append(stack)


## Lagert zuerst in passende Stapel und danach in freie Slots ein.
## Der Rückgabewert ist die Menge, die keinen Platz mehr gefunden hat.
func add_item(item_id: StringName, amount: int) -> int:
	if amount <= 0 or item_catalog == null:
		return amount

	var definition := item_catalog.get_definition(item_id)
	if definition == null:
		return amount

	var remaining_amount := _add_to_slots(slots, definition, amount)

	# Interessierte Systeme werden nur bei einer tatsächlichen Änderung informiert.
	if remaining_amount < amount:
		var new_amount := get_amount(item_id)
		print("Du hast ", new_amount, "x ", item_id)
		contents_changed.emit()
		inventory_changed.emit(item_id, new_amount)

	return remaining_amount


## Füllt ein frei wählbares Slot-Array, ohne Signale zu senden. Dadurch kann
## dieselbe Stapellogik für echte Einlagerungen und sichere Vorschauen dienen.
func _add_to_slots(
	target_slots: Array[InventoryStack],
	definition: ItemDefinition,
	amount: int,
) -> int:
	var remaining_amount := amount
	var transfer_amount := 0

	# Bereits vorhandene Stapel werden zuerst aufgefüllt.
	for stack in target_slots:
		if remaining_amount == 0:
			break
		if stack == null or stack.is_empty():
			continue

		transfer_amount = mini(stack.get_free_space(definition), remaining_amount)
		if transfer_amount <= 0:
			continue

		stack.amount += transfer_amount
		remaining_amount -= transfer_amount

	# Die verbleibende Menge wird auf neue Stapel in leeren Slots verteilt.
	var max_stack_size := definition.get_effective_max_stack_size()
	for stack in target_slots:
		if remaining_amount == 0:
			break
		if stack == null or not stack.is_empty():
			continue

		transfer_amount = mini(max_stack_size, remaining_amount)
		stack.item_id = definition.id
		stack.amount = transfer_amount
		remaining_amount -= transfer_amount

	return remaining_amount

# Liefert die aktuelle Gesamtmenge einer Item-ID.
func get_amount(item_id: StringName) -> int:
	var count := 0
	for slot in slots:
		if slot == null or slot.is_empty():
			continue
		if slot.item_id == item_id:
			count += slot.amount
	return count


## Liefert die Anzahl der nicht leeren Inventarplätze.
func get_used_slot_count() -> int:
	var count := 0
	for slot in slots:
		if slot != null and not slot.is_empty():
			count += 1
	return count


## Liefert die Anzahl aller Gegenstände über sämtliche Stapel hinweg.
func get_total_item_count() -> int:
	var count := 0
	for slot in slots:
		if slot != null and not slot.is_empty():
			count += slot.amount
	return count


## Liefert unabhängige Stapelkopien, damit das UI das Inventar nicht verändert.
func get_slots_snapshot() -> Array[InventoryStack]:
	var snapshot: Array[InventoryStack] = []
	for slot in slots:
		if slot == null:
			snapshot.append(null)
		else:
			snapshot.append(slot.duplicate(true) as InventoryStack)
	return snapshot


## Berechnet den gesamten freien Platz für eine bestimmte Item-ID.
func get_add_capacity(item_id: StringName) -> int:
	if item_catalog == null:
		return 0

	var definition := item_catalog.get_definition(item_id)
	if definition == null:
		return 0

	var capacity := 0
	var max_stack_size := definition.get_effective_max_stack_size()
	for stack in slots:
		if stack == null:
			continue
		if stack.is_empty():
			capacity += max_stack_size
		else:
			capacity += stack.get_free_space(definition)
	return capacity


## Prüft, ob eine positive Menge vollständig eingelagert werden kann.
func can_add_item(item_id: StringName, amount: int) -> bool:
	if amount <= 0 or item_catalog == null:
		return false
	if item_catalog.get_definition(item_id) == null:
		return false
	return get_add_capacity(item_id) >= amount


## Prüft mehrere Outputs gemeinsam auf kopierten Slots. So können verschiedene
## Itemarten nicht irrtümlich denselben letzten freien Slot reservieren.
func can_add_items(item_amounts: Array[ItemAmount]) -> bool:
	if item_catalog == null:
		return false

	var simulated_slots := get_slots_snapshot()
	for item_amount in item_amounts:
		if item_amount == null or item_amount.amount <= 0:
			return false

		var definition := item_catalog.get_definition(item_amount.item_id)
		if definition == null:
			return false
		if _add_to_slots(simulated_slots, definition, item_amount.amount) > 0:
			return false

	return true


## Entfernt eine Menge vollständig oder lässt das Inventar unverändert.
func remove_item(item_id: StringName, amount: int) -> bool:
	if amount <= 0 or get_amount(item_id) < amount:
		return false

	var remaining_amount := amount
	for stack in slots:
		if remaining_amount == 0:
			break
		if stack == null or stack.is_empty() or stack.item_id != item_id:
			continue

		var removed_amount := mini(stack.amount, remaining_amount)
		stack.amount -= removed_amount
		remaining_amount -= removed_amount
		if stack.amount == 0:
			stack.clear()

	contents_changed.emit()
	inventory_changed.emit(item_id, get_amount(item_id))
	return true


## Verschiebt bis zur Wunschmenge in ein anderes Inventar und gibt die wirklich
## eingelagerte Menge zurück. Unerwartete Zielreste werden sofort zurückgebucht.
func transfer_to(
	target: Inventory,
	item_id: StringName,
	requested_amount: int,
) -> int:
	if target == null or target == self:
		return 0
	if item_id.is_empty() or requested_amount <= 0:
		return 0

	var transfer_amount := mini(
		requested_amount,
		mini(get_amount(item_id), target.get_add_capacity(item_id)),
	)
	if transfer_amount <= 0:
		return 0
	if not remove_item(item_id, transfer_amount):
		return 0

	var target_remainder := target.add_item(item_id, transfer_amount)
	var moved_amount := transfer_amount - target_remainder
	if target_remainder > 0:
		var source_remainder := add_item(item_id, target_remainder)
		if source_remainder > 0:
			push_error("Inventartransfer konnte einen Rest nicht zurückbuchen.")

	return moved_amount


## Verschiebt ausschließlich aus dem angegebenen Quellslot. Diese Variante ist
## für manuelle Inventarfenster gedacht, in denen der Spieler einen konkreten
## sichtbaren Stapel anklickt. Der Rückgabewert ist die wirklich bewegte Menge.
func transfer_slot_to(
	target: Inventory,
	source_slot_index: int,
	requested_amount: int,
) -> int:
	if target == null or target == self or requested_amount <= 0:
		return 0
	if source_slot_index < 0 or source_slot_index >= slots.size():
		return 0

	var source_stack := slots[source_slot_index]
	if source_stack == null or source_stack.is_empty():
		return 0

	var item_id := source_stack.item_id
	var transfer_amount := mini(
		requested_amount,
		mini(source_stack.amount, target.get_add_capacity(item_id)),
	)
	if transfer_amount <= 0:
		return 0

	# Die Menge wird zunächst aus genau dem gewählten Slot reserviert. Sollte das
	# Ziel wider Erwarten einen Rest ablehnen, landet er wieder in diesem Slot.
	source_stack.amount -= transfer_amount
	var target_remainder := target.add_item(item_id, transfer_amount)
	source_stack.amount += target_remainder

	var moved_amount := transfer_amount - target_remainder
	if moved_amount <= 0:
		return 0
	if source_stack.amount == 0:
		source_stack.clear()

	contents_changed.emit()
	inventory_changed.emit(item_id, get_amount(item_id))
	return moved_amount
