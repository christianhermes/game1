extends SceneTree

## Prüft, dass das beim Start neu gebackene NavigationMesh einen Bewohner um
## die feste Nordwand der ersten Ruine herumführt.


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var main_scene := load("res://main.tscn") as PackedScene
	assert(main_scene != null)

	var world = main_scene.instantiate()
	root.add_child(world)
	var navigation_region := world.get_node(
		"WorldNavigation",
	) as WorldNavigation3D
	assert(navigation_region != null)

	if not navigation_region.is_navigation_ready():
		var bake_success: bool = await navigation_region.navigation_rebuilt
		assert(bake_success)
	var navigation_map: RID = navigation_region.get_navigation_map()
	## Der Server kann die teure Kartensynchronisation im Hintergrund ausführen.
	## Der Test wartet begrenzt, bis die aktualisierte Region einen Pfad liefert.
	var waited_frames := 0
	var path := PackedVector3Array()
	while path.is_empty() and waited_frames < 120:
		await physics_frame
		waited_frames += 1
		path = NavigationServer3D.map_get_path(
			navigation_map,
			Vector3(-8.0, 0.3, -14.0),
			Vector3(-8.0, 0.3, -7.0),
			true,
		)

	assert(path.size() >= 3)

	var path_goes_around_wall := false
	for point in path:
		if point.x > -3.5 or point.x < -12.5:
			path_goes_around_wall = true
			break
	assert(path_goes_around_wall)

	print("BASE_NAVIGATION_SMOKE_TEST_OK")
	quit()
