class_name StorageContainer
extends FinishedBuilding

## Physischer Lagerbehälter mit einem eigenen Inventory-Kind. Jede Instanz der
## späteren Kistenszene besitzt dadurch wirklich unabhängige Bestände.
@onready var inventory := get_node_or_null("Inventory") as Inventory


## TODO 59.1: Gib das Kisteninventar zurück. Die null-Prüfung bleibt Aufgabe des
## aufrufenden Menüs, damit eine fehlerhafte Szene keine Gegenstände verschluckt.
func get_storage_inventory() -> Inventory:
	return null


## TODO 59.2: Ergänze die normale Gebäudeinformation um belegte Slots,
## Gesamtkapazität und Gesamtmenge. Verwende dafür nur öffentliche Methoden des
## Inventory und greife nicht direkt auf dessen internes Slot-Array zu.
func get_world_info_text() -> String:
	return super.get_world_info_text()
