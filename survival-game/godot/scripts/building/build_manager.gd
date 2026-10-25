class_name BuildManager
extends Node3D

const GRID_SIZE := 2.0

@export var player: CharacterBody3D
@export var camera: Camera3D
@export var construction_site_scene: PackedScene
@export var selected_recipe: BuildRecipe

@onready var placement_preview: MeshInstance3D = $PlacementPreview

var build_mode := false
var control_enabled := false
var current_placement_position: Variant = null


func _ready() -> void:
	set_control_enabled(false)


## Aktualisiert die Bauvorschau fortlaufend auf der gültigen Rasterposition
## unter der Maus und blendet sie aus, wenn dort nicht gebaut werden darf.
func _process(_delta: float) -> void:
	if not is_build_mode_active():
		return

	var mouse_position = get_viewport().get_mouse_position()
	current_placement_position = _get_snapped_build_position(mouse_position)
	if current_placement_position == null:
		placement_preview.visible = false
		return
	placement_preview.visible = true
	placement_preview.global_position = current_placement_position + Vector3(0.0, 0.05, 0.0)


func _unhandled_input(event: InputEvent) -> void:
	if not control_enabled:
		return

	if event.is_action_pressed("toggle_build_mode"):
		build_mode = not build_mode
		placement_preview.visible = build_mode


# Liefert true nur dann, wenn Basissteuerung und Baumodus aktiv sind. Main
# nutzt diese Abfrage später, um Linksklicks nicht gleichzeitig zur Auswahl
# und zur Bauplatzierung zu verwenden.
func is_build_mode_active() -> bool:
	return control_enabled and build_mode


## Ermittelt den erlaubten Baupunkt unter der Maus und richtet ihn am Bauraster
## aus. Gibt null zurück, wenn kein gültiger Untergrund getroffen wurde.
func _get_snapped_build_position(mouse_position: Vector2) -> Variant:
	if camera == null:
		return null
	var ray_origin := camera.project_ray_origin(mouse_position)
	var ray_direction := camera.project_ray_normal(mouse_position)
	var ray_end := ray_origin + ray_direction * 1000.0
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collide_with_areas = true
	var hit = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return null

	var collider := hit.get("collider") as Node

	if collider == null or not collider.is_in_group("build_surface"):
		return null

	var hit_position: Vector3 = hit.get("position")

	return Vector3(
		snappedf(hit_position.x, GRID_SIZE),
		hit_position.y,
		snappedf(hit_position.z, GRID_SIZE)
	)


## Erzeugt an der aktuell gültigen Vorschauposition eine Baustelle mit dem
## ausgewählten Rezept. Gibt true zurück, wenn die Platzierung erfolgreich war.
func try_place_construction_site() -> bool:
	if not is_build_mode_active() or current_placement_position == null or construction_site_scene == null or selected_recipe == null:
		return false
	var site = construction_site_scene.instantiate() as ConstructionSite
	if site == null:
		return false
	site.recipe = selected_recipe
	# Die Rasterkoordinaten bilden eine reproduzierbare Ziel-ID. Dadurch können
	# Aufträge die Baustelle finden, ohne eine kurzlebige Node-Referenz zu halten.
	var placement_position: Vector3 = current_placement_position
	var cell_x = roundi(placement_position.x / GRID_SIZE)
	var cell_z = roundi(placement_position.z / GRID_SIZE)
	var id_text = StringName(&"construction_site_" + str(cell_x) + &"_" + str(cell_z))
	site.world_id = id_text
	var parent = get_parent()
	if parent == null:
		site.free()
		return false
	parent.add_child(site)
	site.global_position = placement_position

	return true


func set_control_enabled(enabled: bool) -> void:
	control_enabled = enabled

	if not control_enabled:
		build_mode = false
		placement_preview.visible = false
		current_placement_position = null
