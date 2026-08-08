class_name TerrainData extends Node

signal tile_changed(layer: int, cell: Vector2i, type: TileTypes.Type)

var width: int
var height: int
var layers := []
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
	heightmap[cell.y][cell.x] = layer - 1
	tile_changed.emit(layer, cell, TileTypes.Type.NONE)
	return true
