class_name TerrainData extends Node

signal tile_changed(layer: int, cell: Vector2i, type: TileTypes.Type)

var width: int
var height: int
var layers := []
# Base material of each layer, parallel to `layers`. Drives which atlas block it draws with.
var layer_types: Array[TileTypes.Type] = []
var heightmap := []
# The ruin standing in this terrain, and where its local grid starts in world cells.
# Anything that needs the site rather than the tiles reads these — artifacts are buried
# in its rooms.
var structure: StructureGenerator.Structure
var structure_origin: Vector2i

var last_cell: Vector2i
var timer: float
var selected_layer: int
	
func is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < width and cell.y >= 0 and cell.y < height

func get_type(layer: int, cell: Vector2i) -> TileTypes.Type:
	return layers[layer][cell.y][cell.x]

func dig(cell: Vector2i) -> bool:
	if(!CheckIfOnMap(cell)):
		return false
	var layer = heightmap[cell.y][cell.x]

	layers[layer][cell.y][cell.x] = TileTypes.Type.NONE
	heightmap[cell.y][cell.x] = layer - 1
	tile_changed.emit(layer, cell, TileTypes.Type.NONE)
	return true
	
func select_layer(cell: Vector2i):
	selected_layer = heightmap[cell.y][cell.x]
	
func deselect_layer():
	selected_layer = 0
	
func scrach_level(cell: Vector2i) -> bool:
	if(!CheckIfOnMap(cell) || selected_layer == 0):
		return false
	var layer = heightmap[cell.y][cell.x]
	if(layer != selected_layer):
		return false
	layers[layer][cell.y][cell.x] = TileTypes.Type.NONE
	heightmap[cell.y][cell.x] = layer - 1
	tile_changed.emit(layer, cell, TileTypes.Type.NONE)
	return true

func fancy_dig(cell: Vector2i, size: int, tool_type: ToolType.Type, speed: int, _delta: float) -> bool:
	if(!CheckIfOnMap(cell)):
		return false
	var layer = heightmap[cell.y][cell.x]
	var tool_efficency = ToolType.get_tool_efficency(tool_type,layers[layer][cell.y][cell.x])
	
	timer -= _delta;
	if(cell != last_cell):
		timer = .5
	if(timer < 0):
		timer = .5
		layers[layer][cell.y][cell.x] = TileTypes.Type.NONE
		heightmap[cell.y][cell.x] = layer - 1
		tile_changed.emit(layer, cell, TileTypes.Type.NONE)
		
	last_cell = cell
	return true

func CheckIfOnMap(cell: Vector2i) -> bool:
	if not is_inside(cell):
		return false
	var layer = heightmap[cell.y][cell.x]
	if layer < 1:
		return false
	return true
