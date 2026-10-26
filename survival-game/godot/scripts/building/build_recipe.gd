class_name BuildRecipe
extends Resource

enum PlacementType {
	WALL_EDGE,
	FOUNDATION,
	FLOOR,
	OBJECT,
}

@export var display_name: String = ""
@export var finished_scene: PackedScene
@export var required_materials: Array[ItemAmount] = []
@export var required_tool_id: StringName = &""
@export_range(1, 100, 1) var required_work: int = 1

# Die Platzierungsdaten beschreiben die logische Rasterbelegung unabhängig von
# der sichtbaren Größe des Meshes. footprint verwendet X für Breite und Y für
# Tiefe auf der horizontalen Rasterebene.
@export var placement_type: PlacementType = PlacementType.WALL_EDGE
@export var footprint := Vector2i.ONE
@export_range(1, 8, 1) var height_levels := 1
@export var can_rotate := true

## Prüft, ob die logische Rasterbelegung des Rezepts verwendet werden kann.
## Wandkanten belegen in der ersten Version genau eine Rasterzelle, während
## Fundamente, Böden und Objekte auch größere Grundflächen verwenden dürfen.
func is_placement_data_valid() -> bool:
	if footprint.x < 1 or footprint.y < 1 or height_levels < 1:
		return false
	if placement_type == PlacementType.WALL_EDGE and footprint != Vector2i.ONE:
		return false
	return true
