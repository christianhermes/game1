class_name WorkstationMenu
extends PanelContainer


@onready var title_label: Label = $Margin/VBox/TitleLabel
@onready var recipe_buttons: VBoxContainer = $Margin/VBox/RecipeButtons
@onready var queue_label: Label = $Margin/VBox/QueueLabel
@onready var queue_entries: VBoxContainer = $Margin/VBox/QueueEntries
@onready var close_button: Button = $Margin/VBox/CloseButton

var current_station: ProcessingStation = null


func _ready() -> void:
	visible = false
	close_button.pressed.connect(close_menu)


# Öffnet das Fenster für genau eine Station und verbindet dessen
# Warteschlangenänderungen mit der Anzeige.
func open_for_station(station: ProcessingStation) -> void:
	if station == null:
		return

	_disconnect_current_station()
	current_station = station
	current_station.production_queue_changed.connect(_refresh_queue)
	title_label.text = current_station.display_name
	_rebuild_recipe_buttons()
	_refresh_queue()
	visible = true


func close_menu() -> void:
	_disconnect_current_station()
	current_station = null
	visible = false


func _disconnect_current_station() -> void:
	if current_station == null:
		return
	if current_station.production_queue_changed.is_connected(_refresh_queue):
		current_station.production_queue_changed.disconnect(_refresh_queue)


# Erzeugt für jedes verfügbare ProcessingRecipe einen eigenen Button. bind()
# merkt sich, welches Rezept zu welchem dynamisch erzeugten Button gehört.
func _rebuild_recipe_buttons() -> void:
	for old_button in recipe_buttons.get_children():
		old_button.queue_free()

	if current_station == null:
		return

	for available_recipe in current_station.get_available_recipes():
		if available_recipe == null:
			continue
		var recipe_button := Button.new()
		recipe_button.text = available_recipe.display_name
		recipe_button.pressed.connect(
			_on_recipe_button_pressed.bind(available_recipe),
		)
		recipe_buttons.add_child(recipe_button)


# Übergibt das angeklickte Rezept an die geöffnete Station. Deren Signal
# production_queue_changed aktualisiert anschließend automatisch die Anzeige.
func _on_recipe_button_pressed(selected_recipe: ProcessingRecipe) -> void:
	if current_station == null:
		return
	current_station.enqueue_recipe(selected_recipe)


# Baut die sichtbaren Queue-Zeilen aus einer Kopie der Stationsdaten neu auf.
# Jeder ProductionOrder erhält eine Zeile mit Prioritäts- und Abbruchsteuerung.
func _refresh_queue() -> void:
	for old_row in queue_entries.get_children():
		old_row.queue_free()

	if current_station == null:
		queue_label.text = "Warteschlange: leer"
		return

	var production_queue: Array[ProductionOrder] = (
		current_station.get_production_queue()
	)
	if production_queue.is_empty():
		queue_label.text = "Warteschlange: leer"
		return

	queue_label.text = "Warteschlange:"
	for index in range(production_queue.size()):
		var row := _create_queue_row(
			production_queue[index],
			index + 1,
			production_queue.size(),
		)
		if row != null:
			queue_entries.add_child(row)


# Erzeugt die Anzeige und Steuerung eines priorisierten Produktionsauftrags.
# Die stabile Auftrags-ID bleibt auch nach einer Verschiebung gültig.
func _create_queue_row(
	order: ProductionOrder,
	display_index: int,
	queue_size: int,
) -> HBoxContainer:
	if order == null or order.recipe == null:
		return null

	var row := HBoxContainer.new()
	var order_label := Label.new()
	order_label.text = "%d. %s x%d" % [
		display_index,
		order.recipe.display_name,
		order.amount,
	]
	order_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(order_label)

	var up_button := Button.new()
	up_button.text = "Hoch"
	up_button.pressed.connect(
		_on_move_order_pressed.bind(order.id, -1),
	)
	up_button.disabled = display_index == 1

	var down_button := Button.new()
	down_button.text = "Runter"
	down_button.pressed.connect(
		_on_move_order_pressed.bind(order.id, 1),
	)
	down_button.disabled = display_index == queue_size

	var cancel_button := Button.new()
	cancel_button.text = "Abbrechen"
	cancel_button.pressed.connect(
		_on_cancel_order_pressed.bind(order.id),
	)

	row.add_child(up_button)
	row.add_child(down_button)
	row.add_child(cancel_button)
	return row


# Lässt die Station den über seine stabile ID gewählten Auftrag entfernen.
# Das Stationssignal aktualisiert die sichtbare Liste anschließend automatisch.
func _on_cancel_order_pressed(order_id: int) -> void:
	if current_station == null:
		return
	current_station.remove_queued_order(order_id)


# Übergibt die gewählte ID und Bewegungsrichtung an die Station. Das UI
# verändert die zugrunde liegende Prioritätenliste nicht selbst.
func _on_move_order_pressed(order_id: int, direction: int) -> void:
	if current_station == null:
		return
	current_station.move_queued_order(order_id, direction)
