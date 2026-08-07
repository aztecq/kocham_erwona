extends Node2D

var width: int = 20
var height: int = 20
var types : Array[TileTypes.Type] = [TileTypes.Type.BEDROCK,TileTypes.Type.ROCK, TileTypes.Type.SAND,  TileTypes.Type.DIRT]
var tilemap_layers = [$Layer1, $Layer2, $Layer3, $Layer4]
var all_layers = []
var highmap = []
@export var dualGrid: DualGrid

func _ready() -> void:
	all_layers = create_3d_array(types)
	highmap = create_2d_array(width, height)
	inicialize_values_highmap(types.size())
	insert_structure(0)
	
	for i in tilemap_layers.size():
		generate_terrain(all_layers[i], tilemap_layers[i])	
	
func inicialize_values_highmap(number_of_layers: int) -> void:
	for y in highmap.size():
		for x in highmap[y].size():
			highmap[y][x] = number_of_layers

func create_2d_array(_x: int, _y: int) -> Array:
	var result := []
	for y in _y:
		var arr = []
		arr.resize(_x)
		result.append(arr)
	return result

func fill_2d_array_with_tile_type(array: Array, type: TileTypes.Type):
	for y in array:
		y.fill(type)
	return array
	
func create_2d_array_of_type(width: int, height: int, type: TileTypes.Type):
	var array = create_2d_array(width, height)
	return fill_2d_array_with_tile_type(array, type)

func create_3d_array(layer_types: Array[TileTypes.Type]):
	var result := []
	for layer_type in layer_types:
		result.append(create_2d_array_of_type(width, height, layer_type))
	return result

func generate_terrain (array, layer: TileMapLayer):
	for i in width:
		for j in height:
			var type = array[j][i]
			layer.set_cell(Vector2i(i, j), 1, get_texture_coords(type))
			
func insert_structure(at_layer: int = 0):
	var floor = StructureGenerator.create_floor()
	var origin = Vector2i(0, 0)
	
	for y in all_layers[at_layer].size()-1:
		for x in all_layers[at_layer][y].size()-1:
			if y < floor.size() and x < floor[y].size() and floor[y][x] == 1:
				all_layers[at_layer][y][x] = TileTypes.Type.BRICKS

func get_texture_coords(type: TileTypes.Type):
	var texture
	match type:
		TileTypes.Type.DIRT:
			texture = Vector2i(3,0)
		TileTypes.Type.SAND:
			texture = Vector2i(1,0)
		TileTypes.Type.ROCK:
			texture = Vector2i(2,0)
		TileTypes.Type.BEDROCK:
			texture = Vector2i(7,0)
		TileTypes.Type.BRICKS:
			texture = Vector2i(0,0)
		_: 
			texture = Vector2i(0,0)
	return texture

func _process(delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var global_mouse_pos = get_global_mouse_position()
			var local_mouse_pos = $Layer4.to_local(global_mouse_pos)
			var grid_position = $Layer4.local_to_map(local_mouse_pos)
			var layer_index = highmap[grid_position.y][grid_position.x]
			
<<<<<<< Updated upstream
			all_layers[layerIndex][map_coords.y][map_coords.x] = TileTypes.Type.NONE
			highmap[map_coords.y][map_coords.x] = highmap[map_coords.y][map_coords.x] - 1;
			var tile = dualGrid.get_tile(layerIndex, 
			[all_layers[layerIndex][map_coords.y -1][map_coords.x],
			all_layers[layerIndex][map_coords.y][map_coords.x],
			all_layers[layerIndex][map_coords.y][map_coords.x],
			all_layers[layerIndex][map_coords.y][map_coords.x]])
=======
			all_layers[layer_index][grid_position.y][grid_position.x] = TileTypes.Type.NONE
			highmap[grid_position.y][grid_position.x] = highmap[grid_position.y][grid_position.x] - 1;
			#var tile = dualGrid.get_tile(layerIndex, 
			#[all_layers[layerIndex][map_coords.y -1][map_coords.x],
			#all_layers[layerIndex][map_coords.y][map_coords.x],
			#all_layers[layerIndex][map_coords.y][map_coords.x],
			#all_layers[layerIndex][map_coords.y][map_coords.x]])
>>>>>>> Stashed changes
			
			tilemap_layers[layer_index].set_cell(grid_position, -1)
			
			
<<<<<<< Updated upstream
=======
func _edit_terrain(layer_index: int,grid_position: Vector2i, fragment_size: Vector2i) -> void:
	var _y = fragment_size.y - 1
	for y in _y:
		var _x = fragment_size.x - 1
		for x in _x:
			var tile = dualGrid.get_tile(layer_index, 
			[all_layers[layer_index][y][x],
			all_layers[layer_index][y+1][x],
			all_layers[layer_index][y][x+1],
			all_layers[layer_index][y+1][x+1]])
			
			tilemap_layers[layer_index].set_cell(grid_position + Vector2i(y - _y/2,x - _x/2), tile)
			
>>>>>>> Stashed changes
