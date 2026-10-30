extends SceneTree


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	var world := Node3D.new()
	root.add_child(world)

	var enemy_scene := load("res://scenes/enemies/basic_enemy.tscn") as PackedScene
	assert(enemy_scene != null)
	var enemy := enemy_scene.instantiate() as BasicEnemy
	assert(enemy != null)
	world.add_child(enemy)
	enemy.global_position = Vector3(2.0, 0.0, 3.0)

	assert(enemy.health == enemy.max_health)
	assert(enemy.get_world_info_text() == "Leben: 60/60")
	enemy.take_damage(25.0)
	assert(enemy.health == 35.0)
	assert(enemy.get_world_info_text() == "Leben: 35/60")
	var health_bar := enemy.get_node("HealthBar") as Node3D
	var health_bar_fill := enemy.get_node("HealthBar/Fill") as MeshInstance3D
	var health_bar_fill_mesh := health_bar_fill.mesh as QuadMesh
	assert(health_bar.visible)
	assert(is_equal_approx(health_bar_fill_mesh.size.x, 1.2 * 35.0 / 60.0))
	assert(is_equal_approx(
		health_bar_fill_mesh.center_offset.x,
		-(1.0 - 35.0 / 60.0) * 0.6,
	))
	assert(_count_damage_labels(world) == 1)

	enemy.take_damage(35.0)
	enemy.take_damage(1.0)
	assert(enemy.is_queued_for_deletion())
	assert(_count_damage_labels(world) == 2)

	var spawned_loot: ItemPickup = null
	for child in world.get_children():
		if child is ItemPickup:
			assert(spawned_loot == null)
			spawned_loot = child as ItemPickup

	assert(spawned_loot != null)
	assert(spawned_loot.item_id == &"stone")
	assert(spawned_loot.amount == 1)
	assert(not spawned_loot.world_id.is_empty())
	assert(spawned_loot.global_position.is_equal_approx(Vector3(2.0, 0.0, 3.0)))

	print("COMBAT_SMOKE_TEST_OK")
	quit()


func _count_damage_labels(world: Node3D) -> int:
	var label_count := 0
	for child in world.get_children():
		if child is Label3D:
			label_count += 1
	return label_count
