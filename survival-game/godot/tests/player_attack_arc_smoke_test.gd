extends SceneTree

## Prüft den vollständigen kleinen Meuten-Kampfkreislauf: Der Halbkreis trifft
## alle vorderen Ziele, Hit-Stun und Rückstoß zeigen vom Player weg und der
## Schadensschutz verhindert mehrere nahezu gleichzeitige Gegnertreffer.


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var main_scene := load("res://main.tscn") as PackedScene
	var enemy_scene := load("res://scenes/enemies/basic_enemy.tscn") as PackedScene
	assert(main_scene != null and enemy_scene != null)

	var world := main_scene.instantiate() as Node3D
	root.add_child(world)
	var player := world.get_node("Player") as CharacterBody3D
	assert(player != null)
	player.set_physics_process(false)
	player.set("facing_direction", Vector3.FORWARD)

	var player_position := player.global_position
	var front_left := _create_enemy(
		enemy_scene,
		world,
		player_position + Vector3(-0.8, 0.0, -1.0),
	)
	var front_right := _create_enemy(
		enemy_scene,
		world,
		player_position + Vector3(0.8, 0.0, -1.0),
	)
	var behind := _create_enemy(
		enemy_scene,
		world,
		player_position + Vector3(0.0, 0.0, 1.0),
	)
	var arc_boundary := _create_enemy(
		enemy_scene,
		world,
		player_position + Vector3(1.0, 0.0, 0.0),
	)

	## Die Physik benötigt einen Takt, um die neu erzeugten Gegner in der
	## AttackArea zu registrieren.
	await physics_frame
	player.call("_try_attack")

	assert(front_left.health == 35.0)
	assert(front_right.health == 35.0)
	assert(arc_boundary.health == 35.0)
	assert(behind.health == 60.0)
	assert(front_left.hit_stun_remaining > 0.0)
	assert(front_right.hit_stun_remaining > 0.0)
	assert(arc_boundary.hit_stun_remaining > 0.0)
	assert(behind.hit_stun_remaining == 0.0)

	_assert_knockback_points_away_from_player(front_left, player)
	_assert_knockback_points_away_from_player(front_right, player)
	_assert_knockback_points_away_from_player(arc_boundary, player)

	var stats := player.get_node("PlayerStats") as PlayerStats
	assert(stats != null)
	var initial_health := stats.health
	player.take_damage(10.0, front_left)
	player.take_damage(10.0, front_right)
	assert(is_equal_approx(stats.health, initial_health - 10.0))

	## Der Player war für den Angriffstest angehalten. Für diese kurze Wartezeit
	## wird nur sein Physikprozess aktiviert, damit der Immunitätstimer abläuft.
	player.set_physics_process(true)
	await create_timer(player.damage_immunity_duration + 0.05).timeout
	player.set_physics_process(false)
	player.take_damage(10.0, front_left)
	assert(is_equal_approx(stats.health, initial_health - 20.0))

	print("PLAYER_ATTACK_ARC_SMOKE_TEST_OK")
	quit()


func _assert_knockback_points_away_from_player(
	enemy: BasicEnemy,
	player: Node3D,
) -> void:
	assert(enemy.knockback_velocity.length_squared() > 0.0)
	var direction_from_player := enemy.global_position - player.global_position
	direction_from_player.y = 0.0
	assert(direction_from_player.length_squared() > 0.0)
	var direction_dot := enemy.knockback_velocity.normalized().dot(
		direction_from_player.normalized(),
	)
	assert(direction_dot > 0.99)


func _create_enemy(
	enemy_scene: PackedScene,
	world: Node3D,
	spawn_position: Vector3,
) -> BasicEnemy:
	var enemy := enemy_scene.instantiate() as BasicEnemy
	assert(enemy != null)
	world.add_child(enemy)
	enemy.global_position = spawn_position
	enemy.set_physics_process(false)
	return enemy
