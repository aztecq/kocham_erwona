class_name StructureGenerator extends Node

enum StructureType { House, Castle }
enum TileType { DIRT, SAND, BEDROCK, HUMUS, FLOOR, WALL }

static func create_structure():
	var floor = create_floor()
	var floor_border = get_border_cells(floor)
	#var walls = create_walls(floor_border)

 
static func create_walls(floor_borders: Array[Array]):
	pass


static func create_floor():
	var room1 = Rect2i(0, 0, randi_range(3, 6), randi_range(3, 6))
	var room2 = Rect2i(0, 0, randi_range(3, 6), randi_range(3, 6))
		
	while !is_intersection_valid(room1, room2):
		room2.position = Vector2i(
			randi_range(1 - room2.size.x, room1.size.x - 1),
			randi_range(1 - room2.size.y, room1.size.y - 1)
		)
	
	var bounds := room1.merge(room2)
	room1.position -= bounds.position
	room2.position -= bounds.position
	var floor_width := bounds.size.x
	var floor_height := bounds.size.y
	
	var grid := []
	for y in bounds.size.y + 2:
		var row: Array[int] = []
		row.resize(bounds.size.x + 2)
		grid.append(row)

	for r in [room1, room2]:
		for y in range(r.position.y + 1, r.end.y + 1):
			for x in range(r.position.x + 1, r.end.x + 1):
				grid[y][x] = 1
	return grid
	

static func is_intersection_valid(r1: Rect2i, r2: Rect2i) -> bool:
	var intersect_area = r1.intersection(r2).get_area()
	return intersect_area > 0 and intersect_area < r1.get_area() and intersect_area < r2.get_area()
	
	
const NEIGHBORS_8 := [
	Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
	Vector2i(-1,  0),                  Vector2i(1,  0),
	Vector2i(-1,  1), Vector2i(0,  1), Vector2i(1,  1),
]

static func get_border_cells(grid: Array) -> Array[Vector2i]:
	var height := grid.size()
	var width: int = grid[0].size()
	var seen := {}
	var border: Array[Vector2i] = []

	for y in height:
		for x in width:
			if grid[y][x] != 1:
				continue
			for d in NEIGHBORS_8:
				var n: Vector2i = Vector2i(x, y) + d
				if seen.has(n):
					continue
				if grid[n.y][n.x] == 0:
					seen[n] = true
					border.append(n)
	return border
