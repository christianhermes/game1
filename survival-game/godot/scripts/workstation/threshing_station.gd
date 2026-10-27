class_name ThreshingStation
extends Workstation

const REQUIRED_ITEM_ID: StringName = &"wheat"
const REQUIRED_AMOUNT := 1
const SEED_OUTPUT := 2
const STRAW_OUTPUT := 1

func _use_station(actor: Node3D) -> void:
	# TODO 57.4: Saatgut und Stroh gemeinsam auf verfügbaren Platz prüfen, bevor
	# Weizen verbraucht wird. Beide Outputs müssen ganz oder gar nicht entstehen.
	if not actor.has_method("try_use_selected_item"):
		return

	if not actor.has_method("receive_item"):
		return

	var wheat_used: bool = actor.call(
		"try_use_selected_item",
		REQUIRED_ITEM_ID,
		REQUIRED_AMOUNT,
	)

	if not wheat_used:
		return

	actor.call("receive_item", &"wheat_seed", SEED_OUTPUT)
	actor.call("receive_item", &"straw", STRAW_OUTPUT)
