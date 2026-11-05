class_name WorldNavigation3D
extends NavigationRegion3D

## Wiederverwendbare Navigationsregion für Basis-, Abenteuer- und Dungeonmaps.
## Sie backt sämtliche begehbaren Höhen, Rampen und statischen Hindernisse aus
## einem frei wählbaren Teil des Szenenbaums in ein gemeinsames 3D-NavMesh.

signal navigation_rebuilt(success: bool)

@export var source_root_path := NodePath("..")
@export var bake_on_ready := true
@export_range(0.0, 2.0, 0.05) var rebake_delay := 0.1

var navigation_ready := false
var _request_scheduled := false
var _bake_running := false
var _rebake_after_current := false


func _ready() -> void:
	add_to_group(&"world_navigation")
	# Eingebettete Resources werden zwischen Instanzen derselben PackedScene
	# geteilt. Jede geladene Karte erhält deshalb vor einem Runtime-Bake ihre
	# eigene Kopie und kann andere Karten oder Tests nicht versehentlich ändern.
	if navigation_mesh != null:
		navigation_mesh = navigation_mesh.duplicate(true) as NavigationMesh
	navigation_ready = (
		navigation_mesh != null
		and navigation_mesh.get_polygon_count() > 0
	)

	if bake_on_ready:
		# Das gespeicherte Mesh könnte nicht mehr zur aktuellen Karte passen. Bis
		# zum ersten erfolgreichen Bake wird es deshalb nicht für neue Pfade genutzt.
		enabled = false
		navigation_ready = false
		request_rebake()


## Merkt mehrere schnelle Änderungen als einen einzigen Bake vor. Kommt während
## eines laufenden Bakes weitere Geometrie hinzu, folgt danach genau ein neuer.
func request_rebake() -> void:
	if _bake_running:
		_rebake_after_current = true
		return
	if _request_scheduled:
		return

	_request_scheduled = true
	_run_scheduled_rebake.call_deferred()


func is_navigation_ready() -> bool:
	return navigation_ready and enabled


## Wartet einen Frame auf neu hinzugefügte CollisionObjects und bündelt weitere
## Änderungsmeldungen innerhalb des kurzen konfigurierbaren Zeitfensters.
func _run_scheduled_rebake() -> void:
	await get_tree().process_frame
	if rebake_delay > 0.0:
		await get_tree().create_timer(rebake_delay).timeout

	_request_scheduled = false
	_start_rebake()


func _start_rebake() -> void:
	if navigation_mesh == null:
		_finish_rebake(false)
		return

	var source_root := get_node_or_null(source_root_path)
	if source_root == null:
		push_warning("Die Navigationsquelle wurde nicht gefunden: %s" % source_root_path)
		_finish_rebake(false)
		return

	var source_geometry := NavigationMeshSourceGeometryData3D.new()
	NavigationServer3D.parse_source_geometry_data(
		navigation_mesh,
		source_geometry,
		source_root,
	)
	if not source_geometry.has_data():
		push_warning("Für das Pathfinding wurde keine Quellgeometrie gefunden.")
		_finish_rebake(false)
		return

	_bake_running = true
	NavigationServer3D.bake_from_source_geometry_data_async(
		navigation_mesh,
		source_geometry,
		_on_async_bake_finished,
	)


func _on_async_bake_finished() -> void:
	_finish_rebake(
		navigation_mesh != null
		and navigation_mesh.get_polygon_count() > 0,
	)


func _finish_rebake(success: bool) -> void:
	_bake_running = false
	navigation_ready = success
	enabled = success
	navigation_rebuilt.emit(success)

	if _rebake_after_current:
		_rebake_after_current = false
		request_rebake()
