class_name BuildRecipe
extends Resource

@export var display_name: String = ""
@export var finished_scene: PackedScene
@export var required_materials: Array[ItemAmount] = []
@export var required_tool_id: StringName = &""
@export_range(1, 100, 1) var required_work: int = 1
