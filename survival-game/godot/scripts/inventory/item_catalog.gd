class_name ItemCatalog
extends Resource

## Ein gemeinsamer Katalog verhindert, dass Spieler, Kisten und Werkstationen
## dieselben Itemdaten jeweils separat definieren müssen.
@export var definitions: Array[ItemDefinition] = []


## Sucht eine gültige Definition anhand ihrer ID.
## Durchlaufe definitions, überspringe null und ungültige Einträge und gib den
## ersten Treffer zurück. Ohne Treffer wird null zurückgegeben.
func get_definition(item_id: StringName) -> ItemDefinition:
	for item in definitions:
		if item == null or not item.is_valid():
			continue
		if item.id == item_id:
			return item
	return null


## Prüft den gesamten Katalog.
## Ungültige Definitionen und doppelte IDs ergeben false. Verwende ein lokales
## Dictionary, um bereits gesehene IDs zu merken.
func is_valid() -> bool:
	var defs : Dictionary = {}
	for item in definitions:
		if item == null or not item.is_valid():
			return false
		if defs.has(item.id):
			return false
		defs.get_or_add(item.id)
	return true
