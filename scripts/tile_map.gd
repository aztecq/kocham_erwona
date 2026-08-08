extends Node2D

var width: int = 20
var height: int = 20
var types : Array[TileTypes.Type] = [TileTypes.Type.BEDROCK,TileTypes.Type.ROCK, TileTypes.Type.SAND,  TileTypes.Type.DIRT]
var tilemap_layers = [$Layer1, $Layer2, $Layer3, $Layer4]
var all_layers = []
var highmap = []
@export var dualGrid: DualGrid

func _ready() -> void:
	all_layers = TerrainGenerator.create_3d_array(width, height, types)
	highmap = TerrainGenerator.create_2d_array(width, height)
	inicialize_values_highmap(types.size())
	
	for i in tilemap_layers.size():
		generate_terrain(all_layers[i], tilemap_layers[i])	

func inicialize_values_highmap(number_of_layers: int) -> void:
	for y in highmap.size():
		highmap.fill(number_of_layers)

func generate_terrain (array, layer: TileMapLayer):
	for i in width:
		for j in height:
			var type = array[j][i]
			layer.set_cell(Vector2i(i, j), 1, TileAtlas.coords_for(type))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var global_mouse_pos = get_global_mouse_position()
			var local_mouse_pos = $Layer4.to_local(global_mouse_pos)
			var grid_position = $Layer4.local_to_map(local_mouse_pos)
			var layer_index = highmap[grid_position.y][grid_position.x]
			
			#all_layers[layer_index][grid_position.y][grid_position.x] = TileTypes.Type.NONE
			#highmap[grid_position.y][grid_position.x] -= 1
			tilemap_layers[layer_index].set_cell(grid_position, -1)

func _edit_terrain(layer_index: int,grid_position: Vector2i, fragment_size: Vector2i) -> void:
	var _y = fragment_size.y - 1
	for y in _y:
		var _x = fragment_size.x - 1
		for x in _x:
			var tile = dualGrid.get_tile(layer_index, 
				[
					all_layers[layer_index][y][x],
					all_layers[layer_index][y+1][x],
					all_layers[layer_index][y][x+1],
					all_layers[layer_index][y+1][x+1]
				]
			)
			tilemap_layers[layer_index].set_cell(grid_position + Vector2i(y - _y/2,x - _x/2), tile)
