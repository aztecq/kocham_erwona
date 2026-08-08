class_name TerrainGenerator

# Chance that a wall cell reaching the top of the structure layers pushes through the
# ground above it. A ruin is buried, but a stone or two breaking the surface gives away
# where to dig. Set to 0 to leave ruins hidden completely.
const EXPOSED_CELL_CHANCE := 0.15

static func flat(
	width: int,
	height: int,
	types: Array[TileTypes.Type] = TerrainLayers.STACK
) -> TerrainData:
	var data := TerrainData.new()
	data.width = width
	data.height = height
	# Duplicated because the default comes from a const, which is read-only.
	data.layer_types = types.duplicate()
	data.layers = create_3d_array(width, height, data.layer_types)
	insert_structure(data.layers, data.layer_types)
	data.heightmap = build_heightmap(data.layers, width, height)
	return data

# Only the structure overlays start empty; every ground layer starts full and stays that
# way apart from the cells a ruin takes off it. Nowhere in the world is there a cell with
# nothing in it.
static func create_3d_array(w: int, h: int, layer_types: Array[TileTypes.Type]) -> Array:
	var result := []
	for i in layer_types.size():
		var type := TileTypes.Type.NONE if TerrainLayers.is_structure_layer(i) else layer_types[i]
		result.append(create_2d_array_of_type(w, h, type))
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

# Topmost solid layer per cell, which is where `dig` starts. Read off the layers rather
# than assumed: the structure layers are empty everywhere a ruin isn't.
static func build_heightmap(layers: Array, width: int, height: int) -> Array:
	var heightmap := create_2d_array(width, height)
	for y in height:
		for x in width:
			# -1 marks a column with nothing left in it, which `dig` already refuses.
			var top := -1
			for i in layers.size():
				if layers[i][y][x] != TileTypes.Type.NONE:
					top = i
			heightmap[y][x] = top
	return heightmap

# Drops one ruin somewhere it fits whole. Its floor goes on the first structure overlay
# and each wall level on the next one up, every cell taking the material its layer is
# made of — which is what keeps ruin floors and ruin walls telling apart.
static func insert_structure(layers: Array, layer_types: Array[TileTypes.Type]) -> void:
	var structure := StructureGenerator.create_structure()
	var overlays := TerrainLayers.STRUCTURE_LAYERS
	var height: int = layers[0].size()
	var width: int = layers[0][0].size()
	var origin := Vector2i(
		randi_range(0, maxi(0, width - structure.size.x)),
		randi_range(0, maxi(0, height - structure.size.y))
	)

	for y in structure.size.y:
		for x in structure.size.x:
			var local := Vector2i(x, y)
			var cell := origin + local
			if cell.x >= width or cell.y >= height:
				continue
			if structure.is_floor(local):
				build(layers, layer_types, overlays[0], cell)

			var top := 0
			# A stack with room for fewer levels than the walls have clips them rather
			# than failing.
			for level in mini(StructureGenerator.MAX_WALL_HEIGHT, TerrainLayers.wall_levels()):
				if not structure.is_wall(level, local):
					break
				top = overlays[level + 1]
				build(layers, layer_types, top, cell)

			if top == TerrainLayers.top_structure_layer() and randf() < EXPOSED_CELL_CHANCE:
				uncover(layers, cell, top)

# Puts a cell of a ruin on an overlay layer, and takes the same cell off the ground layer
# under it. Stone stands in the ground's place rather than inside it, so the level is
# still one solid sheet of tiles.
static func build(layers: Array, layer_types: Array[TileTypes.Type], layer: int, cell: Vector2i) -> void:
	layers[layer][cell.y][cell.x] = layer_types[layer]
	layers[layer - 1][cell.y][cell.x] = TileTypes.Type.NONE

# Strips the ground off a single cell, letting the wall under it break the surface. Only
# ever used on the topmost stone of a ruin, so what it opens up is sky, not a cavity.
static func uncover(layers: Array, cell: Vector2i, from_layer: int) -> void:
	for i in range(from_layer + 1, layers.size()):
		layers[i][cell.y][cell.x] = TileTypes.Type.NONE
