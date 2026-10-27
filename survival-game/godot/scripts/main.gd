extends Node3D

## Dieses Skript gehört zur Hauptszene und verbindet die wichtigsten Teile
## der Spielwelt. Es verwaltet außerdem den Wechsel zwischen direkter
## Charaktersteuerung und der freien Basisübersicht.

enum ControlMode {
	CHARACTER,
	BASE,
}

# Abstand der Kamera zum Spieler. Die drei Werte stehen für X, Y und Z.
const CAMERA_OFFSET := Vector3(22.0, 25.0, 22.0)

# Bestimmt, wie schnell die Kamera dem Spieler folgt.
const CAMERA_FOLLOW_SPEED := 6.0
const DEFAULT_CAMERA_SIZE := 27.0
const BASE_CAMERA_PAN_SPEED := 18.0
const BASE_CAMERA_ROTATION_SPEED := 1.5
const BASE_CAMERA_MIN_SIZE := 10.0
const BASE_CAMERA_MAX_SIZE := 45.0
const BASE_CAMERA_ZOOM_STEP := 2.0

# @onready bedeutet: Godot sucht diese Nodes erst, wenn die Szene bereit ist.
@onready var camera: Camera3D = $Camera3D
@onready var player: CharacterBody3D = $Player
@onready var build_grid: BuildGrid = $BuildGrid
@onready var build_manager: BuildManager = $BuildManager
@onready var hotbar = $UI/Hotbar
@onready var control_mode_label: Label = $UI/ControlModeLabel
@onready var workstation_menu = $UI/WorkstationMenu
@onready var world_info_panel = $UI/WorldInfoPanel
@onready var build_menu = $UI/BuildMenu

# Diese Position ist das Ziel, auf das die Kamera schaut.
var camera_target := Vector3.ZERO
var control_mode := ControlMode.CHARACTER
var base_camera_yaw := 0.0
var base_camera_size := DEFAULT_CAMERA_SIZE

# Speichert den Bewohner, der im Basismodus aktuell ausgewählt ist.
var selected_actor: Node3D = null


# _ready() wird einmal aufgerufen, nachdem die Szene vollständig geladen wurde.
func _ready() -> void:
	# Die Kamera beginnt direkt über der aktuellen Position des Spielers.
	camera_target = player.global_position
	camera.size = DEFAULT_CAMERA_SIZE
	_apply_control_mode()
	_update_camera()
	_prepare_build_menu()

	# Startausrüstung: Der Spieler erhält drei Weizenkörner.
	player.receive_item(&"wheat_seed", 3)
	player.receive_item(&"hammer", 1)


## Übergibt den gültigen Baukatalog an das Menü und verbindet Auswahl sowie
## Sichtbarkeit genau einmal mit dem BuildManager. Das Menü bleibt bis zum
## Aktivieren des Baumodus geschlossen.
func _prepare_build_menu() -> void:
	build_menu.visible = false
	build_menu.set_recipes(build_manager.get_available_recipes())
	if not build_menu.recipe_selected.is_connected(build_manager.select_recipe):
		build_menu.recipe_selected.connect(build_manager.select_recipe)

	if not build_manager.build_mode_changed.is_connected(build_menu.set_catalog_visible):
		build_manager.build_mode_changed.connect(build_menu.set_catalog_visible)


# _process() wird in jedem dargestellten Bild aufgerufen.
func _process(delta: float) -> void:
	if control_mode == ControlMode.CHARACTER:
		# lerp nähert das Kameraziel weich an die Spielerposition an.
		var follow_weight := clampf(CAMERA_FOLLOW_SPEED * delta, 0.0, 1.0)
		camera_target = camera_target.lerp(player.global_position, follow_weight)
	else:
		_update_base_camera_input(delta)

	_update_camera()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_control_mode"):
		if control_mode == ControlMode.CHARACTER:
			control_mode = ControlMode.BASE
		else:
			control_mode = ControlMode.CHARACTER

		_apply_control_mode()
		get_viewport().set_input_as_handled()
		return

	if control_mode != ControlMode.BASE:
		return

	if event is InputEventMouseButton and event.pressed:
		# Kein Mausklick auf HUD oder Fenster darf durch die Oberfläche hindurch
		# einen Weltbefehl, eine Auswahl oder einen Bauabbruch auslösen.
		if get_viewport().gui_get_hovered_control() != null:
			return

		if event.button_index == MOUSE_BUTTON_LEFT:
			# Im Baumodus platziert der Linksklick eine Baustelle und darf nicht
			# zusätzlich die normale Auswahl in der Welt auslösen.
			if build_manager.is_build_mode_active():
				build_manager.try_place_construction_site()
				get_viewport().set_input_as_handled()
				return
			_select_at_mouse(event.position)
			get_viewport().set_input_as_handled()
			return
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			# Im Baumodus hat der kontrollierte Baustellenabbruch Vorrang. Ein
			# Rechtsklick auf andere Ziele bleibt der normale Bewohnerbefehl.
			if (
				build_manager.is_build_mode_active()
				and build_manager.try_cancel_construction_site(event.position)
			):
				get_viewport().set_input_as_handled()
				return

			_command_selected_actor(event.position)
			get_viewport().set_input_as_handled()
			return
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			base_camera_size -= BASE_CAMERA_ZOOM_STEP
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			base_camera_size += BASE_CAMERA_ZOOM_STEP
		else:
			return

		base_camera_size = clampf(
			base_camera_size,
			BASE_CAMERA_MIN_SIZE,
			BASE_CAMERA_MAX_SIZE,
		)
		camera.size = base_camera_size
		get_viewport().set_input_as_handled()


# Wandelt die zweidimensionale Mausposition in einen Strahl durch die
# dreidimensionale Spielwelt um und fragt den ersten getroffenen Körper ab.
func _select_at_mouse(mouse_position: Vector2) -> void:
	var ray_origin := camera.project_ray_origin(mouse_position)
	var ray_direction := camera.project_ray_normal(mouse_position)
	var ray_end := ray_origin + ray_direction * 1000.0

	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end,
	)
	# Arbeitsstationen sind Area3D-Nodes und müssen bei der Auswahl ausdrücklich
	# in die Raycast-Abfrage aufgenommen werden.
	query.collide_with_areas = true
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	
	# Wenn hit leer ist, soll die bisherige Auswahl aufgehoben werden.
	if hit.is_empty():
		workstation_menu.close_menu()
		world_info_panel.close_panel()
		_set_selected_actor(null)
	else:
		var collider: Object = hit.get("collider")
		# Jedes Weltobjekt entscheidet selbst, welche Informationen es anbietet.
		# Unbekannte Treffer (zum Beispiel der Boden) schließen das Fenster.
		var selected_node := collider as Node
		var room_info := ""
		if selected_node != null:
			# Das Raster ergänzt nur bei fertigen Boden- oder Deckenbauteilen einen
			# Raumstatus. Alle anderen Elemente behalten ihre bisherige Anzeige.
			room_info = build_grid.get_room_info_for_owner(selected_node)
		world_info_panel.show_target(selected_node, room_info)
		if collider is ProcessingStation:
			_set_selected_actor(null)
			workstation_menu.open_for_station(collider as ProcessingStation)
			return

		workstation_menu.close_menu()
		# Wähle nur Nodes aus der Gruppe selectable als Bewohner aus. Ein Treffer
		# auf ein anderes Objekt hebt die bisherige Auswahl auf.
		if collider != null and collider.is_in_group("selectable"):
			_set_selected_actor(collider)
		else:
			_set_selected_actor(null)


	


# Diese Methode soll immer zuerst die alte Auswahl ausschalten und danach
# den neuen Actor speichern und sichtbar markieren.
func _set_selected_actor(actor: Node3D) -> void:
	if selected_actor and selected_actor.has_method("set_selected"):
		selected_actor.set_selected(false)

	selected_actor = actor

	if selected_actor and selected_actor.has_method("set_selected"):
		selected_actor.set_selected(true)


# Ersetzt den bisherigen Befehl des ausgewählten Bewohners durch einen
# zielabhängigen Weltauftrag oder einen Laufbefehl zur angeklickten Position.
func _command_selected_actor(mouse_position: Vector2) -> void:
	if selected_actor == null:
		return
	if not selected_actor.has_method("set_move_target"):
		return
	var ray_origin := camera.project_ray_origin(mouse_position)
	var ray_direction := camera.project_ray_normal(mouse_position)
	var ray_end := ray_origin + ray_direction * 1000.0

	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end,
	)
	# Pickups sind Area3D-Nodes. Ohne diese Option würde der Ray durch sie
	# hindurchgehen und stattdessen den Boden darunter treffen.
	query.collide_with_areas = true
	# Der Raycast liefert neben dem getroffenen Objekt auch die genaue
	# Trefferposition in der 3D-Welt.
	var hit := get_world_3d().direct_space_state.intersect_ray(query)

	# Ohne Treffer kann kein gültiges Bewegungsziel vergeben werden.
	if hit.is_empty():
		return

	# Jeder gültige neue Befehl ersetzt den bisherigen Auftrag und dessen
	# Bewegungsziel. Dadurch bleibt kein alter RUNNING-Auftrag zurück.
	if selected_actor.has_method("cancel_current_job"):
		selected_actor.call("cancel_current_job")

	var collider: Object = hit.get("collider")
	if (
		collider != null
		and collider.has_method("get_job_target_id")
		and collider.has_method("get_job_type")
		and selected_actor.has_method("get_worker_id")
		and selected_actor.has_method("assign_job")
	):
		# Stabile Ziel- und Bewohner-IDs halten den Auftrag unabhängig von den
		# aktuell geladenen Nodes. Der Manager liefert seine eindeutige ID zurück.
		var job_id: int = SettlementJobManager.create_job(
			collider.get_job_type(),
			collider.get_job_target_id(),
			hit.get("position"),
			selected_actor.get_worker_id()
		)
		# Die Ausgabe macht die Auftragserstellung während des Prototyps sichtbar.
		print("Neuer Auftrag: ", job_id)
		if selected_actor.assign_job(job_id):
			return

		# Eine fehlgeschlagene Übernahme darf keinen offenen Auftrag im Manager
		# zurücklassen und wird nicht als gewöhnlicher Laufbefehl ausgeführt.
		SettlementJobManager.cancel_job(job_id)
		return

	# Der ausgewählte Bewohner entscheidet mit seinem NavigationAgent3D selbst,
	# welchen begehbaren Weg er zu dieser Position nimmt.
	selected_actor.set_move_target(hit.get("position"))


func _update_base_camera_input(delta: float) -> void:
	var input := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward",
	)

	var forward := -camera.global_basis.z
	var right := camera.global_basis.x
	forward.y = 0.0
	right.y = 0.0
	forward = forward.normalized()
	right = right.normalized()

	var pan_direction := right * input.x - forward * input.y
	if pan_direction.length_squared() > 0.0:
		camera_target += (
			pan_direction.normalized()
			* BASE_CAMERA_PAN_SPEED
			* delta
		)

	var rotation_input := Input.get_axis(
		"rotate_camera_left",
		"rotate_camera_right",
	)
	base_camera_yaw += (
		rotation_input
		* BASE_CAMERA_ROTATION_SPEED
		* delta
	)


func _apply_control_mode() -> void:
	var base_mode_active := control_mode == ControlMode.BASE
	player.set_direct_control_enabled(not base_mode_active)
	build_manager.set_control_enabled(base_mode_active)
	hotbar.set_mouse_wheel_enabled(not base_mode_active)

	if base_mode_active:
		camera_target = player.global_position
		camera.size = base_camera_size
		control_mode_label.text = (
			"BASISMODUS\n"
			+ "Tab: Charakter | WASD: Kamera | Q/E: Kamera drehen | Mausrad: Zoom | B: Bauen | R: Bauteil drehen"
		)
	else:
		workstation_menu.close_menu()
		world_info_panel.close_panel()
		camera_target = player.global_position
		camera.size = DEFAULT_CAMERA_SIZE
		control_mode_label.text = (
			"CHARAKTERMODUS\n"
			+ "Tab: Basis | WASD: Laufen | F: Interagieren | E: Benutzen"
		)


# Setzt die Kamera an ihre versetzte Position und richtet sie auf das Ziel aus.
func _update_camera() -> void:
	var camera_offset := CAMERA_OFFSET
	if control_mode == ControlMode.BASE:
		camera_offset = CAMERA_OFFSET.rotated(Vector3.UP, base_camera_yaw)

	camera.global_position = camera_target + camera_offset
	camera.look_at(camera_target, Vector3.UP)
