extends SceneTree

## Prüft die wiederverwendbare Actor-Komponente gegen das tatsächlich zur
## Laufzeit gebackene NavMesh der Basis. Die Figur wird dabei nicht bewegt;
## getestet wird bewusst nur die Verantwortung des PathfindingAgent3D.


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var main_scene := load("res://main.tscn") as PackedScene
	assert(main_scene != null)

	var world := main_scene.instantiate()
	root.add_child(world)
	var navigation_region := world.get_node(
		"WorldNavigation",
	) as WorldNavigation3D
	var player := world.get_node("Player") as CharacterBody3D
	var pathfinding_agent := player.get_node(
		"NavigationAgent3D",
	) as PathfindingAgent3D
	assert(navigation_region != null)
	assert(pathfinding_agent != null)

	if not navigation_region.is_navigation_ready():
		var bake_success: bool = await navigation_region.navigation_rebuilt
		assert(bake_success)

	# Ein Ziel auf derselben begehbaren Basisfläche muss nach der asynchronen
	# Kartensynchronisation eine verwertbare Laufrichtung liefern.
	pathfinding_agent.set_destination(Vector3(8.0, 0.3, 8.0))
	var direction := Vector3.ZERO
	var waited_frames := 0
	while direction.is_zero_approx() and waited_frames < 120:
		await physics_frame
		waited_frames += 1
		direction = pathfinding_agent.get_next_movement_direction(
			player.global_position,
		)

	assert(pathfinding_agent.has_destination)
	assert(not direction.is_zero_approx())
	assert(is_zero_approx(direction.y))

	pathfinding_agent.cancel_destination()
	assert(not pathfinding_agent.has_destination)

	# Pickups werden am sichtbaren Objekt und damit oberhalb des Bodens
	# angeklickt. Das Ende des dazu auf das NavMesh projizierten Bodenpfads muss
	# trotzdem als erreicht gelten, damit der Pickup-Auftrag ausgeführt wird.
	var elevated_target := player.global_position + Vector3.UP * 2.0
	pathfinding_agent.set_destination(elevated_target)
	waited_frames = 0
	while pathfinding_agent.has_destination and waited_frames < 120:
		await physics_frame
		waited_frames += 1
		pathfinding_agent.get_next_movement_direction(player.global_position)

	assert(not pathfinding_agent.has_destination)
	assert(
		pathfinding_agent.last_result
		== PathfindingAgent3D.DestinationResult.REACHED
	)
	print("PATHFINDING_AGENT_SMOKE_TEST_OK")
	quit()
