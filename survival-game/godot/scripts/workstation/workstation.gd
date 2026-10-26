class_name Workstation
extends Area3D

@export var display_name := "Arbeitsstation"

func _ready() -> void:
	add_to_group("interactable")


func get_world_info_title() -> String:
	return display_name


func get_world_info_text() -> String:
	return "Typ: Arbeitsstation"


func interact(actor: Node3D) -> void:
	_use_station(actor)


func _use_station(_actor: Node3D) -> void:
	push_warning("Diese Arbeitsstation besitzt noch keine Funktion.")
