class_name TerrainRenderer extends Node2D

@onready var tilemap_layers: Array[TileMapLayer] = [$Layer1, $Layer2, $Layer3, $Layer4, $Layer5, $Layer6]
@onready var dual_grid: DualGrid = $DualGrid

var _data: TerrainData

func bind(data: TerrainData) -> void:
	_data = data
	data.tile_changed.connect(_on_tile_changed)
	_redraw_all()
	
func _on_tile_changed(layer: int, cell: Vector2i, type: TileTypes.Type):
	_edit_terrain(layer, cell, Vector2i(2, 2))

func _redraw_all():
	for i in _data.layers.size():
		_edit_terrain(i, Vector2i(_data.layers[0].size()/2, _data.layers.size()/2), Vector2i(10,10))
		
	#for i in tilemap_layers.size():
		#generate_terrain(_data.layers[i], tilemap_layers[i])	
		
func generate_terrain(array, layer: TileMapLayer):
	for i in _data.width:
		for j in _data.height:
			var type = array[j][i]
			layer.set_cell(Vector2i(i, j), 1, TileAtlas.coords_for(type))
	
func cell_at_global(global_pos: Vector2) -> Vector2i:
	var layer := tilemap_layers[0]
	return layer.local_to_map(layer.to_local(global_pos))

func _edit_terrain(layer_index: int, grid_position: Vector2i, fragment_size: Vector2i) -> void:
	var _y = fragment_size.y - 1
	for y in _y:
		var _x = fragment_size.x - 1
		for x in _x:
			var tile_coords = dual_grid.get_tile(layer_index, 
				[
					_data.layers[layer_index][y][x],
					_data.layers[layer_index][y+1][x],
					_data.layers[layer_index][y][x+1],
					_data.layers[layer_index][y+1][x+1]
				]
			)
			tilemap_layers[layer_index].set_cell(grid_position + Vector2i(y - _y/2,x - _x/2), 0, tile_coords)
