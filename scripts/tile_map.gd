extends Node2D

var width: int = 20
var height: int = 20
var types = [tile_types.BEDROCK,tile_types.ROCK, tile_types.SAND,  tile_types.DIRT]
var all_layers = []

func insert_structure(at_layer: int = 0):
	var floor = StructureGenerator.create_floor()
	var origin = Vector2i(0, 0)
	
	for y in all_layers[at_layer].size()-1:
		for x in all_layers[at_layer][y].size()-1:
			if y < floor.size() and x < floor[y].size() and floor[y][x] == 1:
				all_layers[at_layer][y][x] = tile_types.BRICKS


func generate_2d_array(type):
	var layer = []
	for i  in width:
		layer.append([])
		for j in height:
			layer[i].append(type)
	var new_layer = layer
	return new_layer
	
func make_3d_array(types):
	var result := []
	for i in types:
		result.append(generate_2d_array(i))
	return result
	
func generate_terrain (array, layer: TileMapLayer):
	for i in width:
		for j in height:
			var type = array[j][i]
			layer.set_cell(Vector2i(i, j), 1, get_texture_coords(type))

func get_texture_coords(type: tile_types):
	var texture
	match type:
		tile_types.DIRT:
			texture = Vector2i(3,0)
		tile_types.SAND:
			texture = Vector2i(1,0)
		tile_types.ROCK:
			texture = Vector2i(2,0)
		tile_types.BEDROCK:
			texture = Vector2i(7,0)
		tile_types.BRICKS:
			texture = Vector2i(0,0)
		_: 
			texture = Vector2i(0,0)
	return texture
	

enum tile_types{NONE, DIRT, SAND, ROCK, BEDROCK, BRICKS}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	all_layers = make_3d_array(types)
	var layer1 = $Layer1
	var layer2 = $Layer2
	var layer3 = $Layer3
	var layer4 = $Layer4
	
	insert_structure(0)
		
	generate_terrain(all_layers[0], layer1)
	generate_terrain(all_layers[1], layer2)
	generate_terrain(all_layers[2], layer3)
	generate_terrain(all_layers[3], layer4)
	

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
			
