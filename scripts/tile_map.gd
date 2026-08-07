extends Node2D

var width: int = 20
var height: int = 20
var types = [tile_types.DIRT, tile_types.SAND, tile_types.ROCK, tile_types.BEDROCK]
var all_layers = []

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
	
func generate_terrain (array, layer, layer_level):
	print (layer_level)
	var type = array[layer_level][0][0]
	print (type)
	var texture = Vector2i(0,0)
	match type:
		1: #DIRT
			texture = Vector2i(3,0)
		2: #SAND
			texture = Vector2i(1,0)
		3: #ROCK
			texture = Vector2i(2,0)
		4: #BEDROCK
			texture = Vector2i(7,0)
		_: 
			texture = Vector2i(0,0)
	
	layer.set_cell(Vector2i(0,0),1, texture, 0)
	for i in width:
		for j in height:
			layer.set_cell(Vector2i(i,j),1, texture, 0)


enum tile_types{NONE, DIRT, SAND, ROCK, BEDROCK}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	all_layers = make_3d_array(types)
	var layer1 = $Layer1
	var layer2 = $Layer2
		
	generate_terrain(all_layers, layer1, 0)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
