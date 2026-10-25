class_name RubblePile
extends Area3D


# Die stabile Welt-ID verbindet diesen sichtbaren Schutthaufen mit seinem
# Auftrag, ohne dass der Manager eine kurzlebige Node-Referenz speichern muss.
@export var world_id: StringName = &""
@export var reward_item_id: StringName = &"stone"
@export_range(1, 99, 1) var reward_amount: int = 3
@export var item_pickup_scene: PackedScene

@onready var rubble_label: Label3D = $RubbleLabel


func _ready() -> void:
	add_to_group("job_targets")
	rubble_label.text = "Schutthaufen\nEnthält: %d %s" % [
		reward_amount,
		String(reward_item_id).capitalize(),
	]


# Liefert die stabile ID für den szenenunabhängig gespeicherten Auftrag.
func get_job_target_id() -> StringName:
	return world_id


# Ressourcenquellen erzeugen einen allgemeinen Gewinnungsauftrag. Derselbe Typ
# kann später auch für Bäume, Felsen oder Erzvorkommen verwendet werden.
func get_job_type() -> SettlementJobManager.JobType:
	return SettlementJobManager.JobType.EXTRACT_RESOURCE


# Ersetzt den abgetragenen Schutthaufen durch ein konfiguriertes, physisches
# ItemPickup. Die Belohnung bleibt dadurch in der Welt und muss anschließend
# mit einem eigenen PICKUP-Auftrag eingesammelt werden.
func interact(_actor: Node3D) -> void:
	if item_pickup_scene == null:
		return
	var parent = get_parent()
	if parent == null:
		return
	var child = item_pickup_scene.instantiate() as ItemPickup
	if child == null:
		return
	child.world_id = StringName("%s_reward" % world_id)
	child.item_id = reward_item_id
	child.amount = reward_amount
	parent.add_child(child)
	child.global_position = global_position + Vector3(1, 0, 0)

	queue_free()
