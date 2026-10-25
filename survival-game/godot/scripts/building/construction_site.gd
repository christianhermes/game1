class_name ConstructionSite
extends Area3D

@export var recipe: BuildRecipe
# Jede dynamisch platzierte Baustelle benötigt eine eindeutige Welt-ID, damit
# ein Auftrag keine kurzlebige Node-Referenz speichern muss.
@export var world_id: StringName = &""
var delivered_materials: Dictionary = {}
var current_work: int = 0
@onready var site_label: Label3D = $SiteLabel

func _ready() -> void:
	add_to_group("interactable")
	# Die Gruppe und world_id machen auch dynamisch platzierte Baustellen zu
	# auflösbaren Zielen für den SettlementJobManager.
	add_to_group("job_targets")

	if recipe == null:
		site_label.text = "Kein Rezept ausgewählt"
		return

	_update_label()


# Liefert die stabile Ziel-ID, unter der Bewohner diese Baustelle wiederfinden.
func get_job_target_id() -> StringName:
	return world_id


# Kennzeichnet Interaktionen mit dieser Baustelle als Bauauftrag.
func get_job_type() -> SettlementJobManager.JobType:
	return SettlementJobManager.JobType.BUILD


# Prüft über alle Materialarten hinweg, ob die Baustelle vollständig beliefert
# wurde. Fehlende Dictionary-Einträge gelten dabei als Menge 0.
func _has_all_materials() -> bool:
	for material in recipe.required_materials:
		var delivered: int = delivered_materials.get(material.item_id, 0)

		if delivered < material.amount:
			return false

	return true


# Überträgt alle noch benötigten Materialien, die der Bewohner im Inventar
# besitzt. Bereits gelieferte Teilmengen bleiben bei einem Fehlschlag erhalten.
func _deliver_all_materials(actor: Node3D) -> bool:
	if not actor.has_method("try_use_item"):
		return false

	for material in recipe.required_materials:
		var delivered: int = delivered_materials.get(material.item_id, 0)

		while delivered < material.amount:
			var material_used: bool = actor.call(
				"try_use_item",
				material.item_id,
				1,
			)

			if not material_used:
				_update_label()
				return false

			delivered += 1
			delivered_materials[material.item_id] = delivered

	_update_label()
	return _has_all_materials()


# Liefert bei einer Interaktion zunächst alle verfügbaren Materialien und
# führt erst bei vollständiger Belieferung einen einzelnen Arbeitsschritt aus.
func interact(actor: Node3D) -> void:
	if not _deliver_all_materials(actor):
		return

	_try_build(actor)


func _update_label() -> void:
	var material: ItemAmount = recipe.required_materials[0]
	var delivered: int = delivered_materials.get(material.item_id, 0)
	site_label.text = "%s\n%s: %d/%d" % [
	recipe.display_name,
	String(material.item_id).capitalize(),
	delivered,
	material.amount,
	]
	if delivered >= material.amount:
		site_label.text = "%s\n%s\nArbeit: %d/%d" % [
		recipe.display_name,
		String(recipe.required_tool_id).capitalize(),
		current_work,
		recipe.required_work,
		]
		return

func _try_build(actor: Node3D) -> void:
	if not actor.has_method("has_item"):
		return

	var correct_tool_selected: bool = actor.call(
		"has_item",
		recipe.required_tool_id,
	)
	if not correct_tool_selected:
		return

	current_work += 1
	if current_work >= recipe.required_work:
		_complete_building()
		return

	_update_label()


# Liefert alle verfügbaren Materialien und führt die vollständige Bauarbeit in
# sichtbaren Zeitabständen aus. Vor und nach jedem Timer wird geprüft, ob der
# Bewohner noch denselben Auftrag bearbeitet. Fehlende Voraussetzungen oder
# ein zwischenzeitlicher Abbruch ergeben false.
func perform_build_job(actor: Node3D, job_id: int) -> bool:
	if not _deliver_all_materials(actor):
		return false

	if not actor.has_method("has_item"):
		return false

	if not actor.call("has_item", recipe.required_tool_id):
		return false

	if not actor.has_method("is_current_job"):
		return false

	while current_work < recipe.required_work:
		if not actor.call("is_current_job", job_id):
			return false

		await get_tree().create_timer(0.75).timeout

		if not actor.call("is_current_job", job_id):
			return false

		current_work += 1
		_update_label()

	_complete_building()
	return true


func _complete_building() -> void:
	var finished_building: Node3D = recipe.finished_scene.instantiate()
	get_parent().add_child(finished_building)
	finished_building.global_transform = global_transform
	queue_free()
