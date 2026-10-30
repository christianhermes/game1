class_name StorageMenu
extends PanelContainer

## Das Lagerfenster zeigt Spieler und Kiste nebeneinander. Es delegiert jede
## Mengenänderung an Inventory.transfer_slot_to() und verändert keine Slots
## selbst.
var player_inventory: Inventory
var storage_inventory: Inventory
@onready var player_items: VBoxContainer = (
	$MainColumn/Inventories/PlayerColumn/PlayerItems
)
@onready var storage_items: VBoxContainer = (
	$MainColumn/Inventories/StorageColumn/StorageItems
)


## Öffnet das Lagerfenster für Spieler- und Kisteninventar. Vorhandene
## Verbindungen werden gelöst, damit beim Wechsel zu einer anderen Kiste kein
## altes Inventar weiterhin die Anzeige aktualisiert. Beide neuen Inventare
## melden Inhaltsänderungen anschließend automatisch an _refresh().
func open_for_storage(
	new_player_inventory: Inventory,
	new_storage_inventory: Inventory,
) -> void:
	if new_player_inventory == null or new_storage_inventory == null:
		return

	if (
		player_inventory != null
		and player_inventory.contents_changed.is_connected(_refresh)
	):
		player_inventory.contents_changed.disconnect(_refresh)
	if (
		storage_inventory != null
		and storage_inventory.contents_changed.is_connected(_refresh)
	):
		storage_inventory.contents_changed.disconnect(_refresh)

	player_inventory = new_player_inventory
	storage_inventory = new_storage_inventory

	if not player_inventory.contents_changed.is_connected(_refresh):
		player_inventory.contents_changed.connect(_refresh)
	if not storage_inventory.contents_changed.is_connected(_refresh):
		storage_inventory.contents_changed.connect(_refresh)

	visible = true
	_refresh()


## Trennt beide Änderungssignale sicher, verwirft die Inventarreferenzen und
## versteckt das Lagerfenster. is_connected() verhindert dabei den Versuch,
## eine bereits getrennte Verbindung erneut zu trennen.
func close_menu() -> void:
	if (
		player_inventory != null
		and player_inventory.contents_changed.is_connected(_refresh)
	):
		player_inventory.contents_changed.disconnect(_refresh)
	if (
		storage_inventory != null
		and storage_inventory.contents_changed.is_connected(_refresh)
	):
		storage_inventory.contents_changed.disconnect(_refresh)

	player_inventory = null
	storage_inventory = null
	visible = false


## Baut Spieler- und Kistenanzeige neu auf. Die Reihenfolge von Quelle und Ziel
## legt für die jeweilige Seite die spätere Transferrichtung fest.
func _refresh() -> void:
	if player_inventory == null or storage_inventory == null:
		return

	_rebuild_inventory_list(
		player_items,
		player_inventory,
		storage_inventory,
		"Einlagern",
	)
	_rebuild_inventory_list(
		storage_items,
		storage_inventory,
		player_inventory,
		"Entnehmen",
	)


## Ersetzt die sichtbaren Zeilen eines Inventars durch Zeilen aus sicheren
## Slotkopien. Dadurch speichert oder verändert die UI niemals echte Slots.
func _rebuild_inventory_list(
	container: VBoxContainer,
	source: Inventory,
	target: Inventory,
	button_text: String,
) -> void:
	for child in container.get_children():
		child.queue_free()

	var slots_snapshot := source.get_slots_snapshot()
	for slot_index in range(slots_snapshot.size()):
		var stack := slots_snapshot[slot_index]
		if stack == null or stack.is_empty():
			continue

		var definition := source.item_catalog.get_definition(stack.item_id)
		if definition == null:
			continue

		var row := _create_item_row(
			source,
			target,
			slot_index,
			stack,
			definition,
			button_text,
		)
		container.add_child(row)


## Erzeugt eine Zeile mit Stapelbeschreibung und Transferbutton. Der Button
## merkt sich Transferrichtung, Slotindex und die aktuell sichtbare Stapelmenge.
## Dadurch verändert ein Klick genau den angezeigten Stapel.
func _create_item_row(
	source: Inventory,
	target: Inventory,
	source_slot_index: int,
	stack: InventoryStack,
	definition: ItemDefinition,
	button_text: String,
) -> HBoxContainer:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = "%s: %d/%d" % [
		definition.display_name,
		stack.amount,
		definition.get_effective_max_stack_size(),
	]
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var button := Button.new()
	button.text = button_text
	button.pressed.connect(
		_on_transfer_pressed.bind(
			source,
			target,
			source_slot_index,
			stack.amount,
		),
	)

	row.add_child(label)
	row.add_child(button)
	return row


## Übergibt gültige Transferwünsche vollständig an Inventory.transfer_slot_to().
## Die Inventare begrenzen die Menge selbst und melden ihre Änderungen über
## contents_changed, wodurch die sichtbaren Listen automatisch neu entstehen.
func _on_transfer_pressed(
	source: Inventory,
	target: Inventory,
	source_slot_index: int,
	requested_amount: int,
) -> void:
	if source == null or target == null:
		return
	if source_slot_index < 0 or requested_amount <= 0:
		return
	source.transfer_slot_to(target, source_slot_index, requested_amount)
