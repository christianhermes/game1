class_name InventoryStack
extends Resource

## Ein Stapel speichert nur ID und Menge. Name, Typ und Stapelgrenze kommen aus
## dem gemeinsamen ItemCatalog und werden dadurch nicht pro Slot dupliziert.
@export var item_id: StringName = &""
@export_range(0, ItemDefinition.DEFAULT_MAX_STACK_SIZE, 1) var amount := 0


## Ein Stapel ist leer, wenn seine ID leer oder seine Menge kleiner
## oder gleich 0 ist.
func is_empty() -> bool:
	if item_id.is_empty() or amount <= 0:
		return true
	return false


## Setzt ID und Menge auf ihre leeren Ausgangswerte zurück.
func clear() -> void:
	item_id = &""
	amount = 0


## Liefert den freien Platz dieses Stapels für die übergebene
## Definition. Eine andere Item-ID oder eine ungültige Definition ergibt 0.
func get_free_space(definition: ItemDefinition) -> int:
	if definition == null or not definition.is_valid():
		return 0
	if item_id != definition.id:
		return 0
	var space = definition.get_effective_max_stack_size()
	return clampi(space - amount, 0, space)
