extends SceneTree

## Baut im Test eine durchgehende Wand quer über die Basiskarte. Der einzige
## mögliche Weg von Süden nach Norden führt durch die Holztür in ihrer Mitte.


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var main_scene := load("res://main.tscn") as PackedScene
	var door_scene := load(
		"res://scenes/buildings/WoodDoor.tscn",
	) as PackedScene
	assert(main_scene != null)
	assert(door_scene != null)

	var world := main_scene.instantiate()
	root.add_child(world)
	_add_barrier_segment(world, Vector3(-10.5, 1.5, 0.0))
	_add_barrier_segment(world, Vector3(10.5, 1.5, 0.0))
	var door := door_scene.instantiate() as Node3D
	world.add_child(door)
	door.global_position = Vector3.ZERO

	var navigation_region := world.get_node(
		"WorldNavigation",
	) as WorldNavigation3D
	assert(navigation_region != null)
	if not navigation_region.is_navigation_ready():
		var bake_success: bool = await navigation_region.navigation_rebuilt
		assert(bake_success)

	var navigation_map := navigation_region.get_navigation_map()
	var path := PackedVector3Array()
	var waited_frames := 0
	while path.is_empty() and waited_frames < 120:
		await physics_frame
		waited_frames += 1
		path = NavigationServer3D.map_get_path(
			navigation_map,
			Vector3(0.0, 0.3, -3.0),
			Vector3(0.0, 0.3, 3.0),
			true,
		)

	assert(path.size() >= 2)
	for point in path:
		assert(absf(point.x) < 1.0)

	print("DOOR_NAVIGATION_SMOKE_TEST_OK")
	quit()


func _add_barrier_segment(parent: Node, position: Vector3) -> void:
	var body := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(19.0, 3.0, 0.3)
	collision.shape = shape
	body.add_child(collision)
	parent.add_child(body)
	body.global_position = position
