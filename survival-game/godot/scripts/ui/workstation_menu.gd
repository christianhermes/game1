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
# Jeder ProductionOrder wird dabei zu einer eigenen Zeile mit Abbrechen-Button.
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


func _create_queue_row(
	order: ProductionOrder,
	display_index: int,
	queue_size: int,
) -> HBoxContainer:
	# TODO AUFGABE 9: Baue eine sichtbare Zeile für einen priorisierten Auftrag.
	#
	# Gewünschte Darstellung:
	#   1. Mehl mahlen x3    [Hoch] [Runter] [Abbrechen]
	#
	# Vorgehen:
	# 1. Prüfe order und order.recipe auf null. Falls eines null ist: return null.
	# 2. Erzeuge mit HBoxContainer.new() eine Variable row.
	# 3. Erzeuge mit Label.new() eine Variable order_label.
	# 4. Setze order_label.text mit dem Format "%d. %s x%d" und diesen Werten:
	#      display_index, order.recipe.display_name, order.amount
	# 5. Setze order_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL,
	#    damit der Text den freien Platz vor dem Button einnimmt.
	# 6. Füge order_label mit row.add_child(order_label) zur Zeile hinzu.
	# 7. Erzeuge einen Hoch-Button. Setze seinen Text auf "Hoch" und verbinde:
	#      up_button.pressed.connect(
	#          _on_move_order_pressed.bind(order.id, -1),
	#      )
	#    Setze up_button.disabled = display_index == 1.
	# 8. Erzeuge entsprechend einen Runter-Button mit direction 1.
	#    Deaktiviere ihn mit display_index == queue_size.
	# 9. Erzeuge einen Button, setze seinen Text auf "Abbrechen" und verbinde:
	#      cancel_button.pressed.connect(
	#          _on_cancel_order_pressed.bind(order.id),
	#      )
	# 10. Füge alle drei Buttons in dieser Reihenfolge zur row hinzu und gib row zurück.
	#
	# bind() speichert die stabile ID und beim Verschieben zusätzlich die Richtung
	# im jeweiligen Button. Die Buttons arbeiten dadurch nicht mit instabilen Indizes.
	return null


func _on_cancel_order_pressed(order_id: int) -> void:
	# TODO AUFGABE 10: Delegiere Abbrechen und Prioritätsänderung an die Station.
	#
	# 1. Wenn current_station null ist: return.
	# 2. Rufe current_station.remove_queued_order(order_id) auf.
	# 3. Kein direkter _refresh_queue()-Aufruf: Die Station sendet bei Erfolg
	#    production_queue_changed und aktualisiert damit das Menü automatisch.
	pass


func _on_move_order_pressed(order_id: int, direction: int) -> void:
	# TODO AUFGABE 10 (Fortsetzung):
	# 1. Wenn current_station null ist: return.
	# 2. Rufe current_station.move_queued_order(order_id, direction) auf.
	# 3. Auch hier ist kein manueller _refresh_queue()-Aufruf erforderlich.
	pass
