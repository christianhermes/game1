class_name BuildManager
extends Node3D

# Godot verwendet für Drehungen Radiant. PI / 2 entspricht genau 90 Grad.
const PLACEMENT_ROTATION_STEP := PI / 2.0
const BUILD_OCCUPANT_GROUP := &"build_occupant"
const VALID_PREVIEW_COLOR := Color(0.25, 0.76, 0.0, 1.0)
const INVALID_PREVIEW_COLOR := Color(0.9, 0.15, 0.1, 1.0)

@export var player: CharacterBody3D
@export var camera: Camera3D
# Die Node ist in main.tscn mit dem BuildGrid-Skript verbunden. Der allgemeine
# Node-Typ verhindert eine Abhängigkeit vom lokalen class_name-Importcache.
@export var build_grid: Node
@export var construction_site_scene: PackedScene
@export var selected_recipe: BuildRecipe

@onready var placement_preview: MeshInstance3D = $PlacementPreview

var build_mode := false
var control_enabled := false
var current_placement_position: Variant = null
var current_grid_origin := Vector3i.ZERO
var current_rotation_quarters := 0
var placement_rotation_y := 0.0
var current_placement_valid := false


func _ready() -> void:
	set_control_enabled(false)
	_register_existing_construction_sites()


## Aktualisiert die Bauvorschau fortlaufend auf der gültigen Rasterposition
## unter der Maus und blendet sie aus, wenn dort nicht gebaut werden darf.
func _process(_delta: float) -> void:
	if not is_build_mode_active():
		return

	var mouse_position = get_viewport().get_mouse_position()
	current_placement_position = _get_snapped_build_position(mouse_position)
	if current_placement_position == null:
		current_placement_valid = false
		placement_preview.visible = false
		return
	placement_preview.visible = true
	placement_preview.global_position = current_placement_position + Vector3(0.0, 0.05, 0.0)
	current_placement_valid = bool(build_grid.call(
		"can_place",
		selected_recipe,
		current_grid_origin,
		current_rotation_quarters,
	))
	_update_placement_preview_color(current_placement_valid)


## Übernimmt beim Szenenstart bereits platzierte Baustellen in das zentrale
## Raster. So bleiben auch im Editor vorbereitete Baustellen weiterhin belegt.
func _register_existing_construction_sites() -> void:
	if not _has_valid_build_dependencies():
		return

	for node in get_tree().get_nodes_in_group(BUILD_OCCUPANT_GROUP):
		var site := node as ConstructionSite
		if site == null or site.recipe == null:
			continue

		var rotation_quarters := _rotation_y_to_quarters(site.global_rotation.y)
		var grid_origin := _get_grid_origin_for_world_position(
			site.global_position,
			site.recipe,
			rotation_quarters,
		)
		site.grid_origin = grid_origin
		site.rotation_quarters = rotation_quarters
		site.build_grid = build_grid
		var registered := bool(build_grid.call(
			"register_placement",
			site.recipe,
			grid_origin,
			rotation_quarters,
			site,
		))
		if not registered:
			push_warning("Vorhandene Baustelle konnte nicht im BuildGrid registriert werden: %s" % site.name)


## Prüft die Referenzen, die jede Rasterplatzierung benötigt.
func _has_valid_build_dependencies() -> bool:
	return (
		build_grid != null
		and selected_recipe != null
		and selected_recipe.is_placement_data_valid()
		and build_grid.has_method("world_to_cell")
		and build_grid.has_method("cell_to_world")
		and build_grid.has_method("world_to_wall_edge")
		and build_grid.has_method("wall_edge_to_world")
		and build_grid.has_method("can_place")
		and build_grid.has_method("register_placement")
	)


func _unhandled_input(event: InputEvent) -> void:
	if not control_enabled:
		return

	if event.is_action_pressed("toggle_build_mode"):
		build_mode = not build_mode
		placement_preview.visible = build_mode
		if not build_mode:
			_reset_placement_rotation()
		get_viewport().set_input_as_handled()
		return

	if build_mode and event.is_action_pressed("rotate_building"):
		_rotate_placement()
		get_viewport().set_input_as_handled()


## Dreht die Bauvorschau in festen 90-Grad-Schritten und hält den gespeicherten
## Winkel mit wrapf() innerhalb einer vollständigen Umdrehung.
func _rotate_placement() -> void:
	if selected_recipe != null and not selected_recipe.can_rotate:
		return

	placement_rotation_y = wrapf(
		placement_rotation_y + PLACEMENT_ROTATION_STEP,
		0.0,
		TAU,
	)
	current_rotation_quarters = _rotation_y_to_quarters(placement_rotation_y)
	placement_preview.rotation.y = placement_rotation_y


# Liefert true nur dann, wenn Basissteuerung und Baumodus aktiv sind. Main
# nutzt diese Abfrage später, um Linksklicks nicht gleichzeitig zur Auswahl
# und zur Bauplatzierung zu verwenden.
func is_build_mode_active() -> bool:
	return control_enabled and build_mode


## Wandelt einen exakten Y-Winkel in einen der vier logischen Drehschritte um.
func _rotation_y_to_quarters(rotation_y: float) -> int:
	return posmod(roundi(rotation_y / PLACEMENT_ROTATION_STEP), 4)


## Zeigt mit Grün oder Rot, ob die aktuelle Rasterzelle bebaut werden darf.
func _update_placement_preview_color(is_valid: bool) -> void:
	var overlay: StandardMaterial3D = placement_preview.material_overlay
	if overlay == null:
		return
	if is_valid:
		overlay.albedo_color = VALID_PREVIEW_COLOR
	else:
		overlay.albedo_color = INVALID_PREVIEW_COLOR


## Sammelt vorhandene Baustellen und Bauteile als Raycast-Ausnahmen. So trifft
## die Bauabfrage auch direkt neben oder hinter einer Wand weiterhin den Boden.
func _get_build_raycast_exclusions() -> Array[RID]:
	var exclusions: Array[RID] = []
	for occupant in get_tree().get_nodes_in_group(BUILD_OCCUPANT_GROUP):
		if occupant is CollisionObject3D:
			exclusions.append((occupant as CollisionObject3D).get_rid())

	return exclusions


## Berechnet abhängig von der Platzierungsart entweder eine Wandkante oder die
## Zelle unter der Weltposition.
func _get_grid_origin_for_world_position(
	world_position: Vector3,
	recipe: BuildRecipe,
	rotation_quarters: int,
) -> Vector3i:
	if recipe.placement_type == BuildRecipe.PlacementType.WALL_EDGE:
		return build_grid.call(
			"world_to_wall_edge",
			world_position,
			rotation_quarters,
		)

	return build_grid.call("world_to_cell", world_position)


## Ermittelt den Baupunkt unter der Maus und rechnet ihn abhängig vom Rezept in
## eine Wandkante oder den Mittelpunkt einer Rasterzelle um.
func _get_snapped_build_position(mouse_position: Vector2) -> Variant:
	if camera == null or not _has_valid_build_dependencies():
		return null
	var ray_origin := camera.project_ray_origin(mouse_position)
	var ray_direction := camera.project_ray_normal(mouse_position)
	var ray_end := ray_origin + ray_direction * 1000.0
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collide_with_areas = true
	query.exclude = _get_build_raycast_exclusions()
	var hit = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return null

	var collider := hit.get("collider") as Node

	if collider == null or not collider.is_in_group("build_surface"):
		return null

	current_rotation_quarters = _rotation_y_to_quarters(placement_rotation_y)
	current_grid_origin = _get_grid_origin_for_world_position(
		hit.get("position"),
		selected_recipe,
		current_rotation_quarters,
	)
	if selected_recipe.placement_type == BuildRecipe.PlacementType.WALL_EDGE:
		return build_grid.call(
			"wall_edge_to_world",
			current_grid_origin,
			current_rotation_quarters,
		)

	return build_grid.call("cell_to_world", current_grid_origin)


## Sucht per Raycast ausschließlich die Baustelle unter der Maus und versucht,
## sie kontrolliert abzubrechen. Bauobjekte werden hier bewusst nicht aus dem
## Raycast ausgeschlossen, weil gerade eine ConstructionSite getroffen werden soll.
func try_cancel_construction_site(mouse_position: Vector2) -> bool:
	if camera == null:
		return false
	var ray_origin := camera.project_ray_origin(mouse_position)
	var ray_direction := camera.project_ray_normal(mouse_position)
	var ray_end := ray_origin + ray_direction * 1000.0
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collide_with_areas = true
	var hit = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return false

	var site := hit.get("collider") as ConstructionSite
	if site == null:
		return false

	return site.cancel_construction()


## Erzeugt an der aktuell gültigen Vorschauposition eine Baustelle mit dem
## ausgewählten Rezept. Gibt true zurück, wenn die Platzierung erfolgreich war.
func try_place_construction_site() -> bool:
	# Dieselbe Gültigkeitsprüfung steuert Vorschaufarbe und Platzierung, damit
	# eine rot markierte beziehungsweise belegte Rasterzelle zuverlässig sperrt.
	if (
		not is_build_mode_active()
		or current_placement_position == null
		or construction_site_scene == null
		or not _has_valid_build_dependencies()
		or not current_placement_valid
	):
		return false
	var site = construction_site_scene.instantiate() as ConstructionSite
	if site == null:
		return false
	site.recipe = selected_recipe
	site.grid_origin = current_grid_origin
	site.rotation_quarters = current_rotation_quarters
	site.build_grid = build_grid
	# Platzierungsart und Rasterkoordinate bilden eine reproduzierbare Ziel-ID.
	# Aufträge finden die Baustelle dadurch ohne kurzlebige Node-Referenz wieder.
	var placement_position: Vector3 = current_placement_position
	var placement_key := "%d_%d_%d_%d_%d" % [
		selected_recipe.placement_type,
		current_grid_origin.x,
		current_grid_origin.y,
		current_grid_origin.z,
		current_rotation_quarters % 2,
	]
	site.world_id = StringName("construction_site_" + placement_key)
	var parent = get_parent()
	if parent == null:
		site.free()
		return false
	parent.add_child(site)
	site.global_position = placement_position
	# Die Baustelle übernimmt den Winkel der Vorschau. Beim Fertigstellen kopiert
	# ConstructionSite den gesamten global_transform auf das fertige Bauteil.
	site.global_rotation.y = placement_rotation_y
	var registered := bool(build_grid.call(
		"register_placement",
		selected_recipe,
		current_grid_origin,
		current_rotation_quarters,
		site,
	))
	if not registered:
		site.queue_free()
		current_placement_valid = false
		_update_placement_preview_color(false)
		return false

	current_placement_valid = false
	_update_placement_preview_color(false)
	return true


## Setzt den Rotationszustand beim Verlassen des Baumodus vollständig zurück.
func _reset_placement_rotation() -> void:
	placement_rotation_y = 0.0
	current_rotation_quarters = 0
	placement_preview.rotation.y = 0.0


func set_control_enabled(enabled: bool) -> void:
	control_enabled = enabled

	if not control_enabled:
		build_mode = false
		placement_preview.visible = false
		current_placement_position = null
		current_placement_valid = false
		_reset_placement_rotation()
