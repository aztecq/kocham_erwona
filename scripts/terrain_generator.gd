class_name TerrainGenerator

# Chance that a wall cell at the top of a ruin pushes up through the ground above it. A
# ruin is buried, but a stone or two breaking the surface gives away where to dig. Set to
# 0 to leave ruins hidden completely.
const EXPOSED_CELL_CHANCE := 0.15

# Tries to find a clear spot for each ruin before giving up on it. Maps that are mostly
# ruin already just end up with fewer than asked for.
const PLACEMENT_ATTEMPTS := 30

static func flat(
	width: int,
	height: int,
	structure_count: int = 1,
	types: Array[TileTypes.Type] = TerrainLayers.STACK
) -> TerrainData:
	var data := TerrainData.new()
	data.width = width
	data.height = height
	# Duplicated because the default comes from a const, which is read-only.
	data.layer_types = types.duplicate()
	data.layers = create_3d_array(width, height, data.layer_types)
	for i in structure_count:
		insert_structure(data)
	data.heightmap = build_heightmap(data.layers, width, height)
	return data

static func create_3d_array(w: int, h: int, layer_types: Array[TileTypes.Type]) -> Array:
	var result := []
	for layer_type in layer_types:
		result.append(create_2d_array_of_type(w, h, layer_type))
	return result

static func create_2d_array(_x: int, _y: int) -> Array:
	var result := []
	for y in _y:
		var arr = []
		arr.resize(_x)
		result.append(arr)
	return result

static func create_2d_array_of_type(width: int, height: int, type: TileTypes.Type) -> Array:
	var array = create_2d_array(width, height)
	return fill_2d_array_with_tile_type(array, type)

static func fill_2d_array_with_tile_type(array: Array, type: TileTypes.Type) -> Array:
	for y in array:
		y.fill(type)
	return array

# Topmost solid level per cell, which is where `dig` starts. Every column is solid from
# the bedrock up, so this only differs from the top of the stack where a ruin has broken
# the surface and taken the ground above it off.
static func build_heightmap(layers: Array, width: int, height: int) -> Array:
	var heightmap := create_2d_array(width, height)
	for y in height:
		for x in width:
			var top := layers.size() - 1
			while top >= 0 and layers[top][y][x] == TileTypes.Type.NONE:
				top -= 1
			heightmap[y][x] = top
	return heightmap

# Drops one ruin where it fits whole and clear of the ruins already down, replacing the
# ground it stands in: its floor on STRUCTURE_FLOOR_LEVEL, each wall level on the level
# above the last. Nothing is carved out and nothing is added — a cell of ground becomes
# a cell of stone. A ruin that can't find room is dropped, not forced.
static func insert_structure(data: TerrainData) -> void:
	var layers := data.layers
	var structure := StructureGenerator.create_structure()
	var base := TerrainLayers.STRUCTURE_FLOOR_LEVEL
	var wall_levels := TerrainLayers.wall_levels()
	var origin := find_origin(data, structure.size)
	if origin.x < 0:
		return

	var placed := TerrainData.PlacedStructure.new()
	placed.structure = structure
	placed.origin = origin
	data.structures.append(placed)

	for y in structure.size.y:
		for x in structure.size.x:
			var local := Vector2i(x, y)
			var cell := origin + local
			if structure.is_floor(local):
				layers[base][cell.y][cell.x] = TerrainLayers.STRUCTURE_FLOOR_MATERIAL

			var top := base
			for level in mini(StructureGenerator.MAX_WALL_HEIGHT, wall_levels):
				if not structure.is_wall(level, local):
					break
				top = base + 1 + level
				layers[top][cell.y][cell.x] = TerrainLayers.STRUCTURE_WALL_MATERIALS[level]

			# Only the tallest walls can surface: uncovering a short one would sink a
			# shaft through several levels of ground to reach it.
			if top == base + wall_levels and randf() < EXPOSED_CELL_CHANCE:
				uncover(layers, cell, top)

# A spot where the ruin's whole footprint is on the map and off every other ruin's.
# (-1, -1) when none turned up: their margin ring is part of the footprint, so two
# footprints touching would weld into one shape and confuse whose wall is whose.
static func find_origin(data: TerrainData, size: Vector2i) -> Vector2i:
	if size.x > data.width or size.y > data.height:
		return Vector2i(-1, -1)
	for attempt in PLACEMENT_ATTEMPTS:
		var origin := Vector2i(
			randi_range(0, data.width - size.x),
			randi_range(0, data.height - size.y)
		)
		var footprint := Rect2i(origin, size)
		var clear := true
		for placed in data.structures:
			if footprint.intersects(Rect2i(placed.origin, placed.structure.size)):
				clear = false
				break
		if clear:
			return origin
	return Vector2i(-1, -1)

# Strips the ground off a single cell, letting the wall under it break the surface. Only
# ever used on the topmost stone of a ruin, so what it opens up is sky, not a cavity.
static func uncover(layers: Array, cell: Vector2i, from_level: int) -> void:
	for i in range(from_level + 1, layers.size()):
		layers[i][cell.y][cell.x] = TileTypes.Type.NONE
