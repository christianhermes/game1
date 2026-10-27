class_name StorageMenu
extends PanelContainer

## Das Lagerfenster zeigt Spieler und Kiste nebeneinander. Es delegiert jede
## Mengenänderung an Inventory.transfer_to() und verändert keine Slots selbst.
var player_inventory: Inventory
var storage_inventory: Inventory


## TODO 60.1: Speichere beide gültigen Inventare, verbinde ihre Änderungssignale,
## öffne das Fenster und rufe _refresh() auf. Bei null bleibt das Fenster zu.
func open_for_storage(
	new_player_inventory: Inventory,
	new_storage_inventory: Inventory,
) -> void:
	pass


## TODO 60.2: Trenne zuvor verbundene Signale, leere beide Referenzen und
## verstecke das Fenster.
func close_menu() -> void:
	pass


## TODO 60.3: Erzeuge aus Kopien der sichtbaren Slotdaten je eine Zeile für
## Spieler und Kiste. Jede nicht leere Zeile zeigt Name, Menge und Stapelgrenze.
## Spielerzeilen erhalten einen Einlagern-, Kistenzeilen einen Entnehmen-Button.
func _refresh() -> void:
	pass


## TODO 60.4: Verschiebe mit transfer_to() so viel wie möglich aus dem gewählten
## Stapel. Die UI berechnet oder verändert dabei niemals selbst Itemmengen.
func _on_transfer_pressed(
	source: Inventory,
	target: Inventory,
	item_id: StringName,
	requested_amount: int,
) -> void:
	pass
