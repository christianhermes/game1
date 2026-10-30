class_name Oven
extends Workstation

const REQUIRED_ITEM_ID: StringName = &"flour"
const REQUIRED_AMOUNT := 2
const BREAD_OUTPUT := 1

func _use_station(actor: Node3D) -> void:
	if not actor.has_method("try_use_selected_item"):
		return

	if not actor.has_method("receive_item") or not actor.has_method("can_receive_item"):
		return
	if not actor.call("can_receive_item", &"bread", BREAD_OUTPUT):
		return

	var flour_used: bool = actor.call(
		"try_use_selected_item",
		REQUIRED_ITEM_ID,
		REQUIRED_AMOUNT,
	)

	if not flour_used:
		return

	var remaining_amount: int = actor.call("receive_item", &"bread", BREAD_OUTPUT)
	if remaining_amount > 0:
		push_error("Vorab geprüftes Brot konnte nicht eingelagert werden.")
