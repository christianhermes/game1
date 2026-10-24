class_name ConstructionSite
extends Area3D

@export var recipe: BuildRecipe
var delivered_materials: Dictionary = {}
var current_work: int = 0
@onready var site_label: Label3D = $SiteLabel

func _ready() -> void:
	add_to_group("interactable")

	if recipe == null:
		site_label.text = "Kein Rezept ausgewählt"
		return

	_update_label()


func interact(actor: Node3D) -> void:
	if not actor.has_method("try_use_selected_item"):
		return

	for material in recipe.required_materials:
		var delivered: int = delivered_materials.get(material.item_id, 0)
		if delivered >= material.amount:
			continue

		var material_used: bool = actor.call(
			"try_use_selected_item",
			material.item_id,
			1,
		)
		if not material_used:
			return

		delivered_materials[material.item_id] = delivered + 1
		_update_label()
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
	if not actor.has_method("has_selected_item"):
		return

	var correct_tool_selected: bool = actor.call(
		"has_selected_item",
		recipe.required_tool_id,
	)
	if not correct_tool_selected:
		return

	current_work += 1
	if current_work >= recipe.required_work:
		_complete_building()
		return

	_update_label()


func _complete_building() -> void:
	var finished_building: Node3D = recipe.finished_scene.instantiate()
	get_parent().add_child(finished_building)
	finished_building.global_transform = global_transform
	queue_free()
