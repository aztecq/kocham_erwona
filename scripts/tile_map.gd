extends Node2D

enum TileType { NONE, DIRT, SAND, ROCK, BEDROCK, BRICKS }

var width: int = 20
var height: int = 20
var types : Array[TileType] = [TileType.BEDROCK,TileType.ROCK, TileType.SAND,  TileType.DIRT]
var all_layers = []

func _ready() -> void:
	all_layers = create_3d_array(types)
	var tilemap_layers = [$Layer1, $Layer2, $Layer3, $Layer4]
	
	insert_structure(0)
	
	for i in tilemap_layers.size():
		generate_terrain(all_layers[i], tilemap_layers[i])	
	

func insert_structure(at_layer: int = 0):
	var floor = StructureGenerator.create_floor()
	var origin = Vector2i(0, 0)
	
	for y in all_layers[at_layer].size()-1:
		for x in all_layers[at_layer][y].size()-1:
			if y < floor.size() and x < floor[y].size() and floor[y][x] == 1:
				all_layers[at_layer][y][x] = TileType.BRICKS

func create_2d_array(_x: int, _y: int) -> Array:
	var result := []
	for y in _y:
		var arr = []
		arr.resize(_x)
		result.append(arr)
	return result

func fill_2d_array_with_tile_type(array: Array, type: TileType):
	for y in array:
		y.fill(type)
	return array
	
func create_2d_array_of_type(width: int, height: int, type: TileType):
	var array = create_2d_array(width, height)
	return fill_2d_array_with_tile_type(array, type)

func create_3d_array(layer_types: Array[TileType]):
	var result := []
	for layer_type in layer_types:
		result.append(create_2d_array_of_type(width, height, layer_type))
	return result

#func generate_2d_array(type):
	#var result = []
	#for i in width:
		#var x = []
		#layer.append([])
		#for j in height:
			#layer[i].append(type)
		#append 
	#return result

		
#func make_3d_array(types):
	#var result := []
	#for i in types:
		#result.append(generate_2d_array(i))
	#return result
	
func generate_terrain (array, layer: TileMapLayer):
	for i in width:
		for j in height:
			var type = array[j][i]
			layer.set_cell(Vector2i(i, j), 1, get_texture_coords(type))

func get_texture_coords(type: TileType):
	var texture
	match type:
		TileType.DIRT:
			texture = Vector2i(3,0)
		TileType.SAND:
			texture = Vector2i(1,0)
		TileType.ROCK:
			texture = Vector2i(2,0)
		TileType.BEDROCK:
			texture = Vector2i(7,0)
		TileType.BRICKS:
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
			var map_coords = $Layer4.local_to_map(local_mouse_pos)
			if $Layer2.get_cell_source_id(map_coords) == -1:
				$Layer1.set_cell(map_coords, -1)
			elif $Layer3.get_cell_source_id(map_coords) == -1:
				$Layer2.set_cell(map_coords, -1)
			elif $Layer4.get_cell_source_id(map_coords) == -1:
				$Layer3.set_cell(map_coords, -1)
			else:
				$Layer4.set_cell(map_coords, -1)
			
