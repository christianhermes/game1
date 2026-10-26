class_name ConstructionSite
extends Area3D

@export var recipe: BuildRecipe
@export var refund_pickup_scene: PackedScene
## Logische Rasterdaten werden bereits vor dem Einfügen der Baustelle gesetzt.
## Die allgemeine Node-Referenz vermeidet eine Abhängigkeit vom lokalen
## class_name-Importcache und verweist zur Laufzeit auf BuildGrid.
var grid_origin := Vector3i.ZERO
var rotation_quarters := 0
var build_grid: Node
# Jede dynamisch platzierte Baustelle benötigt eine eindeutige Welt-ID, damit
# ein Auftrag keine kurzlebige Node-Referenz speichern muss.
@export var world_id: StringName = &""
var delivered_materials: Dictionary = {}
var current_work: int = 0
var cancellation_started := false
var status_message := ""

func _ready() -> void:
	add_to_group("interactable")
	# Die Gruppe und world_id machen auch dynamisch platzierte Baustellen zu
	# auflösbaren Zielen für den SettlementJobManager.
	add_to_group("job_targets")

	if not _is_recipe_valid():
		status_message = "Ungültiges Baurezept"
		return

	_update_site_visuals()
	_update_status()


## Formt die allgemeine Baustellenszene passend zum aktuellen Rezept. Mesh und
## Kollisionsform werden pro Instanz dupliziert, damit Wand-, Fundament- und
## Bodenbaustellen ihre Resources nicht gegenseitig verändern.
func _update_site_visuals() -> void:
	var site_mesh := get_node_or_null("SiteMesh") as MeshInstance3D
	var interaction_shape := get_node_or_null("InteractionShape") as CollisionShape3D
	if site_mesh == null or interaction_shape == null:
		return

	var source_mesh := site_mesh.mesh as BoxMesh
	var source_shape := interaction_shape.shape as BoxShape3D
	if source_mesh == null or source_shape == null:
		return

	# Beide Kopien werden vorbereitet, bevor eine Node verändert wird. Dadurch
	# bleibt die Baustelle auch bei einer unerwarteten Resource vollständig intakt.
	var local_mesh := source_mesh.duplicate() as BoxMesh
	var local_shape := source_shape.duplicate() as BoxShape3D
	if local_mesh == null or local_shape == null:
		return

	var visual_size := Vector3(
		BuildGrid.CELL_SIZE,
		0.1,
		0.4,
	)
	var collision_size := Vector3(
		BuildGrid.CELL_SIZE,
		0.5,
		0.8,
	)
	if recipe.placement_type != BuildRecipe.PlacementType.WALL_EDGE:
		var width := recipe.footprint.x * BuildGrid.CELL_SIZE
		var depth := recipe.footprint.y * BuildGrid.CELL_SIZE
		visual_size = Vector3(width, 0.1, depth)
		collision_size = Vector3(width, 0.5, depth)

	local_mesh.size = visual_size
	local_shape.size = collision_size
	site_mesh.mesh = local_mesh
	interaction_shape.shape = local_shape
	site_mesh.position.y = visual_size.y / 2.0
	interaction_shape.position.y = collision_size.y / 2.0


# Liefert die stabile Ziel-ID, unter der Bewohner diese Baustelle wiederfinden.
func get_job_target_id() -> StringName:
	return world_id


# Kennzeichnet Interaktionen mit dieser Baustelle als Bauauftrag.
func get_job_type() -> SettlementJobManager.JobType:
	return SettlementJobManager.JobType.BUILD


## Prüft alle Voraussetzungen, die der aktuelle Bauablauf von einem Rezept
## benötigt. Dadurch greifen spätere Funktionen nie auf unvollständige Daten zu.
func _is_recipe_valid() -> bool:
	if recipe == null:
		return false
	if recipe.display_name.is_empty() or recipe.finished_scene == null:
		return false
	if recipe.required_materials.is_empty() or recipe.required_tool_id.is_empty():
		return false

	for material in recipe.required_materials:
		if material == null:
			return false
		if material.item_id.is_empty() or material.amount < 1:
			return false

	return recipe.is_placement_data_valid()


# Prüft über alle Materialarten hinweg, ob die Baustelle vollständig beliefert
# wurde. Fehlende Dictionary-Einträge gelten dabei als Menge 0.
func _has_all_materials() -> bool:
	if not _is_recipe_valid():
		return false

	for material in recipe.required_materials:
		var delivered: int = delivered_materials.get(material.item_id, 0)

		if delivered < material.amount:
			return false

	return true


# Überträgt alle noch benötigten Materialien, die der Bewohner im Inventar
# besitzt. Bereits gelieferte Teilmengen bleiben bei einem Fehlschlag erhalten.
func _deliver_all_materials(actor: Node3D) -> bool:
	if not _is_recipe_valid():
		status_message = "Ungültiges Baurezept"
		return false
	if not actor.has_method("try_use_item"):
		return false

	for material in recipe.required_materials:
		var delivered: int = delivered_materials.get(material.item_id, 0)

		while delivered < material.amount:
			var material_used: bool = actor.call(
				"try_use_item",
				material.item_id,
				1,
			)

			if not material_used:
				_update_status()
				return false

			delivered += 1
			delivered_materials[material.item_id] = delivered

	_update_status()
	return _has_all_materials()


# Liefert bei einer Interaktion zunächst alle verfügbaren Materialien und
# führt erst bei vollständiger Belieferung einen einzelnen Arbeitsschritt aus.
func interact(actor: Node3D) -> void:
	if not _deliver_all_materials(actor):
		return

	_try_build(actor)


## Erstellt für jede benötigte Materialart eine eigene Statuszeile.
func _get_material_status_text() -> String:
	var lines: Array[String] = []
	for material in recipe.required_materials:
		var delivered: int = delivered_materials.get(material.item_id, 0)
		lines.append("%s: %d/%d" % [
			String(material.item_id).capitalize(),
			delivered,
			material.amount,
		])

	return "\n".join(lines)


## Löscht vorübergehende Fehlermeldungen, sobald die Baustelle wieder in einem
## regulären Zustand ist. Fortschrittswerte liest das Infofenster direkt aus.
func _update_status() -> void:
	if not _is_recipe_valid():
		status_message = "Ungültiges Baurezept"
		return

	status_message = ""


## Liefert die Inhalte für das zentrale Auswahlfenster. Weil die Werte bei
## jedem UI-Update neu gelesen werden, bleiben Lieferung und Baufortschritt live.
func get_world_info_title() -> String:
	if recipe == null or recipe.display_name.is_empty():
		return "Baustelle"
	return "Baustelle: %s" % recipe.display_name


func get_world_info_text() -> String:
	if not _is_recipe_valid():
		return status_message if not status_message.is_empty() else "Ungültiges Baurezept"

	var lines: Array[String] = [
		"Status: Materiallieferung",
		_get_material_status_text(),
	]
	if _has_all_materials():
		lines[0] = "Status: Bauarbeit"
		lines.append("Werkzeug: %s" % String(recipe.required_tool_id).capitalize())
		lines.append("Arbeit: %d/%d" % [current_work, recipe.required_work])
	if not status_message.is_empty():
		lines.append(status_message)
	return "\n".join(lines)

func _try_build(actor: Node3D) -> void:
	if not _is_recipe_valid():
		return
	if not actor.has_method("has_item"):
		return

	var correct_tool_selected: bool = actor.call(
		"has_item",
		recipe.required_tool_id,
	)
	if not correct_tool_selected:
		return

	current_work += 1
	if current_work >= recipe.required_work:
		_complete_building()
		return

	_update_status()


# Liefert alle verfügbaren Materialien und führt die vollständige Bauarbeit in
# sichtbaren Zeitabständen aus. Vor und nach jedem Timer wird geprüft, ob der
# Bewohner noch denselben Auftrag bearbeitet. Fehlende Voraussetzungen oder
# ein zwischenzeitlicher Abbruch ergeben false.
func perform_build_job(actor: Node3D, job_id: int) -> bool:
	if not _is_recipe_valid():
		status_message = "Ungültiges Baurezept"
		return false
	if not _deliver_all_materials(actor):
		return false
	if not actor.has_method("has_item"):
		return false

	if not actor.call("has_item", recipe.required_tool_id):
		return false

	if not actor.has_method("is_current_job"):
		return false

	while current_work < recipe.required_work:
		if not actor.call("is_current_job", job_id):
			return false

		await get_tree().create_timer(0.75).timeout

		if not actor.call("is_current_job", job_id):
			return false

		current_work += 1
		_update_status()

	_complete_building()
	return true


func _complete_building() -> void:
	if not _is_recipe_valid():
		status_message = "Ungültiges Baurezept"
		return

	# Ohne Owner-Übertragung darf kein fertiges Gebäude entstehen, weil seine
	# Rasterposition anschließend nicht mehr zuverlässig verwaltet werden könnte.
	if build_grid == null or not build_grid.has_method("replace_owner"):
		status_message = "Bauraster ist nicht verfügbar"
		return

	var finished_building := recipe.finished_scene.instantiate() as Node3D
	var parent := get_parent()
	if finished_building == null or parent == null:
		status_message = "Gebäude konnte nicht erstellt werden"
		return

	parent.add_child(finished_building)
	finished_building.global_transform = global_transform
	# Das fertige Gebäude übernimmt denselben Key, bevor die Baustelle verschwindet.
	build_grid.call("replace_owner", self, finished_building)
	queue_free()


## Erzeugt für jede gelieferte Materialart genau ein physisches Pickup. Alle
## Instanzen werden zunächst vorbereitet, damit ein ungültiges Pickup-Prefab
## nicht zu einer nur teilweise ausgeführten Rückgabe führt.
func _spawn_refund_pickups() -> bool:
	var parent := get_parent()
	if refund_pickup_scene == null or parent == null:
		return false

	var pickups: Array[ItemPickup] = []
	for item_id in delivered_materials:
		var delivered_amount: int = delivered_materials.get(item_id, 0)
		if delivered_amount <= 0:
			continue

		var pickup := refund_pickup_scene.instantiate() as ItemPickup
		if pickup == null:
			for prepared_pickup in pickups:
				prepared_pickup.free()
			return false

		pickup.item_id = item_id
		pickup.amount = delivered_amount
		pickup.world_id = StringName("%s_refund_%d" % [
			String(world_id),
			pickups.size(),
		])
		pickups.append(pickup)

	for index in range(pickups.size()):
		var pickup := pickups[index]
		parent.add_child(pickup)
		pickup.global_position = global_position + Vector3(
			0.75 * (index + 1),
			0.0,
			0.0,
		)

	delivered_materials.clear()
	return true


## Bricht alle zugehörigen Aufträge ab, gibt gelieferte Materialien zurück und
## entfernt anschließend Rasterreservierung und Baustelle. Der Schutz verhindert
## doppelte Pickups durch mehrere Abbruchaufrufe im selben Frame. Der Rückgabe-
## wert zeigt dem aufrufenden Eingabesystem, ob der Abbruch ausgeführt wurde.
func cancel_construction() -> bool:
	if cancellation_started:
		return false
	if build_grid == null or not build_grid.has_method("unregister_owner"):
		status_message = "Bauraster ist nicht verfügbar"
		return false

	cancellation_started = true
	SettlementJobManager.cancel_jobs_for_target(world_id)
	if not _spawn_refund_pickups():
		cancellation_started = false
		status_message = "Materialien konnten nicht zurückgegeben werden"
		return false

	build_grid.call("unregister_owner", self)
	queue_free()
	return true
