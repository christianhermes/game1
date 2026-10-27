class_name ItemDefinition
extends Resource

## Beschreibt eine Gegenstandsart unabhängig von einem konkreten Inventarstapel.
## Echte erlernte Zauber gehören später in ein Fähigkeitssystem. MAGIC_ITEM ist
## für physische magische Gegenstände wie Schriftrollen, Runen oder Kristalle.
enum ItemType {
	MATERIAL,
	CONSUMABLE,
	TOOL,
	EQUIPMENT,
	MAGIC_ITEM,
	QUEST_ITEM,
}

const DEFAULT_MAX_STACK_SIZE := 99

@export var id: StringName = &""
@export var display_name := ""
@export var item_type := ItemType.MATERIAL
@export_range(1, DEFAULT_MAX_STACK_SIZE, 1) var max_stack_size := DEFAULT_MAX_STACK_SIZE


## Liefert die tatsächlich erlaubte Stapelgröße.
##
## Regeln:
## - TOOL liefert immer 1, unabhängig vom Inspectorwert.
## - Alle anderen Typen verwenden max_stack_size.
## - clampi() hält den Wert sicher zwischen 1 und DEFAULT_MAX_STACK_SIZE.
func get_effective_max_stack_size() -> int:
	if item_type == ItemType.TOOL:
		return 1
	return clampi(max_stack_size, 1, DEFAULT_MAX_STACK_SIZE)


## Eine Definition ist nur gültig, wenn ID und Anzeigename nicht leer
## sind und die effektive Stapelgröße mindestens 1 beträgt.
func is_valid() -> bool:
	if id.is_empty() or display_name.is_empty():
		return false
	if get_effective_max_stack_size() < 1:
		return false
	return true
