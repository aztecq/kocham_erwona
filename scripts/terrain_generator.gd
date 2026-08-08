class_name TerrainGenerator

static func flat(width: int, height: int, types: Array[TileTypes.Type] = TerrainLayers.STACK) -> TerrainData:
	var data := TerrainData.new()
	data.width = width
	data.height = height
	# Duplicated because the default comes from a const, which is read-only.
	data.layer_types = types.duplicate()
	data.layers = create_3d_array(width, height, types)
	data.layers = insert_structure(data.layers, 0)
	data.heightmap = create_2d_array(width, height)
	for y in data.heightmap.size():
		data.heightmap[y].fill(types.size()-1)
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

static func insert_structure(layers: Array, at_layer: int = 0):
	var floor = StructureGenerator.create_floor()
	var origin = Vector2i(0, 0)
	
	for y in layers[at_layer].size()-1:
		for x in layers[at_layer][y].size()-1:
			if y < floor.size() and x < floor[y].size() and floor[y][x] == 1:
				layers[at_layer][y][x] = TileTypes.Type.BRICKS
	return layers
