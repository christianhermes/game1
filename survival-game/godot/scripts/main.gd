extends Node3D

## Dieses Skript gehört zur Hauptszene und verbindet die wichtigsten Teile
## der Spielwelt. Im Moment kümmert es sich vor allem um die Kamera und gibt
## dem Spieler beim Spielstart sein erstes Saatgut.

# Abstand der Kamera zum Spieler. Die drei Werte stehen für X, Y und Z.
const CAMERA_OFFSET := Vector3(22.0, 25.0, 22.0)

# Bestimmt, wie schnell die Kamera dem Spieler folgt.
const CAMERA_FOLLOW_SPEED := 6.0

# @onready bedeutet: Godot sucht diese Nodes erst, wenn die Szene bereit ist.
@onready var camera: Camera3D = $Camera3D
@onready var player: CharacterBody3D = $Player

# Diese Position ist das Ziel, auf das die Kamera schaut.
var camera_target := Vector3.ZERO


# _ready() wird einmal aufgerufen, nachdem die Szene vollständig geladen wurde.
func _ready() -> void:
	# Die Kamera beginnt direkt über der aktuellen Position des Spielers.
	camera_target = player.global_position
	_update_camera()

	# Startausrüstung: Der Spieler erhält drei Weizenkörner.
	player.receive_item(&"wheat_seed", 3)
	player.receive_item(&"hammer", 1)


# _process() wird in jedem dargestellten Bild aufgerufen.
func _process(delta: float) -> void:
	# delta macht die Bewegung unabhängig von der Bildrate.
	var follow_weight := clampf(CAMERA_FOLLOW_SPEED * delta, 0.0, 1.0)

	# lerp nähert das Kameraziel weich an die Spielerposition an.
	camera_target = camera_target.lerp(player.global_position, follow_weight)
	_update_camera()


# Setzt die Kamera an ihre versetzte Position und richtet sie auf das Ziel aus.
func _update_camera() -> void:
	camera.global_position = camera_target + CAMERA_OFFSET
	camera.look_at(camera_target, Vector3.UP)
