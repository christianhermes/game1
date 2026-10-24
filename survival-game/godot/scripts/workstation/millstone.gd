class_name Millstone
extends Workstation

const REQUIRED_ITEM_ID: StringName = &"wheat_seed"
const REQUIRED_AMOUNT := 1
const FLOUR_OUTPUT := 2

func _use_station(actor: Node3D) -> void:
	if not actor.has_method("try_use_selected_item"):
		return

	if not actor.has_method("receive_item"):
		return

	var wheat_seed_used: bool = actor.call(
		"try_use_selected_item",
		REQUIRED_ITEM_ID,
		REQUIRED_AMOUNT,
	)

	if not wheat_seed_used:
		return

	actor.call("receive_item", &"flour", FLOUR_OUTPUT)
