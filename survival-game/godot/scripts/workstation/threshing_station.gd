class_name ThreshingStation
extends Workstation

const REQUIRED_ITEM_ID: StringName = &"wheat"
const REQUIRED_AMOUNT := 1
const SEED_OUTPUT := 2
const STRAW_OUTPUT := 1

func _use_station(actor: Node3D) -> void:
	if not actor.has_method("try_use_selected_item"):
		return

	if not actor.has_method("receive_item") or not actor.has_method("can_receive_items"):
		return

	var seed_output := ItemAmount.new()
	seed_output.item_id = &"wheat_seed"
	seed_output.amount = SEED_OUTPUT
	var straw_output := ItemAmount.new()
	straw_output.item_id = &"straw"
	straw_output.amount = STRAW_OUTPUT
	var outputs: Array[ItemAmount] = [seed_output, straw_output]
	if not actor.call("can_receive_items", outputs):
		return

	var wheat_used: bool = actor.call(
		"try_use_selected_item",
		REQUIRED_ITEM_ID,
		REQUIRED_AMOUNT,
	)

	if not wheat_used:
		return

	var seed_remainder: int = actor.call("receive_item", &"wheat_seed", SEED_OUTPUT)
	var straw_remainder: int = actor.call("receive_item", &"straw", STRAW_OUTPUT)
	if seed_remainder > 0 or straw_remainder > 0:
		push_error("Vorab geprüfter Dreschoutput konnte nicht eingelagert werden.")
