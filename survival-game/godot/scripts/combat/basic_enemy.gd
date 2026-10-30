class_name BasicEnemy
extends CharacterBody3D

## Einfacher Testgegner für Combat V1. Er verwendet zunächst direkte Bewegung
## und Kollisionen. Navigation um Gebäude und Mauern folgt erst, wenn der kleine
## Kampfkreislauf zuverlässig funktioniert.
@export var display_name := "Wandernder Blopp"
@export_range(1.0, 1000.0, 1.0) var max_health := 60.0
@export_range(0.1, 20.0, 0.1) var move_speed := 2.5
@export_range(1.0, 50.0, 0.5) var detection_range := 10.0
@export_range(0.5, 5.0, 0.1) var attack_range := 1.4
@export_range(1.0, 100.0, 1.0) var attack_damage := 10.0
@export_range(0.1, 10.0, 0.1) var attack_cooldown := 1.2
@export var loot_scene: PackedScene
@export var loot_item_id: StringName = &"stone"
@export_range(1, 99, 1) var loot_amount := 1

var health := 0.0
var attack_cooldown_remaining := 0.0
var target: Node3D
var hit_material: StandardMaterial3D
var enemy_base_color := Color(0.65, 0.12, 0.18, 1.0)
var hit_flash_tween: Tween
var health_bar_tween: Tween
var health_bar_fill_mesh: QuadMesh

@onready var body_mesh: MeshInstance3D = $MeshInstance3D
@onready var health_bar: Node3D = $HealthBar
@onready var health_bar_fill: MeshInstance3D = $HealthBar/Fill


## Initialisiert die Laufzeit-Lebenspunkte und sucht den Player unabhängig von
## seinem konkreten Szenenpfad über die gemeinsame Gruppe.
func _ready() -> void:
	health = max_health
	target = get_tree().get_first_node_in_group("player") as Node3D
	var source_material := body_mesh.get_active_material(0) as StandardMaterial3D
	if source_material != null:
		hit_material = source_material.duplicate() as StandardMaterial3D
		body_mesh.material_override = hit_material
		enemy_base_color = hit_material.albedo_color
	var source_fill_mesh := health_bar_fill.mesh as QuadMesh
	if source_fill_mesh != null:
		health_bar_fill_mesh = source_fill_mesh.duplicate() as QuadMesh
		health_bar_fill.mesh = health_bar_fill_mesh


func get_world_info_title() -> String:
	return display_name


func get_world_info_text() -> String:
	return "Leben: %d/%d" % [roundi(health), roundi(max_health)]


## Verfolgt den Player innerhalb der Erkennungsreichweite auf direktem Weg.
## Diese erste Combat-Version besitzt absichtlich noch kein Pathfinding um
## Gebäude. Innerhalb der Angriffsreichweite bleibt der Gegner stehen und fügt
## nur nach Ablauf seines Cooldowns erneut Schaden zu.
func _physics_process(delta: float) -> void:
	attack_cooldown_remaining = maxf(
		attack_cooldown_remaining - delta,
		0.0,
	)

	if not is_instance_valid(target):
		velocity = Vector3.ZERO
		target = get_tree().get_first_node_in_group("player") as Node3D
		if target == null:
			move_and_slide()
			return

	var direction_to_target := target.global_position - global_position
	direction_to_target.y = 0.0
	var distance_squared := direction_to_target.length_squared()

	if distance_squared > detection_range * detection_range:
		velocity = Vector3.ZERO
	elif distance_squared > attack_range * attack_range:
		var movement_direction := direction_to_target.normalized()
		velocity = Vector3(
			movement_direction.x * move_speed,
			0.0,
			movement_direction.z * move_speed,
		)
	else:
		velocity = Vector3.ZERO
		if attack_cooldown_remaining <= 0.0 and target.has_method("take_damage"):
			target.call("take_damage", attack_damage, self)
			attack_cooldown_remaining = attack_cooldown

	move_and_slide()


## Verarbeitet nur positiven Schaden. Die zusätzliche Lebensprüfung verhindert,
## dass mehrere Treffer während des bereits eingeleiteten Todes mehrfach Beute
## erzeugen. Jeder gültige Treffer löst gemeinsam den Materialblitz, die
## temporäre Lebensleiste und eine aufsteigende Schadenszahl aus.
func take_damage(amount: float, _attacker: Node3D = null) -> void:
	if amount <= 0.0 or health <= 0.0:
		return

	health = clampf(health - amount, 0.0, max_health)
	_play_hit_flash()
	_show_health_bar()
	_spawn_damage_number(amount)
	if health <= 0.0:
		_die()


func _play_hit_flash() -> void:
	## Ohne ein vorbereitetes Material gibt es keine Farbe, die animiert werden
	## kann. Der frühe Rücksprung verhindert deshalb einen Laufzeitfehler.
	if hit_material == null:
		return

	## Bei einem schnellen zweiten Treffer läuft möglicherweise noch der vorige
	## Tween. kill() verhindert, dass zwei Tweens dieselbe Farbe verändern.
	if hit_flash_tween != null:
		hit_flash_tween.kill()

	## Der eigentliche Treffer ist ein sofortiger Farbwechsel zu Weiß.
	hit_material.albedo_color = Color.WHITE

	## create_tween() liefert das Tween-Objekt. Dieses speichern wir, damit es
	## beim nächsten Treffer bei Bedarf beendet werden kann.
	hit_flash_tween = create_tween()

	## tween_property() verändert die angegebene Property über die Zeit. Der
	## Property-Pfad muss als String angegeben werden; Zielwert ist die zuvor
	## gespeicherte normale Gegnerfarbe.
	hit_flash_tween.tween_property(
		hit_material,
		"albedo_color",
		enemy_base_color,
		0.12,
	)


func _show_health_bar() -> void:
	## Größe und Mittelpunkt werden direkt am individuellen QuadMesh verändert.
	## Anders als eine Node3D-Position wird dieser Versatz gemeinsam mit dem
	## Billboard zur Kamera gedreht und bleibt dadurch innerhalb des Hintergrunds.
	var health_ratio := clampf(health / max_health, 0.0, 1.0)
	if health_bar_fill_mesh != null:
		var fill_size := health_bar_fill_mesh.size
		fill_size.x = 1.2 * health_ratio
		health_bar_fill_mesh.size = fill_size

		var center_offset := health_bar_fill_mesh.center_offset
		center_offset.x = -(1.0 - health_ratio) * 0.6
		health_bar_fill_mesh.center_offset = center_offset
	health_bar.visible = true

	## Ein neuer Treffer beginnt die zweisekündige Sichtbarkeit erneut.
	if health_bar_tween != null:
		health_bar_tween.kill()
	health_bar_tween = create_tween()
	health_bar_tween.tween_interval(2.0)
	health_bar_tween.tween_callback(func() -> void:
		health_bar.visible = false
	)


func _spawn_damage_number(amount: float) -> void:
	var world_parent := get_parent()
	if world_parent == null:
		return

	var damage_label := Label3D.new()
	damage_label.text = "-%d" % roundi(amount)
	damage_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	damage_label.no_depth_test = true
	damage_label.font_size = 48
	damage_label.outline_size = 8
	damage_label.modulate = Color(1.0, 0.3, 0.2, 1.0)
	world_parent.add_child(damage_label)
	damage_label.global_position = global_position + Vector3(0.0, 1.45, 0.0)

	## Das Label ist absichtlich ein Geschwisterknoten des Gegners. Dadurch kann
	## die Zahl des tödlichen Treffers weiterlaufen, obwohl der Gegner verschwindet.
	var target_position := damage_label.global_position + Vector3.UP
	var damage_tween := damage_label.create_tween().set_parallel()
	damage_tween.tween_property(
		damage_label,
		"global_position",
		target_position,
		0.6,
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	damage_tween.tween_property(damage_label, "modulate:a", 0.0, 0.6)
	damage_tween.chain().tween_callback(damage_label.queue_free)


## Erzeugt aus der vollständigen Pickup-Szene eine sicht- und kollidierbare
## Beute. Die eindeutige world_id eignet sich zugleich für das Auftragssystem.
## Auch ohne gültige Lootszene wird der besiegte Gegner zuverlässig entfernt.
func _die() -> void:
	var world_parent := get_parent()
	if loot_scene != null and world_parent != null:
		var loot := loot_scene.instantiate() as ItemPickup
		if loot != null:
			loot.amount = loot_amount
			loot.item_id = loot_item_id
			loot.world_id = StringName("enemy_loot_%d" % get_instance_id())
			world_parent.add_child(loot)
			loot.global_position = global_position

	queue_free()
