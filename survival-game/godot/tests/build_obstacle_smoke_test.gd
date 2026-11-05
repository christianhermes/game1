extends SceneTree

## Prüft, dass feste Weltgrenzen Bauplätze blockieren, während die Kartenmitte
## und der vorgesehene südliche Ausgang weiterhin als freie Fläche gelten.


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var main_scene := load("res://main.tscn") as PackedScene
	var foundation_recipe = load(
		"res://data/buildings/wood_foundation.tres",
	)
	assert(main_scene != null and foundation_recipe != null)

	var world := main_scene.instantiate() as Node3D
	root.add_child(world)
	var build_manager := world.get_node("BuildManager")
	assert(build_manager != null)

	## Die von CSGBox3D erzeugten Kollisionskörper werden erst im Physiktakt
	## vollständig in den Space aufgenommen.
	await physics_frame
	await physics_frame

	assert(_is_blocked(build_manager, Vector3(19.0, 0.0, 1.0), foundation_recipe))
	assert(_is_blocked(build_manager, Vector3(-19.0, 0.0, 1.0), foundation_recipe))
	assert(_is_blocked(build_manager, Vector3(1.0, 0.0, -19.0), foundation_recipe))
	assert(_is_blocked(build_manager, Vector3(11.0, 0.0, 19.0), foundation_recipe))
	assert(_is_blocked(build_manager, Vector3(-7.0, 0.0, -11.0), foundation_recipe))
	assert(_is_blocked(build_manager, Vector3(-11.0, 0.0, -7.0), foundation_recipe))
	assert(_is_blocked(build_manager, Vector3(-3.0, 0.0, -9.0), foundation_recipe))
	assert(not _is_blocked(build_manager, Vector3.ZERO, foundation_recipe))
	assert(not _is_blocked(build_manager, Vector3(1.0, 0.0, 19.0), foundation_recipe))
	assert(not _is_blocked(build_manager, Vector3(-7.0, 0.0, -7.0), foundation_recipe))

	print("BUILD_OBSTACLE_SMOKE_TEST_OK")
	quit()


func _is_blocked(
	build_manager: Node,
	position: Vector3,
	recipe: Resource,
) -> bool:
	return build_manager.call(
		"_is_blocked_by_world_obstacle",
		position,
		recipe,
		0,
	)
