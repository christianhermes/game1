class_name Workstation
extends Area3D

@export var display_name := "Arbeitsstation"

@onready var station_label: Label3D = $StationLabel


func _ready() -> void:
	add_to_group("interactable")
	station_label.text = display_name


func interact(actor: Node3D) -> void:
	_use_station(actor)


func _use_station(_actor: Node3D) -> void:
	push_warning("Diese Arbeitsstation besitzt noch keine Funktion.")
