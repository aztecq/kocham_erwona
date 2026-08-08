class_name StructureGenerator extends Node

# Walls never stand higher than this many layers above the floor. The layer stack has to
# reserve that many layers above the one a structure's floor lands on.
const MAX_WALL_HEIGHT := 3

const MIN_ROOMS := 2
const MAX_ROOMS := 3
const ROOM_MIN_SIZE := 3
const ROOM_MAX_SIZE := 6
# Rooms are placed by trial: a room that can't find a spot against its anchor is dropped
# rather than retried forever.
const PLACEMENT_ATTEMPTS := 24

# How far the height noise is stretched before it's cut into levels. Raw noise clumps
# around zero, so without this nearly every wall would come out mid height.
const HEIGHT_NOISE_SPREAD := 0.5
const HEIGHT_NOISE_FREQUENCY := 0.28

# Chance a standing wall cell loses its top block. Kept off cells of height 1 so chipping
# never opens the outline — that's what breaches are for.
const WALL_CHIP_CHANCE := 0.25
# Chance a wall cell starts a run of fully collapsed cells.
const WALL_BREACH_CHANCE := 0.04
const WALL_BREACH_MAX_RUN := 3
# One gap is always cut, so a ruin is never sealed shut.
const DOORWAY_WIDTH := 2

const FLOOR_HOLE_CHANCE := 0.06

# An empty cell with at least this many of its eight neighbours already floor is too
# tight to be worth walling, and gets filled in instead.
const NARROW_GAP_NEIGHBORS := 6

const NEIGHBORS_4 := [
	Vector2i(0, -1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, 1),
]

const NEIGHBORS_8 := [
	Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
	Vector2i(-1,  0),                  Vector2i(1,  0),
	Vector2i(-1,  1), Vector2i(0,  1), Vector2i(1,  1),
]


# A generated ruin in its own local grid, walls included: cell (0, 0) is the top-left of
# the wall ring, so the whole thing stamps into the world from a single origin.
class Structure extends RefCounted:
	var size: Vector2i
	# 1 where the ruin has a floor tile. Wall cells carry one too, as a foundation.
	var floor_cells: Array
	# Number of wall levels standing on each cell, 0 where the wall is gone or never was.
	var wall_height: Array

	func is_floor(cell: Vector2i) -> bool:
		return _at(floor_cells, cell) == 1

	# `level` counts up from the floor: level 0 is the first block above it.
	func is_wall(level: int, cell: Vector2i) -> bool:
		return level < _at(wall_height, cell)

	func _at(grid: Array, cell: Vector2i) -> int:
		if cell.y < 0 or cell.y >= grid.size() or cell.x < 0 or cell.x >= grid[cell.y].size():
			return 0
		return grid[cell.y][cell.x]


static func create_structure() -> Structure:
	var structure := Structure.new()
	structure.floor_cells = create_floor()
	structure.size = Vector2i(structure.floor_cells[0].size(), structure.floor_cells.size())

	# The wall ring is taken from the intact floor: punching holes in the floor first
	# would let walls grow into the middle of the ruin.
	var exterior := get_exterior_cells(structure.floor_cells)
	fill_gaps(structure.floor_cells, exterior)
	var border := get_border_cells(structure.floor_cells, exterior)
	structure.wall_height = create_wall_heights(border, structure.size)
	damage_walls(structure.wall_height, border)

	lay_foundations(structure.floor_cells, structure.wall_height, border)
	damage_floor(structure.floor_cells, structure.wall_height)
	return structure


# --- floor ---------------------------------------------------------------------------

# Overlapping rooms merged into one outline, with a one cell margin all round for the
# walls to stand on.
static func create_floor() -> Array:
	var rooms: Array[Rect2i] = [Rect2i(Vector2i.ZERO, random_room_size())]
	for i in randi_range(MIN_ROOMS, MAX_ROOMS) - 1:
		var room := place_room(rooms)
		if room.has_area():
			rooms.append(room)

	var bounds := rooms[0]
	for room in rooms:
		bounds = bounds.merge(room)

	var grid := new_grid(bounds.size + Vector2i(2, 2))
	for room in rooms:
		# Shifted so the outline sits at (1, 1), leaving the margin ring at index 0.
		var offset := Vector2i.ONE - bounds.position
		for y in range(room.position.y + offset.y, room.end.y + offset.y):
			for x in range(room.position.x + offset.x, room.end.x + offset.x):
				grid[y][x] = 1
	return grid


static func random_room_size() -> Vector2i:
	return Vector2i(
		randi_range(ROOM_MIN_SIZE, ROOM_MAX_SIZE),
		randi_range(ROOM_MIN_SIZE, ROOM_MAX_SIZE)
	)


# Hung off a room that is already down, so the ruin always comes out as one shape.
static func place_room(rooms: Array[Rect2i]) -> Rect2i:
	var anchor: Rect2i = rooms.pick_random()
	var size := random_room_size()
	for attempt in PLACEMENT_ATTEMPTS:
		var candidate := Rect2i(anchor.position + Vector2i(
			randi_range(1 - size.x, anchor.size.x - 1),
			randi_range(1 - size.y, anchor.size.y - 1)
		), size)
		if is_placement_valid(candidate, anchor, rooms):
			return candidate
	return Rect2i()


static func is_placement_valid(candidate: Rect2i, anchor: Rect2i, rooms: Array[Rect2i]) -> bool:
	if not is_intersection_valid(anchor, candidate):
		return false
	for room in rooms:
		# A room swallowed by one already placed adds nothing to the outline.
		if room.encloses(candidate):
			return false
	return true


# Rooms have to overlap to stay connected, but not so far that one contains the other —
# that would just give back a plain rectangle.
static func is_intersection_valid(r1: Rect2i, r2: Rect2i) -> bool:
	var intersect_area := r1.intersection(r2).get_area()
	return intersect_area > 0 and intersect_area < r1.get_area() and intersect_area < r2.get_area()


static func damage_floor(floor_cells: Array, wall_height: Array) -> void:
	for y in floor_cells.size():
		for x in floor_cells[y].size():
			# Cells carrying a wall keep their footing; a floating wall reads as a bug
			# rather than as damage.
			if floor_cells[y][x] == 0 or wall_height[y][x] > 0:
				continue
			if randf() < FLOOR_HOLE_CHANCE:
				floor_cells[y][x] = 0


# --- walls ---------------------------------------------------------------------------

# Every empty cell reachable from outside the ruin. The margin ring left by create_floor
# means (0, 0) is always out there, and always connected the whole way round.
static func get_exterior_cells(grid: Array) -> Dictionary:
	var exterior := {Vector2i.ZERO: true}
	var queue: Array[Vector2i] = [Vector2i.ZERO]
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_back()
		for d in NEIGHBORS_4:
			var n: Vector2i = cell + d
			if exterior.has(n) or not is_inside(grid, n) or grid[n.y][n.x] != 0:
				continue
			exterior[n] = true
			queue.append(n)
	return exterior


# Rooms meeting at odd angles leave gaps too tight to wall off: cells walled in
# completely, and one cell slots poking in from outside. Either would put a wall in the
# middle of a room, so they're filled in and the ruin keeps one clean outline. Repeated
# because filling the mouth of a slot exposes the cell behind it.
static func fill_gaps(grid: Array, exterior: Dictionary) -> void:
	for y in grid.size():
		for x in grid[y].size():
			if grid[y][x] == 0 and not exterior.has(Vector2i(x, y)):
				grid[y][x] = 1

	var filling := true
	while filling:
		filling = false
		for cell in exterior.keys():
			if count_floor_neighbors(grid, cell) < NARROW_GAP_NEIGHBORS:
				continue
			grid[cell.y][cell.x] = 1
			exterior.erase(cell)
			filling = true


static func count_floor_neighbors(grid: Array, cell: Vector2i) -> int:
	var count := 0
	for d in NEIGHBORS_8:
		var n: Vector2i = cell + d
		if is_inside(grid, n) and grid[n.y][n.x] == 1:
			count += 1
	return count


# The cells hugging the floor from outside, which is where the walls go.
static func get_border_cells(grid: Array, exterior: Dictionary) -> Array[Vector2i]:
	var seen := {}
	var border: Array[Vector2i] = []
	for y in grid.size():
		for x in grid[y].size():
			if grid[y][x] != 1:
				continue
			for d in NEIGHBORS_8:
				var n: Vector2i = Vector2i(x, y) + d
				if seen.has(n) or not exterior.has(n):
					continue
				seen[n] = true
				border.append(n)
	return border


static func create_wall_heights(border: Array[Vector2i], size: Vector2i) -> Array:
	var heights := new_grid(size)
	var noise := FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = HEIGHT_NOISE_FREQUENCY
	for cell in border:
		# Noise rather than per-cell randomness, so neighbouring cells agree and the wall
		# reads as one crumbling line instead of a comb.
		var t := clampf(inverse_lerp(
			-HEIGHT_NOISE_SPREAD, HEIGHT_NOISE_SPREAD, noise.get_noise_2d(cell.x, cell.y)
		), 0.0, 1.0)
		heights[cell.y][cell.x] = clampi(1 + floori(t * MAX_WALL_HEIGHT), 1, MAX_WALL_HEIGHT)
	return heights


static func damage_walls(heights: Array, border: Array[Vector2i]) -> void:
	var standing := {}
	for cell in border:
		standing[cell] = true

	for cell in border:
		# Breaches keep away from each other, or two of them landing side by side take
		# out a whole wall and the ruin stops reading as a building.
		if randf() < WALL_BREACH_CHANCE and not is_near_breach(heights, standing, cell):
			collapse_run(heights, standing, cell, randi_range(1, WALL_BREACH_MAX_RUN))
	if not border.is_empty():
		collapse_run(heights, standing, border.pick_random(), DOORWAY_WIDTH)

	for cell in border:
		var h: int = heights[cell.y][cell.x]
		if h > 1 and randf() < WALL_CHIP_CHANCE:
			heights[cell.y][cell.x] = h - 1


static func is_near_breach(heights: Array, standing: Dictionary, cell: Vector2i) -> bool:
	if heights[cell.y][cell.x] == 0:
		return true
	for d in NEIGHBORS_8:
		var n: Vector2i = cell + d
		if standing.has(n) and heights[n.y][n.x] == 0:
			return true
	return false


# Flattens a short run of neighbouring wall cells. Done as a run because a breach is what
# a hole in a ruin looks like from above; single cells dropped at random just look noisy.
static func collapse_run(heights: Array, standing: Dictionary, start: Vector2i, length: int) -> void:
	var cell := start
	var step := Vector2i.ZERO
	for i in length:
		heights[cell.y][cell.x] = 0
		var next := next_wall_cell(heights, standing, cell, step)
		if next == cell:
			return
		step = next - cell
		cell = next


# Already collapsed cells are skipped, which also stops a run from doubling back.
static func next_wall_cell(heights: Array, standing: Dictionary, cell: Vector2i, step: Vector2i) -> Vector2i:
	var options: Array[Vector2i] = []
	for d in NEIGHBORS_8:
		var n: Vector2i = cell + d
		if not standing.has(n) or heights[n.y][n.x] == 0:
			continue
		# Carrying on in the same direction keeps the breach a line along the wall.
		if d == step:
			return n
		options.append(n)
	return options.pick_random() if not options.is_empty() else cell


# Standing walls get a floor tile under them, so a breach shows as a gap in the stonework
# rather than the wall hovering over bare ground.
static func lay_foundations(floor_cells: Array, wall_height: Array, border: Array[Vector2i]) -> void:
	for cell in border:
		if wall_height[cell.y][cell.x] > 0:
			floor_cells[cell.y][cell.x] = 1


# --- grid helpers --------------------------------------------------------------------

static func new_grid(size: Vector2i) -> Array:
	var grid := []
	for y in size.y:
		var row: Array[int] = []
		row.resize(size.x)
		grid.append(row)
	return grid


static func is_inside(grid: Array, cell: Vector2i) -> bool:
	return cell.y >= 0 and cell.y < grid.size() and cell.x >= 0 and cell.x < grid[cell.y].size()
