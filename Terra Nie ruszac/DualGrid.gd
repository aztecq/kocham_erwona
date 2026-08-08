class_name DualGrid

extends Node2D

@export var tileset: TileSet

var neighbours_to_index: Dictionary = {
	[false, false, true, false]: 0,
	[true,  true, false, false]: 1,
	[false, true,  true, true]: 2,
	[false,  true,  true, false]: 3,

	[false, true, false,  true]: 4,
	[true,  true, true,  false]: 5,
	[true, true,  true,  true]: 6,
	[true,  false,  true,  true]: 7,

	[true, false, false, false]: 8,
	[true,  false, false, true]: 9,
	[true, true,  false, true]: 10,
	[false,  false,  true, true]: 11,

	[false, true, false,  false]: 12,
	[true,  false, true,  false]: 13,
	[false, false,  false,  true]: 14,
	[false,  false,  false,  false]: 15,
}

func get_tile(layer: int, neighbours: Array[TileTypes.Type]) -> Vector2i:
	var key := [
		neighbours[0] != TileTypes.Type.NONE,
		neighbours[1] != TileTypes.Type.NONE,
		neighbours[2] != TileTypes.Type.NONE,
		neighbours[3] != TileTypes.Type.NONE
	]
	var i: int = neighbours_to_index[key]
	print(key)
	return Vector2i(i % 4 + layer * 4, i / 4)
