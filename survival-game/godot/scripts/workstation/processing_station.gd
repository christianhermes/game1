class_name ProcessingStation
extends Workstation

signal production_queue_changed

# recipe bleibt für die vorhandenen Szenen als einzelnes Standardrezept
# erhalten. available_recipes ermöglicht später mehrere auswählbare Rezepte.
@export var recipe: ProcessingRecipe
@export var available_recipes: Array[ProcessingRecipe] = []

var next_order_id := 1
var production_queue: Array[ProductionOrder] = []


## Ergänzt die allgemeine Stationsinformation um verfügbare Rezepte und die
## aktuelle Prioritätsreihenfolge der Produktionswarteschlange.
func get_world_info_text() -> String:
	var recipes := get_available_recipes()
	var lines: Array[String] = [
		"Typ: Produktionsstation",
		"Rezepte: %d" % recipes.size(),
	]
	if production_queue.is_empty():
		lines.append("Warteschlange: Leer")
	else:
		lines.append("Warteschlange:")
		for index in range(production_queue.size()):
			var order := production_queue[index]
			var recipe_name := "Unbekannt"
			if order.recipe != null and not order.recipe.display_name.is_empty():
				recipe_name = order.recipe.display_name
			lines.append("%d. %s x%d" % [index + 1, recipe_name, order.amount])
	return "\n".join(lines)


# Liefert alle an dieser Station auswählbaren Rezepte. Das bisherige einzelne
# recipe wird automatisch übernommen, damit bestehende Szenen weiterlaufen.
func get_available_recipes() -> Array[ProcessingRecipe]:
	var result: Array[ProcessingRecipe] = available_recipes.duplicate()
	if recipe != null and not result.has(recipe):
		result.push_front(recipe)
	return result


# Fügt dem vorhandenen Rezeptauftrag einen Produktionslauf hinzu. Ein neues
# Rezept erhält genau einen Auftrag am Ende der Prioritätenliste und eine
# stabile ID. Eine höhere Wiederholungsmenge verändert die Priorität nicht.
func enqueue_recipe(recipe_to_add: ProcessingRecipe) -> bool:
	if recipe_to_add == null:
		return false
	var recipes = get_available_recipes()
	if recipes.find(recipe_to_add) == -1:
		return false

	for order in production_queue:
		if order.recipe == recipe_to_add:
			order.amount += 1
			production_queue_changed.emit()
			return true

	var new_order := ProductionOrder.new(next_order_id, recipe_to_add, 1)
	next_order_id += 1
	production_queue.append(new_order)
	production_queue_changed.emit()
	return true


# Das UI erhält eine Kopie, damit es die echte Warteschlange nicht versehentlich
# verändern kann. Die ProcessingStation bleibt die einzige Datenquelle.
func get_production_queue() -> Array[ProductionOrder]:
	return production_queue.duplicate()


# Entfernt genau den Auftrag mit der angegebenen stabilen ID. Array-Indizes
# werden nicht als Identität verwendet, weil sie sich beim Sortieren verändern.
func remove_queued_order(order_id: int) -> bool:
	for index in range(production_queue.size()):
		if production_queue[index].id == order_id:
			production_queue.remove_at(index)
			production_queue_changed.emit()
			return true
	return false


# Verschiebt einen Auftrag genau eine Prioritätsstufe. Die Array-Reihenfolge ist
# die Ausführungspriorität: Index 0 wird später zuerst berücksichtigt.
# direction muss -1 für hoch oder 1 für runter sein.
func move_queued_order(order_id: int, direction: int) -> bool:
	if direction != -1 and direction != 1:
		return false
	for index in range(production_queue.size()):
		if production_queue[index].id != order_id:
			continue
		var target_index := index + direction
		if target_index < 0 or target_index >= production_queue.size():
			return false
		var target = production_queue[index]
		production_queue.remove_at(index)
		production_queue.insert(target_index, target)
		production_queue_changed.emit()
		return true
	return false


func _use_station(actor: Node3D) -> void:
	# TODO 57.4: Prüfe vor dem Verbrauch der Zutaten, ob sämtliche Outputs in das
	# Zielinventar passen. Ein voller Output darf niemals Zutaten vernichten. Die
	# drei alten Spezialstationen werden im selben Arbeitsschritt mit abgesichert.
	if recipe == null:
		push_warning(display_name + " besitzt kein Rezept.")
		return

	if recipe.ingredient == null:
		push_warning(recipe.display_name + " besitzt keine Zutat.")
		return

	if not actor.has_method("try_use_selected_item"):
		return

	if not actor.has_method("receive_item"):
		return

	var ingredient_used: bool = actor.call(
		"try_use_selected_item",
		recipe.ingredient.item_id,
		recipe.ingredient.amount,
	)

	if not ingredient_used:
		return

	for output in recipe.outputs:
		if output == null:
			continue
		actor.call(
			"receive_item",
			output.item_id,
			output.amount,
		)
