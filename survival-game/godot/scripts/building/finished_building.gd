class_name FinishedBuilding
extends StaticBody3D

## Gemeinsame minimale Daten eines fertigen Gebäudes. Schaden und Reparaturen
## folgen erst als eigenes Gameplay-System; das Infofenster kann die dafür
## vorgesehenen Lebenspunkte aber bereits einheitlich darstellen.

@export var display_name := "Gebäude"
@export_range(1.0, 10000.0, 1.0) var max_health := 100.0
var health: float


func _ready() -> void:
	health = max_health


func get_world_info_title() -> String:
	return display_name


func get_world_info_text() -> String:
	return "Status: Fertig\nLeben: %d/%d" % [roundi(health), roundi(max_health)]
