class_name StorageContainer
extends FinishedBuilding

## Physischer Lagerbehälter mit einem eigenen Inventory-Kind. Jede Instanz der
## späteren Kistenszene besitzt dadurch wirklich unabhängige Bestände.
@export_range(0.5, 10.0, 0.1) var access_distance := 2.5
@onready var inventory := get_node_or_null("Inventory") as Inventory


## Gibt das eigene Kisteninventar an Lagerfenster und andere Systeme weiter.
func get_storage_inventory() -> Inventory:
	return inventory


## Erlaubt manuellen Zugriff nur, wenn der Bewohner horizontal nah genug an
## der Kiste steht. Höhenunterschiede durch Bodenplatten zählen dabei nicht.
func can_be_accessed_by(actor: Node3D) -> bool:
	if actor == null:
		return false

	var offset := actor.global_position - global_position
	offset.y = 0.0
	return offset.length() <= access_distance


## Ergänzt die Gebäudeinformation um die wichtigsten Lagerwerte.
func get_world_info_text() -> String:
	var building_info := super.get_world_info_text()
	if inventory == null:
		return building_info

	return "%s\nLagerplätze: %d/%d\nGegenstände: %d" % [
		building_info,
		inventory.get_used_slot_count(),
		inventory.slot_capacity,
		inventory.get_total_item_count(),
	]
