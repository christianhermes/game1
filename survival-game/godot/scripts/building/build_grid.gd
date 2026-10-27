class_name BuildGrid
extends Node

## Zentrale logische Baukarte. Eine Rasterkoordinate besteht aus X, Stockwerk Y
## und Z. Verschiedene Belegungsschichten dürfen dieselbe Zelle gemeinsam
## verwenden, beispielsweise Fundament, Boden und Einrichtung.

const CELL_SIZE := 2.0
# Drei Meter pro Ebene lassen einem zwei Meter hohen Bewohner ausreichend
# Kopffreiheit unter einer Boden- beziehungsweise Deckenplatte.
const LEVEL_HEIGHT := 3.0

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

## Prüft, ob eine Rasterzelle sowohl einen Boden als auch eine Decke besitzt.
## Die Decke ist derselbe Bodentyp genau eine logische Ebene höher. Die drei
## Meter LEVEL_HEIGHT werden erst bei der Umrechnung in Weltkoordinaten benutzt.
func _has_floor_and_ceiling(cell: Vector3i) -> bool:
	# Vector3i.UP erhöht die logische Ebenennummer um eins, nicht um drei Meter.
	var ceiling_cell := cell + Vector3i.UP
	return (
		floor_occupancy.has(cell)
		and floor_occupancy.has(ceiling_cell)
	)


## Prüft, ob zwischen einer Zelle und ihrem direkten horizontalen Nachbarn eine
## Wand oder Tür liegt. Beide Bauarten belegen dieselbe Wandkanten-Schicht.
## Nord und Süd verwenden X-Kanten, West und Ost verwenden Z-Kanten.
func _has_wall_between(cell: Vector3i, direction: Vector3i) -> bool:
	# Der Kantenursprung beginnt an der nordwestlichen Ecke der Zelle. Nur Süd
	# und Ost müssen auf die jeweils gegenüberliegende Rastergrenze verschoben werden.
	var edge_origin := cell
	var rotation_quarters := 0

	if direction == Vector3i(0, 0, -1):
		# Nordkante: X-Richtung am unveränderten Zellursprung.
		rotation_quarters = 0
	elif direction == Vector3i(0, 0, 1):
		# Südkante: X-Richtung an der nächsten Z-Grenze.
		edge_origin.z += 1
		rotation_quarters = 0
	elif direction == Vector3i(-1, 0, 0):
		# Westkante: Z-Richtung am unveränderten Zellursprung.
		rotation_quarters = 1
	elif direction == Vector3i(1, 0, 0):
		# Ostkante: Z-Richtung an der nächsten X-Grenze.
		edge_origin.x += 1
		rotation_quarters = 1
	else:
		# Diagonale und vertikale Richtungen sind keine Zellseiten.
		return false

	var edge_key := get_wall_edge_key(edge_origin, rotation_quarters)
	return wall_edge_occupancy.has(edge_key)


## Sucht von einer Startzelle aus alle verbundenen Zellen eines geschlossenen
## Raums. Ein leeres Ergebnis bedeutet, dass Boden, Decke oder eine Begrenzung
## fehlt. Türen zählen wie Wände als geschlossene Raumkante.
func find_closed_room(start_cell: Vector3i) -> Array[Vector3i]:
	# Nur die vier horizontalen Nachbarn gehören zur aktuellen Stockwerksebene.
	var directions: Array[Vector3i] = [
		Vector3i(-1, 0, 0),
		Vector3i(1, 0, 0),
		Vector3i(0, 0, -1),
		Vector3i(0, 0, 1),
	]
	var cells_to_check: Array[Vector3i] = [start_cell]
	var visited: Dictionary = {}
	var room_cells: Array[Vector3i] = []

	while not cells_to_check.is_empty():
		# Die letzte vorgemerkte Zelle wird entnommen. Für das Ergebnis ist es
		# unerheblich, ob die Liste als Stapel oder Warteschlange abgearbeitet wird.
		var current_cell: Vector3i = cells_to_check.pop_back()

		# Eine bereits geprüfte Zelle darf weder erneut ausgewertet noch erneut
		# in das Ergebnis aufgenommen werden.
		if visited.has(current_cell):
			continue

		# Erreicht die Suche eine Zelle ohne vollständige Flächen, führt dort eine
		# Öffnung aus dem Raum. Das bisherige Teilergebnis wird deshalb verworfen.
		if not _has_floor_and_ceiling(current_cell):
			return room_cells

		visited[current_cell] = true

		for direction in directions:
			# Eine vorhandene Wand oder Tür beendet die Suche nur an dieser Seite.
			if _has_wall_between(current_cell, direction):
				continue

			# Ohne Begrenzung gehört der direkte Nachbar zum selben möglichen Raum
			# und wird später vollständig auf Boden und Decke geprüft.
			var neighbor: Vector3i = current_cell + direction
			if not visited.has(neighbor):
				cells_to_check.append(neighbor)

	# Dictionary-Keys werden zum klar typisierten Ergebnisarray übertragen.
	for visited_cell in visited:
		room_cells.append(visited_cell)

	return room_cells


## Liefert die Raumangaben für ein ausgewähltes Boden- oder Deckenbauteil.
## Andere Bauarten erhalten keinen Zusatztext. Bei einer Decke wird zusätzlich
## die Zelle darunter geprüft, weil dieselbe Platte dort den Raum abschließt.
func get_room_info_for_owner(owner: Node) -> String:
	if owner == null:
		return ""

	var owner_is_floor := false
	var checked_start_cells: Dictionary = {}
	for occupied_cell in floor_occupancy:
		if floor_occupancy[occupied_cell] != owner:
			continue

		owner_is_floor = true
		var start_candidates: Array[Vector3i] = [
			occupied_cell,
			occupied_cell - Vector3i.UP,
		]
		for start_cell in start_candidates:
			# Mehrzellige Böden können dieselbe mögliche Raumzelle mehrfach liefern.
			if checked_start_cells.has(start_cell):
				continue
			checked_start_cells[start_cell] = true

			var room_cells := find_closed_room(start_cell)
			if room_cells.is_empty():
				continue

			var area_square_meters := roundi(
				room_cells.size() * CELL_SIZE * CELL_SIZE,
			)
			return "Raum: Geschlossen\nGröße: %d Zellen (%d m²)" % [
				room_cells.size(),
				area_square_meters,
			]

	if owner_is_floor:
		return "Raum: Offen oder unvollständig"

	return ""
