class_name TerrainData extends Node

signal tile_changed(layer: int, cell: Vector2i, type: TileTypes.Type)

var width: int
var height: int
var layers := []
# Base material of each layer, parallel to `layers`. Drives which atlas block it draws with.
var layer_types: Array[TileTypes.Type] = []
var heightmap := []

func is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < width and cell.y >= 0 and cell.y < height

func get_type(layer: int, cell: Vector2i) -> TileTypes.Type:
	return layers[layer][cell.y][cell.x]

func dig(cell: Vector2i) -> bool:
	if not is_inside(cell):
		return false
	var layer = heightmap[cell.y][cell.x]
	if layer < 0:
		return false
	layers[layer][cell.y][cell.x] = TileTypes.Type.NONE
	heightmap[cell.y][cell.x] = _top_layer_below(layer, cell)
	tile_changed.emit(layer, cell, TileTypes.Type.NONE)
	return true

# The layer below is not always the next thing to dig: the layers a structure is built
# into are empty everywhere the structure isn't, so a column can have a gap in it.
func _top_layer_below(layer: int, cell: Vector2i) -> int:
	for i in range(layer - 1, -1, -1):
		if layers[i][cell.y][cell.x] != TileTypes.Type.NONE:
			return i
	return -1
