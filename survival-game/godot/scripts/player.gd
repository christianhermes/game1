extends CharacterBody3D

## Dieses Skript steuert die Bewegung und die Interaktionen des Spielers.
## Außerdem bildet es die Verbindung zwischen Hotbar, Inventar und Weltobjekten.

# Bewegungsgeschwindigkeit des Spielers in Metern pro Sekunde.
const SPEED := 6.0

# Diese ID verbindet den sichtbaren CharacterBody3D mit seinen persistenten
# Aufträgen im SettlementJobManager.
@export var worker_id: StringName = &"player"

#was stillt wieviel Hunger
const RAW_WHEAT_HUNGER := 10.0
const BREAD_HUNGER := 40.0
# Kann später genutzt werden, um Bewegung etwa in Menüs zu sperren.
var can_move := true

# Der Spielmodus entscheidet, ob der Spieler gerade direkt gesteuert wird.
# Das ist bewusst von can_move getrennt, damit Tod oder Menüs weiterhin
# unabhängig vom Basis-/Charaktermodus Bewegung sperren können.
var direct_control_enabled := true

# Die Hotbar meldet hierhin, welcher Gegenstand gerade ausgewählt ist.
var selected_item_id: StringName = &""

var spawn_position := Vector3.ZERO

# Zeigt an, ob der Bewohner aktuell einem Laufauftrag folgt.
var has_move_target := false

# Reichweite für Interaktionen und das Inventar des Spielers.
@onready var interaction_area: Area3D = $InteractionArea
@onready var inventory: Inventory = $Inventory
@onready var stats: PlayerStats = $PlayerStats
@onready var selection_marker: MeshInstance3D = $SelectionMarker
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

func _ready() -> void:
	spawn_position = global_position
	stats.died.connect(_on_died)

# Einheitlicher Eingang für alle Gegenstände, die der Spieler erhält.
func receive_item(item_id: StringName, amount: int) -> void:
	inventory.add_item(item_id, amount)


func set_direct_control_enabled(enabled: bool) -> void:
	direct_control_enabled = enabled
	if direct_control_enabled:
		cancel_move_target()
	else:
		velocity = Vector3.ZERO


# Der Player besitzt seine eigene Auswahldarstellung. Das Hauptskript muss
# dadurch nicht wissen, wie der Marker technisch aufgebaut ist.
func set_selected(selected: bool) -> void:
	selection_marker.visible = selected


# Liefert die szenenunabhängige ID dieses Bewohners für neue Aufträge.
func get_worker_id() -> StringName:
	return worker_id


# Der Aufrufer nennt nur das Ziel. Welchen Weg der Bewohner dorthin nimmt,
# entscheidet der NavigationAgent3D.
func set_move_target(target_position: Vector3) -> void:
	navigation_agent.target_position = target_position
	has_move_target = true


# Beendet den aktuellen Laufauftrag. Der gespeicherte Status verhindert, dass
# ein alter Auftrag beim nächsten Wechsel in den Basismodus fortgesetzt wird.
func cancel_move_target() -> void:
	has_move_target = false
	velocity = Vector3.ZERO


# _physics_process() läuft in einem festen Takt und ist für Bewegung gedacht.
func _physics_process(_delta: float) -> void:
	var direct_input_available := can_move and direct_control_enabled

	# "interact" ist eine Aktion aus den Eingabe-Einstellungen des Projekts.
	if direct_input_available and Input.is_action_just_pressed("interact"):
		_try_interact()

	if direct_input_available and Input.is_action_just_pressed("use_selected_item"):
		_try_consume_selected_item()
	
	# Bei gesperrter Bewegung wird vorhandene Geschwindigkeit sofort beendet.
	if not direct_input_available:
		velocity = Vector3.ZERO
		if can_move and not direct_control_enabled:
			_update_autonomous_movement()
		move_and_slide()
		return

	# Input.get_vector verbindet vier Tasten zu einem zweidimensionalen Vektor.
	var input := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward",
	)

	# Die Bewegungsrichtung wird aus der Blickrichtung der Kamera berechnet.
	# Dadurch bedeutet W auf dem Bildschirm immer "nach vorne".
	var camera := get_viewport().get_camera_3d()
	var forward := -camera.global_basis.z
	var right := camera.global_basis.x

	# Die Y-Anteile werden entfernt, damit der Spieler am Boden bleibt.
	forward.y = 0.0
	right.y = 0.0
	forward = forward.normalized()
	right = right.normalized()

	var direction := right * input.x + forward * input.y

	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

	# CharacterBody3D bewegt sich und berücksichtigt dabei Kollisionen.
	move_and_slide()


func _update_autonomous_movement() -> void:
	if not has_move_target:
		return

	if navigation_agent.is_navigation_finished():
		has_move_target = false
		return

	# Der NavigationAgent3D liefert in jedem Physikschritt den nächsten Punkt
	# seines berechneten Weges und nicht sofort das endgültige Ziel.
	var next_path_position := navigation_agent.get_next_path_position()

	# Ziel minus aktuelle Position ergibt die Bewegungsrichtung. Der Y-Anteil
	# wird entfernt, damit der CharacterBody3D auf dem Boden bleibt.
	var direction := next_path_position - global_position
	direction.y = 0.0
	direction = direction.normalized()

	# Dieselbe Geschwindigkeit wie bei direkter WASD-Steuerung wird verwendet.
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED


# Sucht innerhalb der InteractionArea das nächstgelegene passende Objekt.
func _try_interact() -> void:
	var closest_interactable: Area3D = null
	var closest_distance := INF

	for area in interaction_area.get_overlapping_areas():
		# Nur Nodes aus dieser Gruppe gelten als interaktiv.
		if not area.is_in_group("interactable"):
			continue

		# Das Objekt muss die gemeinsame Methode interact() anbieten.
		if not area.has_method("interact"):
			continue

		# Die quadrierte Entfernung ist für einen Vergleich ausreichend und
		# vermeidet eine unnötige Quadratwurzel.
		var distance := global_position.distance_squared_to(
			area.global_position,
		)

		if distance < closest_distance:
			closest_distance = distance
			closest_interactable = area

	# call() ruft die gemeinsame Interaktionsmethode dynamisch auf.
	if closest_interactable != null:
		closest_interactable.call("interact", self)


# Empfänger des Signals selected_item_changed aus der Hotbar.
func _on_hotbar_selected_item_changed(item_id: StringName) -> void:
	selected_item_id = item_id


# Wird von einem Weltobjekt aufgerufen, das einen ausgewählten Gegenstand
# verbrauchen möchte, zum Beispiel vom Feld beim Pflanzen.
func try_use_selected_item(required_item_id: StringName, amount: int) -> bool:
	# Besitz allein genügt nicht: Das richtige Item muss ausgewählt sein.
	if selected_item_id != required_item_id:
		return false

	# remove_item() liefert false, wenn die benötigte Menge nicht vorhanden ist.
	return inventory.remove_item(required_item_id, amount)


func _try_consume_selected_item() -> void:
	match selected_item_id:
		&"wheat":
			if stats.hunger >= stats.max_hunger:
				return
			if try_use_selected_item(&"wheat", 1):
				stats.eat(RAW_WHEAT_HUNGER)
		&"bread":
			if stats.hunger >= stats.max_hunger:
				return
			if try_use_selected_item(&"bread", 1):
				stats.eat(BREAD_HUNGER)


func _on_died() -> void:
	can_move = false
	velocity = Vector3.ZERO

	await get_tree().create_timer(2.0).timeout

	global_position = spawn_position
	stats.reset_stats()
	can_move = true


func has_selected_item(required_item_id: StringName) -> bool:
	return (
		selected_item_id == required_item_id
		and inventory.get_amount(required_item_id) > 0
	)
