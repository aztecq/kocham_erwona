class_name TerrainData extends Node

signal tile_changed(layer: int, cell: Vector2i, type: TileTypes.Type)

# The pit has a floor: the bottom level never comes out, so there's always ground to
# stand a ruin on and the map can't be dug into the void.
const BOTTOM_LEVEL := 0

var width: int
var height: int
var layers := []
# Base material of each layer, parallel to `layers`. Drives which atlas block it draws with.
var layer_types: Array[TileTypes.Type] = []
var heightmap := []
# A ruin standing in this terrain and where its local grid starts in world cells.
class PlacedStructure extends RefCounted:
	var structure: StructureGenerator.Structure
	var origin: Vector2i

# Anything that needs the sites rather than the tiles reads this — artifacts are buried
# in their rooms, and the score knows the ruins' cells from here.
var structures: Array[PlacedStructure] = []

func is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < width and cell.y >= 0 and cell.y < height

func get_type(layer: int, cell: Vector2i) -> TileTypes.Type:
	return layers[layer][cell.y][cell.x]

# Topmost solid level of a cell, BOTTOM_LEVEL when only the floor is left.
func top_level(cell: Vector2i) -> int:
	return heightmap[cell.y][cell.x]

# What's lying on top of a cell right now — the material a tool would meet there.
func top_type(cell: Vector2i) -> TileTypes.Type:
	return layers[top_level(cell)][cell.y][cell.x]

# The one way ground leaves the world: takes the top tile off a cell and says what it
# was, NONE if there was nothing left to take. Everything above this — which tool, how
# fast, in what shape, at which locked level — is the controller's business.
func dig(cell: Vector2i) -> TileTypes.Type:
	if not is_inside(cell):
		return TileTypes.Type.NONE
	var layer: int = heightmap[cell.y][cell.x]
	if layer <= BOTTOM_LEVEL:
		return TileTypes.Type.NONE
	var removed: TileTypes.Type = layers[layer][cell.y][cell.x]
	layers[layer][cell.y][cell.x] = TileTypes.Type.NONE
	heightmap[cell.y][cell.x] = layer - 1
	tile_changed.emit(layer, cell, TileTypes.Type.NONE)
	return removed
