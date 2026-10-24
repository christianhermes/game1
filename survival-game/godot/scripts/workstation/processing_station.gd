class_name ProcessingStation
extends Workstation

@export var recipe: ProcessingRecipe


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
	recipe.ingredient.amount)
	
	if not ingredient_used:
		return
		
	for output in recipe.outputs:
		if output == null:
			continue
		actor.call(
			"receive_item",
			output.item_id, 
			output.amount)	
		
