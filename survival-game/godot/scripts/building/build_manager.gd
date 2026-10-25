class_name BuildManager
extends Node3D

@export var player: CharacterBody3D
@export var camera: Camera3D
@export var construction_site_scene: PackedScene
@export var selected_recipe: BuildRecipe

@onready var placement_preview: MeshInstance3D = $PlacementPreview

var build_mode := false
var control_enabled := false


func _ready() -> void:
	set_control_enabled(false)

func _unhandled_input(event: InputEvent) -> void:
	if not control_enabled:
		return

	if event.is_action_pressed("toggle_build_mode"):
		build_mode = not build_mode
		placement_preview.visible = build_mode


func set_control_enabled(enabled: bool) -> void:
	control_enabled = enabled

	if not control_enabled:
		build_mode = false
		placement_preview.visible = false
