class_name PathfindingAgent3D
extends NavigationAgent3D

## Wiederverwendbare Wegfindungskomponente für Bewohner, Gegner und spätere
## Spezialbewegungen. Das WorldNavigation3D liefert den Weg; diese Komponente
## verwaltet Ziel, Wartezeit und die gewünschte Bewegungsrichtung des Actors.

enum MovementMode {
	## Für laufende Figuren: Die Höhe steckt im NavMesh, bewegt wird entlang der
	## Bodenebene. Rampen und Treppen erhöhen den CharacterBody durch Kollisionen.
	GROUND,
	## Behält auch den Höhenanteil eines Wegpunkts bei. Das ist für besondere
	## Bodenbewegungen und vertikale NavigationLinks gedacht, aber nicht für ein
	## frei befliegbares 3D-Volumen: Ein NavigationMesh bleibt eine Oberfläche.
	FULL_3D,
}

enum DestinationResult {
	NONE,
	REACHED,
	FAILED,
}

signal destination_reached
signal destination_failed

@export var movement_mode := MovementMode.GROUND
@export var ground_up_direction := Vector3.UP
@export_range(0.1, 10.0, 0.1) var path_calculation_timeout := 2.0

var has_destination := false
var last_result := DestinationResult.NONE
var _path_request_started_msec := 0
var _waiting_for_navigation_map := false


func set_destination(world_position: Vector3) -> void:
	target_position = world_position
	has_destination = true
	last_result = DestinationResult.NONE
	_path_request_started_msec = 0
	_waiting_for_navigation_map = true


func cancel_destination() -> void:
	has_destination = false
	last_result = DestinationResult.NONE
	_path_request_started_msec = 0
	_waiting_for_navigation_map = false


## Liefert nur die Richtung; Geschwindigkeit, Schwerkraft und move_and_slide()
## bleiben beim CharacterBody. Dadurch kann dieselbe Komponente von Actors mit
## unterschiedlichen Laufgeschwindigkeiten und Bewegungsregeln genutzt werden.
func get_next_movement_direction(actor_position: Vector3) -> Vector3:
	if not has_destination:
		return Vector3.ZERO

	var navigation_map := get_navigation_map()
	if (
		not navigation_map.is_valid()
		or NavigationServer3D.map_get_iteration_id(navigation_map) == 0
	):
		return Vector3.ZERO
	if _waiting_for_navigation_map:
		# Die Laufzeitkarte kann noch gebacken werden. Der eigentliche Pfad-Timeout
		# beginnt erst, sobald der NavigationServer diese Karte synchronisiert hat.
		_waiting_for_navigation_map = false
		_path_request_started_msec = Time.get_ticks_msec()

	# Dieser Aufruf aktualisiert den internen Pfad des NavigationAgent3D und muss
	# deshalb vor der Pfadprüfung erfolgen.
	var next_path_position := get_next_path_position()
	if is_target_reached():
		_finish_destination(DestinationResult.REACHED)
		return Vector3.ZERO

	# Direkt nach einer Zieländerung benötigt NavigationAgent3D mindestens einen
	# Server-Takt. Ein noch leerer Pfad bedeutet in dieser Zeit nicht "angekommen".
	if get_current_navigation_path().is_empty():
		if _has_path_calculation_timed_out():
			_finish_destination(DestinationResult.FAILED)
		return Vector3.ZERO

	# Ein Weltobjekt liegt oft etwas über oder neben der begehbaren Fläche. Für
	# Bodenaufträge bedeutet das Ende des berechneten Weges deshalb "angekommen".
	# Ob das Objekt dort wirklich benutzbar ist, prüft anschließend der Auftrag.
	if is_navigation_finished():
		_finish_destination(DestinationResult.REACHED)
		return Vector3.ZERO

	var direction := next_path_position - actor_position
	if movement_mode == MovementMode.GROUND:
		var normalized_up := ground_up_direction.normalized()
		direction -= normalized_up * direction.dot(normalized_up)

	if direction.length_squared() <= 0.0001:
		return Vector3.ZERO
	return direction.normalized()


func _has_path_calculation_timed_out() -> bool:
	if _path_request_started_msec == 0:
		return false
	var elapsed_seconds := (
		Time.get_ticks_msec() - _path_request_started_msec
	) / 1000.0
	return elapsed_seconds >= path_calculation_timeout


func _finish_destination(result: DestinationResult) -> void:
	has_destination = false
	last_result = result
	_path_request_started_msec = 0
	_waiting_for_navigation_map = false
	if result == DestinationResult.REACHED:
		destination_reached.emit()
	elif result == DestinationResult.FAILED:
		destination_failed.emit()
