extends CharacterBody3D

## Dieses Skript steuert die Bewegung und die Interaktionen des Spielers.
## Außerdem bildet es die Verbindung zwischen Hotbar, Inventar und Weltobjekten.

# Bewegungsgeschwindigkeit des Spielers in Metern pro Sekunde.
const SPEED := 6.0

#was stillt wieviel Hunger
const RAW_WHEAT_HUNGER := 10.0
const BREAD_HUNGER := 40.0
# Kann später genutzt werden, um Bewegung etwa in Menüs zu sperren.
var can_move := true

# Die Hotbar meldet hierhin, welcher Gegenstand gerade ausgewählt ist.
var selected_item_id: StringName = &""

var spawn_position := Vector3.ZERO

# Reichweite für Interaktionen und das Inventar des Spielers.
@onready var interaction_area: Area3D = $InteractionArea
@onready var inventory: Inventory = $Inventory
@onready var stats: PlayerStats = $PlayerStats

func _ready() -> void:
	spawn_position = global_position
	stats.died.connect(_on_died)

# Einheitlicher Eingang für alle Gegenstände, die der Spieler erhält.
func receive_item(item_id: StringName, amount: int) -> void:
	inventory.add_item(item_id, amount)


# _physics_process() läuft in einem festen Takt und ist für Bewegung gedacht.
func _physics_process(_delta: float) -> void:
	# "interact" ist eine Aktion aus den Eingabe-Einstellungen des Projekts.
	if can_move and Input.is_action_just_pressed("interact"):
		_try_interact()

	if can_move and Input.is_action_just_pressed("use_selected_item"):
		_try_consume_selected_item()
	
	# Bei gesperrter Bewegung wird vorhandene Geschwindigkeit sofort beendet.
	if not can_move:
		velocity = Vector3.ZERO
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
