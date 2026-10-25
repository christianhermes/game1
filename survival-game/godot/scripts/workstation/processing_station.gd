class_name ProcessingStation
extends Workstation

signal production_queue_changed

# recipe bleibt für die vorhandenen Szenen als einzelnes Standardrezept
# erhalten. available_recipes ermöglicht später mehrere auswählbare Rezepte.
@export var recipe: ProcessingRecipe
@export var available_recipes: Array[ProcessingRecipe] = []

var next_order_id := 1
var production_queue: Array[ProductionOrder] = []


# Liefert alle an dieser Station auswählbaren Rezepte. Das bisherige einzelne
# recipe wird automatisch übernommen, damit bestehende Szenen weiterlaufen.
func get_available_recipes() -> Array[ProcessingRecipe]:
	var result: Array[ProcessingRecipe] = available_recipes.duplicate()
	if recipe != null and not result.has(recipe):
		result.push_front(recipe)
	return result


func enqueue_recipe(recipe_to_add: ProcessingRecipe) -> bool:
	# TODO AUFGABE 6: Füge einen Produktionslauf zum passenden Rezeptauftrag hinzu.
	#
	# Die beiden vorhandenen Prüfungen bleiben unverändert. Danach gilt:
	#
	# A) Jedes Rezept soll höchstens einmal in der Prioritätenliste vorkommen:
	# 1. Laufe mit for order in production_queue über alle Aufträge.
	# 2. Wenn order.recipe == recipe_to_add gilt:
	#    - erhöhe order.amount um 1,
	#    - löse production_queue_changed.emit() aus,
	#    - gib sofort true zurück.
	#
	# B) Nur wenn das Rezept noch nicht vorhanden ist, entsteht ein neuer Auftrag:
	# 3. Erzeuge einen ProductionOrder mit
	#      ProductionOrder.new(next_order_id, recipe_to_add, 1)
	# 4. Erhöhe next_order_id danach um 1.
	# 5. Hänge den neuen Order mit production_queue.append(...) unten an.
	# 6. Löse production_queue_changed.emit() aus und gib true zurück.
	#
	# Wichtig: Die Position des gefundenen Auftrags bleibt unverändert. Ein weiterer
	# Klick erhöht nur seine Wiederholungsmenge und verändert nicht seine Priorität.
	if recipe_to_add == null:
		return false
	var recipes = get_available_recipes()
	if recipes.find(recipe_to_add) == -1:
		return false

	return false


# Das UI erhält eine Kopie, damit es die echte Warteschlange nicht versehentlich
# verändern kann. Die ProcessingStation bleibt die einzige Datenquelle.
func get_production_queue() -> Array[ProductionOrder]:
	return production_queue.duplicate()


func remove_queued_order(order_id: int) -> bool:
	# TODO AUFGABE 7: Entferne genau den vom UI gewählten Auftrag über seine ID.
	#
	# Vorgehen:
	# 1. Laufe mit for index in range(production_queue.size()) über die Queue.
	# 2. Vergleiche production_queue[index].id mit order_id.
	# 3. Bei Übereinstimmung:
	#    - entferne den Eintrag mit production_queue.remove_at(index),
	#    - löse production_queue_changed.emit() aus,
	#    - gib true zurück.
	# 4. Wurde nach der gesamten Schleife nichts gefunden, gib false zurück.
	#
	# Die ID statt des Array-Index zu übergeben ist wichtig: Nach dem Entfernen
	# verschieben sich Indizes, die Identität der übrigen Aufträge bleibt gleich.
	return false


func move_queued_order(order_id: int, direction: int) -> bool:
	# TODO AUFGABE 8: Verschiebe einen Auftrag in der Prioritätenliste.
	#
	# direction ist -1 für eine Position nach oben und 1 für eine Position
	# nach unten. Andere Werte sind ungültig.
	#
	# Vorgehen:
	# 1. Wenn direction weder -1 noch 1 ist, gib false zurück.
	# 2. Laufe mit einem Index über production_queue.
	# 3. Überspringe Einträge, deren id nicht order_id entspricht.
	# 4. Berechne für den gefundenen Auftrag:
	#      var target_index := index + direction
	# 5. Prüfe mit target_index < 0 oder target_index >= production_queue.size(),
	#    ob die neue Position außerhalb der Liste liegt. Dann: return false.
	# 6. Entferne den Auftrag zunächst mit remove_at(index) und merke ihn vorher
	#    in einer Variable.
	# 7. Füge ihn mit production_queue.insert(target_index, order) wieder ein.
	# 8. Löse production_queue_changed.emit() aus und gib true zurück.
	# 9. Wurde die ID nicht gefunden, gib nach der Schleife false zurück.
	#
	# Die Array-Reihenfolge IST die Priorität: Index 0 wird später immer zuerst
	# berücksichtigt, unabhängig von der Wiederholungsmenge seines Auftrags.
	return false


func _use_station(actor: Node3D) -> void:
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
