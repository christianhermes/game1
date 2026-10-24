class_name BuildManager
extends Node3D

@export var player: CharacterBody3D
@export var camera: Camera3D
@export var construction_site_scene: PackedScene
@export var selected_recipe: BuildRecipe

@onready var placement_preview: MeshInstance3D = $PlacementPreview

var build_mode := false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_build_mode"):
		build_mode = not build_mode
		placement_preview.visible = build_mode
		player.can_move = not build_mode
