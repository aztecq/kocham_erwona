class_name TerrainRenderer extends Node2D

@onready var tilemap_layers: Array[TileMapLayer] = [$Layer1, $Layer2, $Layer3, $Layer4, $Layer5, $Layer6]
@onready var dual_grid: DualGrid = $DualGrid

var _data: TerrainData

func bind(data: TerrainData) -> void:
	_data = data
	data.tile_changed.connect(_on_tile_changed)
	_apply_dual_grid_offset()
	_redraw_all()

# A display tile straddles the four world cells at its corners, so the tilemap layers
# sit half a tile down and right of the world grid they describe.
func _apply_dual_grid_offset() -> void:
	for layer in tilemap_layers:
		layer.position = Vector2(layer.tile_set.tile_size) / 2.0

func _on_tile_changed(layer: int, cell: Vector2i, _type: TileTypes.Type):
	# Four display tiles touch the changed cell: the ones up-left of it through to itself.
	_edit_terrain(layer, cell, Vector2i(2, 2))

func _redraw_all():
	for i in _data.layers.size():
		_redraw_layer(i)

func _redraw_layer(layer_index: int) -> void:
	# Display cells run from -1 so the map's top and left edges get drawn too.
	for y in range(-1, _data.height):
		for x in range(-1, _data.width):
			_set_display_cell(layer_index, x, y)

func generate_terrain(array, layer: TileMapLayer):
	for i in _data.width:
		for j in _data.height:
			var type = array[j][i]
			layer.set_cell(Vector2i(i, j), TileAtlas.SOURCE_ID, TileAtlas.coords_for(type))

func cell_at_global(global_pos: Vector2) -> Vector2i:
	# Deliberately not via a TileMapLayer: those carry the half-tile display offset,
	# and this has to return a world cell.
	var local := to_local(global_pos)
	var tile_size := tilemap_layers[0].tile_set.tile_size
	return Vector2i(floori(local.x / tile_size.x), floori(local.y / tile_size.y))

func _edit_terrain(layer_index: int, grid_position: Vector2i, fragment_size: Vector2i) -> void:
	var start := grid_position - fragment_size / 2
	for y in range(start.y, start.y + fragment_size.y):
		for x in range(start.x, start.x + fragment_size.x):
			_set_display_cell(layer_index, x, y)

func _set_display_cell(layer_index: int, x: int, y: int) -> void:
	if x < -1 or y < -1 or x >= _data.width or y >= _data.height:
		return
	# Clockwise from top-right, which is the order DualGrid's lookup table is keyed in.
	var corners: Array[TileTypes.Type] = [
		_type_at(layer_index, x + 1, y),
		_type_at(layer_index, x + 1, y + 1),
		_type_at(layer_index, x, y + 1),
		_type_at(layer_index, x, y)
	]
	var block := TileAtlas.block_for(_data.layer_types[layer_index])
	tilemap_layers[layer_index].set_cell(
		Vector2i(x, y), TileAtlas.DUAL_SOURCE_ID, dual_grid.get_tile(block, corners)
	)

# Cells off the edge of the map read as empty, so the border resolves to a proper edge
# instead of wrapping around to the far side of the array.
func _type_at(layer_index: int, x: int, y: int) -> TileTypes.Type:
	if x < 0 or y < 0 or x >= _data.width or y >= _data.height:
		return TileTypes.Type.NONE
	return _data.layers[layer_index][y][x]
