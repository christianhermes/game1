class_name BuildGrid
extends Node

## Zentrale logische Baukarte. Eine Rasterkoordinate besteht aus X, Stockwerk Y
## und Z. Verschiedene Belegungsschichten dürfen dieselbe Zelle gemeinsam
## verwenden, beispielsweise Fundament, Boden und Einrichtung.

const CELL_SIZE := 2.0
const LEVEL_HEIGHT := 2.0

var foundation_occupancy: Dictionary = {}
var floor_occupancy: Dictionary = {}
var object_occupancy: Dictionary = {}
var wall_edge_occupancy: Dictionary = {}


## Ordnet eine Weltposition ihrer logischen Rasterzelle und Höhenebene zu.
## floori() sorgt dafür, dass die Zuordnung auch links vom Weltursprung stimmt.
func world_to_cell(world_position: Vector3) -> Vector3i:
	return Vector3i(
		floori(world_position.x / CELL_SIZE),
		floori(world_position.y / LEVEL_HEIGHT),
		floori(world_position.z / CELL_SIZE),
	)


## Liefert die Weltposition in der Mitte einer Rasterzelle. X und Z liegen in
## der Zellmitte; Y beschreibt die Unterkante der jeweiligen Höhenebene.
func cell_to_world(cell: Vector3i) -> Vector3:
	return Vector3(
		(cell.x + 0.5) * CELL_SIZE,
		cell.y * LEVEL_HEIGHT,
		(cell.z + 0.5) * CELL_SIZE,
	)


## Ordnet eine Weltposition der nächstgelegenen Wandkante in der gewünschten
## Richtung zu. X-Wände liegen auf einer Z-Grenze, Z-Wände auf einer X-Grenze.
func world_to_wall_edge(
	world_position: Vector3,
	rotation_quarters: int,
) -> Vector3i:
	var normalized_rotation := posmod(rotation_quarters, 4)
	if normalized_rotation % 2 == 0:
		return Vector3i(
			floori(world_position.x / CELL_SIZE),
			floori(world_position.y / LEVEL_HEIGHT),
			roundi(world_position.z / CELL_SIZE),
		)

	return Vector3i(
		roundi(world_position.x / CELL_SIZE),
		floori(world_position.y / LEVEL_HEIGHT),
		floori(world_position.z / CELL_SIZE),
	)


## Liefert die Weltposition im Mittelpunkt einer logischen Wandkante.
func wall_edge_to_world(
	origin: Vector3i,
	rotation_quarters: int,
) -> Vector3:
	var normalized_rotation := posmod(rotation_quarters, 4)
	if normalized_rotation % 2 == 0:
		return Vector3(
			(origin.x + 0.5) * CELL_SIZE,
			origin.y * LEVEL_HEIGHT,
			origin.z * CELL_SIZE,
		)

	return Vector3(
		origin.x * CELL_SIZE,
		origin.y * LEVEL_HEIGHT,
		(origin.z + 0.5) * CELL_SIZE,
	)


## Liefert sämtliche Zellen einer rechteckigen Grundfläche. Bei einer Drehung
## um 90 oder 270 Grad werden Breite und Tiefe miteinander vertauscht.
func get_footprint_cells(
	origin: Vector3i,
	footprint: Vector2i,
	rotation_quarters: int,
) -> Array[Vector3i]:
	var normalized_rotation := posmod(rotation_quarters, 4)
	var occupied_size := footprint
	if normalized_rotation % 2 == 1:
		occupied_size = Vector2i(footprint.y, footprint.x)

	var occupied_cells: Array[Vector3i] = []
	for local_x in range(occupied_size.x):
		for local_z in range(occupied_size.y):
			occupied_cells.append(Vector3i(
				origin.x + local_x,
				origin.y,
				origin.z + local_z,
			))

	return occupied_cells


## Erzeugt einen stabilen Schlüssel aus Richtung und Rasterursprung. Gegenüber-
## liegende Drehungen verwenden dadurch dieselbe logische Wandkante.
func get_wall_edge_key(
	origin: Vector3i,
	rotation_quarters: int,
) -> StringName:
	var normalized_rotation := posmod(rotation_quarters, 4)
	var direction := "x"
	if normalized_rotation % 2 == 1:
		direction = "z"

	return StringName("%s_%d_%d_%d" % [
		direction,
		origin.x,
		origin.y,
		origin.z,
	])


# Gibt für flächige Platzierungen das zu ihrem Typ gehörende Dictionary zurück.
# So kann beispielsweise ein Boden dieselbe Zelle wie ein Fundament belegen,
# während zwei Böden auf derselben Zelle miteinander kollidieren.
func _get_cell_occupancy(placement_type: BuildRecipe.PlacementType) -> Dictionary:
	match placement_type:
		BuildRecipe.PlacementType.FOUNDATION:
			return foundation_occupancy
		BuildRecipe.PlacementType.FLOOR:
			return floor_occupancy
		BuildRecipe.PlacementType.OBJECT:
			return object_occupancy
		_:
			return {}


## Prüft ausschließlich die zum Rezept gehörende Belegungsschicht. Eine Wand
## verwendet ihren Kantenschlüssel, alle anderen Bauarten ihre Footprint-Zellen.
func can_place(
	recipe: BuildRecipe,
	origin: Vector3i,
	rotation_quarters: int,
) -> bool:
	if recipe == null or not recipe.is_placement_data_valid():
		return false

	if recipe.placement_type == BuildRecipe.PlacementType.WALL_EDGE:
		var edge_key := get_wall_edge_key(origin, rotation_quarters)
		return not wall_edge_occupancy.has(edge_key)

	var occupancy := _get_cell_occupancy(recipe.placement_type)
	var occupied_cells := get_footprint_cells(
		origin,
		recipe.footprint,
		rotation_quarters,
	)
	for cell in occupied_cells:
		if occupancy.has(cell):
			return false

	return true


## Reserviert nach einer vollständigen Belegungsprüfung sämtliche benötigten
## Kanten oder Zellen für den übergebenen Owner.
func register_placement(
	recipe: BuildRecipe,
	origin: Vector3i,
	rotation_quarters: int,
	owner: Node,
) -> bool:
	if owner == null or not can_place(recipe, origin, rotation_quarters):
		return false

	if recipe.placement_type == BuildRecipe.PlacementType.WALL_EDGE:
		var edge_key := get_wall_edge_key(origin, rotation_quarters)
		wall_edge_occupancy[edge_key] = owner
		return true

	var occupancy := _get_cell_occupancy(recipe.placement_type)
	var occupied_cells := get_footprint_cells(
		origin,
		recipe.footprint,
		rotation_quarters,
	)
	for cell in occupied_cells:
		occupancy[cell] = owner

	return true


# Liefert alle Belegungsschichten, damit Entfernen und Übertragen nicht viermal
# mit fast identischem Code geschrieben werden müssen.
func _get_all_occupancies() -> Array[Dictionary]:
	return [
		foundation_occupancy,
		floor_occupancy,
		object_occupancy,
		wall_edge_occupancy,
	]


## Entfernt alle Reservierungen eines Owners. Die Keys werden zuerst gesammelt,
## damit kein Dictionary verändert wird, während darüber iteriert wird.
func unregister_owner(owner: Node) -> void:
	for occupancy in _get_all_occupancies():
		var keys_to_remove: Array = []
		for key in occupancy:
			if occupancy[key] == owner:
				keys_to_remove.append(key)

		for key in keys_to_remove:
			occupancy.erase(key)


## Überträgt bestehende Reservierungen auf einen neuen Owner, ohne die
## zugehörigen Kanten oder Zellen zwischenzeitlich freizugeben.
func replace_owner(current_owner: Node, new_owner: Node) -> void:
	if current_owner == null or new_owner == null:
		return

	for occupancy in _get_all_occupancies():
		for key in occupancy:
			if occupancy[key] == current_owner:
				occupancy[key] = new_owner
