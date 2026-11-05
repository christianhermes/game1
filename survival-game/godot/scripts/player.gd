extends CharacterBody3D

## Dieses Skript steuert die Bewegung und die Interaktionen des Spielers.
## Außerdem bildet es die Verbindung zwischen Hotbar, Inventar und Weltobjekten.

# Bewegungsgeschwindigkeit des Spielers in Metern pro Sekunde.
const SPEED := 6.0

## Schwerkraft und Floor Snap sorgen dafür, dass dieselbe Figur später auch
## Rampen, Treppen und tiefer liegende begehbare Flächen physisch verfolgen kann.
@export_range(1.0, 100.0, 1.0) var gravity_acceleration := 24.0

## Der Nahkampfangriff verwendet die Eingabeaktion attack und eine eigene
## AttackArea mit 1,8 Metern Radius. Schaden und Cooldown bleiben exportiert,
## damit sich das erste Kampfgefühl ohne Codeänderung abstimmen lässt.
@export_range(1.0, 100.0, 1.0) var attack_damage := 25.0
@export_range(0.1, 5.0, 0.1) var attack_cooldown := 0.6
@export_range(1.0, 360.0, 1.0) var attack_arc_degrees := 180.0
@export_range(0.05, 2.0, 0.05) var damage_immunity_duration := 0.45

## Nach einem gültigen Gegnertreffer schützt dieses kurze Zeitfenster den Player
## vor gleichzeitigem Meutenschaden. Es verhindert mehrere Treffer im selben
## Moment, ohne eine Ausweichrolle oder dauerhafte Unverwundbarkeit einzuführen.

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

# ID des aktuell übernommenen Auftrags. -1 bedeutet, dass kein Auftrag aktiv ist.
var current_job_id := -1

# Die Hotbar meldet hierhin, welcher Gegenstand gerade ausgewählt ist.
var selected_item_id: StringName = &""

var spawn_position := Vector3.ZERO
var attack_cooldown_remaining := 0.0
var facing_direction := Vector3.FORWARD
var attack_effect_tween: Tween
var hurt_feedback_tween: Tween
var player_material: StandardMaterial3D
var player_base_color := Color(0.36, 0.55, 0.86, 1.0)
var damage_immunity_remaining = 0.0

# Reichweite für Interaktionen und das Inventar des Spielers.
@onready var interaction_area: Area3D = $InteractionArea
@onready var attack_area: Area3D = $AttackArea
@onready var attack_effect: MeshInstance3D = $AttackEffect
@onready var body_mesh: MeshInstance3D = $MeshInstance3D
@onready var inventory: Inventory = $Inventory
@onready var stats: PlayerStats = $PlayerStats
@onready var selection_marker: MeshInstance3D = $SelectionMarker
@onready var navigation_agent: PathfindingAgent3D = $NavigationAgent3D

func _ready() -> void:
	spawn_position = global_position
	stats.died.connect(_on_died)
	var source_material := body_mesh.get_active_material(0) as StandardMaterial3D
	if source_material != null:
		player_material = source_material.duplicate() as StandardMaterial3D
		body_mesh.material_override = player_material
		player_base_color = player_material.albedo_color
	_prepare_attack_effect_mesh()

# Einheitlicher Eingang für alle Gegenstände. Die Restmenge bleibt beim
# Aufrufer, wenn das Inventar nicht genug Platz besitzt.
func receive_item(item_id: StringName, amount: int) -> int:
	return inventory.add_item(item_id, amount)


## Prüft einen einzelnen Output vor einer unteilbaren Aktion wie einer Ernte.
func can_receive_item(item_id: StringName, amount: int) -> bool:
	return inventory.can_add_item(item_id, amount)


## Prüft mehrere Outputs gemeinsam, damit sie nicht denselben freien Slot planen.
func can_receive_items(item_amounts: Array[ItemAmount]) -> bool:
	return inventory.can_add_items(item_amounts)


func set_direct_control_enabled(enabled: bool) -> void:
	direct_control_enabled = enabled
	if direct_control_enabled:
		cancel_current_job()
	else:
		velocity = Vector3.ZERO


# Der Player besitzt seine eigene Auswahldarstellung. Das Hauptskript muss
# dadurch nicht wissen, wie der Marker technisch aufgebaut ist.
func set_selected(selected: bool) -> void:
	selection_marker.visible = selected


## Zeigt im Basismodus die wichtigsten Bewohnerwerte und den aktuellen
## Tätigkeitszustand im gemeinsamen Auswahlfenster an.
func get_world_info_title() -> String:
	return "Bewohner: %s" % name


func get_world_info_text() -> String:
	var activity := "Bereit"
	if direct_control_enabled:
		activity = "Direkte Steuerung"
	elif current_job_id >= 0:
		activity = "Arbeitet (Auftrag %d)" % current_job_id
	elif navigation_agent.has_destination:
		activity = "Unterwegs"

	var lines: Array[String] = [
		"Status: %s" % activity,
		"Leben: %d/%d" % [roundi(stats.health), roundi(stats.max_health)],
		"Mana: %d/%d" % [roundi(stats.mana), roundi(stats.max_mana)],
		"Hunger: %d/%d" % [roundi(stats.hunger), roundi(stats.max_hunger)],
	]
	if not selected_item_id.is_empty():
		lines.append("Ausgewählt: %s" % String(selected_item_id).capitalize())
	return "\n".join(lines)


# Liefert die szenenunabhängige ID dieses Bewohners für neue Aufträge.
func get_worker_id() -> StringName:
	return worker_id


# Der Aufrufer nennt nur das Ziel. Welchen Weg der Bewohner dorthin nimmt,
# entscheidet der NavigationAgent3D.
func set_move_target(target_position: Vector3) -> void:
	navigation_agent.set_destination(target_position)


# Beendet nur die aktuelle Bewegung. Die spätere Auftragslogik entscheidet
# separat, ob der zugehörige Auftrag fortgesetzt oder abgebrochen wird.
func cancel_move_target() -> void:
	navigation_agent.cancel_destination()
	velocity = Vector3.ZERO


# _physics_process() läuft in einem festen Takt und ist für Bewegung gedacht.
# Der Angriff ist nur während der direkten Charaktersteuerung verfügbar. Sein
# Cooldown läuft unabhängig von Bewegung und frühen Rückgaben einmal pro Takt.
func _physics_process(delta: float) -> void:
	var direct_input_available := can_move and direct_control_enabled
	_apply_gravity(delta)
	attack_cooldown_remaining = maxf(
		attack_cooldown_remaining - delta,
		0.0,
	)
	damage_immunity_remaining = maxf(
		damage_immunity_remaining - delta,
		0.0,
	)
	# "interact" ist eine Aktion aus den Eingabe-Einstellungen des Projekts.
	if direct_input_available and Input.is_action_just_pressed("interact"):
		_try_interact()

	if direct_input_available and Input.is_action_just_pressed("use_selected_item"):
		_try_consume_selected_item()

	# Bei gesperrter Bewegung wird vorhandene Geschwindigkeit sofort beendet.
	if not direct_input_available:
		velocity.x = 0.0
		velocity.z = 0.0
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
	if direction.length_squared() > 0.0:
		facing_direction = direction.normalized()

	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

	# CharacterBody3D bewegt sich und berücksichtigt dabei Kollisionen.
	move_and_slide()
	if direct_input_available and Input.is_action_just_pressed("attack"):
		_try_attack()


## Der NavigationAgent berechnet nur einen Weg. Die tatsächliche Höhenbewegung
## bleibt Aufgabe des CharacterBody, damit Kollision, Gefälle und Stürze korrekt
## mit der Weltphysik zusammenarbeiten.
func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= gravity_acceleration * delta


func _try_attack() -> void:
	if attack_cooldown_remaining > 0.0:
		return
	attack_cooldown_remaining = attack_cooldown
	_play_attack_effect()

	var minimum_direction_dot := cos(deg_to_rad(attack_arc_degrees * 0.5))
	for body in attack_area.get_overlapping_bodies():
		if not body.is_in_group("enemies") or not body.has_method("take_damage"):
			continue

		var enemy := body as Node3D
		if enemy == null:
			continue

		var direction_to_enemy := enemy.global_position - global_position
		direction_to_enemy.y = 0.0
		if direction_to_enemy.length_squared() > 0.0:
			direction_to_enemy = direction_to_enemy.normalized()
			## Eine kleine Toleranz schließt Gegner exakt auf der 90-Grad-Grenze
			## zuverlässig in den gewünschten 180-Grad-Halbkreis ein.
			if facing_direction.dot(direction_to_enemy) < minimum_direction_dot - 0.0001:
				continue

		enemy.call("take_damage", attack_damage, self)


## Erzeugt aus Dreiecksstreifen einen sichtbaren Ringabschnitt, dessen Winkel
## exakt zum Gameplay-Wert attack_arc_degrees passt. So zeigt der Effekt keine
## größere Trefferfläche an, als der Angriff tatsächlich besitzt.
func _prepare_attack_effect_mesh() -> void:
	var placeholder_mesh := attack_effect.mesh as TorusMesh
	if placeholder_mesh == null:
		return
	var effect_material := placeholder_mesh.material
	var arc_mesh := ImmediateMesh.new()
	var segment_count := 24
	var half_arc_radians := deg_to_rad(attack_arc_degrees * 0.5)

	arc_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP, effect_material)
	for segment_index in range(segment_count + 1):
		var progress := float(segment_index) / float(segment_count)
		var angle := lerpf(-half_arc_radians, half_arc_radians, progress)
		var arc_direction := Vector3(sin(angle), 0.0, -cos(angle))

		arc_mesh.surface_set_normal(Vector3.UP)
		arc_mesh.surface_add_vertex(arc_direction * 1.35)
		arc_mesh.surface_set_normal(Vector3.UP)
		arc_mesh.surface_add_vertex(arc_direction * 1.8)
	arc_mesh.surface_end()
	attack_effect.mesh = arc_mesh


func _play_attack_effect() -> void:
	if attack_effect_tween != null:
		attack_effect_tween.kill()
	attack_effect.rotation.y = atan2(-facing_direction.x, -facing_direction.z)
	attack_effect.scale = Vector3.ONE * 0.25
	attack_effect.visible = true
	attack_effect_tween = create_tween()
	attack_effect_tween.tween_property(
		attack_effect,
		"scale",
		Vector3.ONE,
		0.16,
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	attack_effect_tween.tween_callback(func() -> void:
		attack_effect.visible = false
	)


## Leitet gültigen Schaden an die bereits zentrale PlayerStats-Lebenslogik
## weiter. Der optionale Angreifer kann später für Aggro oder Todesursachen
## ausgewertet werden. Bereits verlorenes Leben erzeugt kein weiteres visuelles
## Trefferfeedback während der Respawn-Wartezeit.
func take_damage(amount: float, _attacker: Node3D = null) -> void:
	if damage_immunity_remaining > 0.0:
		return
	if amount <= 0.0 or stats.health <= 0.0:
		return
	stats.take_damage(amount)
	_play_hurt_feedback()
	damage_immunity_remaining = damage_immunity_duration


func _play_hurt_feedback() -> void:
	if player_material == null:
		return
	if hurt_feedback_tween != null:
		hurt_feedback_tween.kill()
	player_material.albedo_color = Color(1.0, 0.12, 0.08, 1.0)
	hurt_feedback_tween = create_tween()
	hurt_feedback_tween.tween_property(
		player_material,
		"albedo_color",
		player_base_color,
		0.18,
	)


func _update_autonomous_movement() -> void:
	if not navigation_agent.has_destination:
		return

	var direction := navigation_agent.get_next_movement_direction(global_position)
	if not navigation_agent.has_destination:
		velocity = Vector3.ZERO
		if navigation_agent.last_result == PathfindingAgent3D.DestinationResult.REACHED:
			_complete_current_job()
		elif current_job_id >= 0:
			SettlementJobManager.cancel_job(current_job_id)
			current_job_id = -1
		return

	# Die wiederverwendbare Komponente liefert nur die Richtung. Der Bewohner
	# behält dadurch seine eigene Geschwindigkeit und CharacterBody-Bewegung.
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


# Autonome Aufträge verwenden Gegenstände direkt aus dem Inventar und sind
# dadurch unabhängig von der aktuell ausgewählten Hotbar-Position.
func try_use_item(item_id: StringName, amount: int) -> bool:
	return inventory.remove_item(item_id, amount)


func has_item(item_id: StringName, amount: int = 1) -> bool:
	return inventory.get_amount(item_id) >= amount

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
# Übernimmt einen passenden offenen Auftrag, startet seinen Status und setzt
# die gespeicherte Zielposition als autonomes Bewegungsziel.
func assign_job(job_id: int) -> bool:
	var job = SettlementJobManager.get_job(job_id)
	if job.is_empty():
		return false
	if job["worker_id"] != worker_id:
		return false
	if !SettlementJobManager.start_job(job_id):
		return false

	current_job_id = job_id
	set_move_target(job["target_position"])
	return true


# Löst eine gespeicherte, szenenunabhängige Ziel-ID wieder zu dem aktuell
# geladenen Weltobjekt aus der Gruppe job_targets auf.
func _find_job_target(target_id: StringName) -> Node3D:
	var targets = get_tree().get_nodes_in_group("job_targets")
	for target in targets:
		if target.has_method("get_job_target_id"):
			if target.get_job_target_id() == target_id:
				return target

	return null


# Prüft sowohl die lokale Job-ID als auch den Status im gemeinsamen Manager.
# Asynchrone Arbeiten erkennen damit auch während eines Timers, ob ein neuer
# Befehl den ursprünglichen Auftrag inzwischen abgebrochen hat.
func is_current_job(job_id: int) -> bool:
	if current_job_id != job_id:
		return false

	var job := SettlementJobManager.get_job(job_id)

	if job.is_empty():
		return false

	return job["status"] == SettlementJobManager.JobStatus.RUNNING


# Führt einen zielgebundenen Auftrag nach Erreichen seines Bewegungsziels aus.
# Pickups und Ressourcenquellen werden synchron über interact() abgeschlossen.
# Bei BUILD wartet der Bewohner dagegen auf den vollständigen, zeitgesteuerten
# Bauvorgang und schützt einen zwischenzeitlich erteilten neuen Auftrag.
func _complete_current_job() -> void:
	var target = null
	if current_job_id < 0:
		return
	var job = SettlementJobManager.get_job(current_job_id)
	if job.is_empty():
		current_job_id = -1
		return
	match job["type"]:
		# Alle zielgebundenen Aufträge lösen ihre gespeicherte Welt-ID erst nach
		# dem Laufweg wieder zum aktuell geladenen Node auf.
		SettlementJobManager.JobType.PICKUP, SettlementJobManager.JobType.EXTRACT_RESOURCE, SettlementJobManager.JobType.BUILD:
			target = _find_job_target(job["target_id"])

	if job["type"] == SettlementJobManager.JobType.BUILD:
		var active_job_id := current_job_id

		if target == null or not target.has_method("perform_build_job"):
			SettlementJobManager.cancel_job(active_job_id)
			current_job_id = -1
			return

		var building_finished: bool = await target.perform_build_job(
			self,
			active_job_id,
		)

		# Während await kann ein neuer Befehl current_job_id geändert haben. Der
		# alte Ablauf darf diesen neuen Auftrag weder beenden noch zurücksetzen.
		if current_job_id != active_job_id:
			return

		if building_finished:
			SettlementJobManager.finish_job(active_job_id)
		else:
			SettlementJobManager.cancel_job(active_job_id)

		current_job_id = -1
		return

	if target != null and target.has_method("interact"):
		target.call("interact", self)
	if SettlementJobManager.finish_job(current_job_id):
		current_job_id = -1


# Bricht einen aktiven Auftrag im Manager ab und beendet unabhängig davon auch
# einen reinen Laufbefehl, der keinen gespeicherten Auftrag besitzt.
func cancel_current_job() -> void:
	if current_job_id >= 0:
		SettlementJobManager.cancel_job(current_job_id)
	current_job_id = -1
	cancel_move_target()
