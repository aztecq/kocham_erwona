extends Node2D

var tile_0
@export var tiles_sets: Array[Array]

var neighbours_to_index: Dictionary = {
	[false, false, false, false]: 0,
	[true,  false, false, false]: 1,
	[false, true,  false, false]: 2,
	[true,  true,  false, false]: 3,

	[false, false, true,  false]: 4,
	[true,  false, true,  false]: 5,
	[false, true,  true,  false]: 6,
	[true,  true,  true,  false]: 7,

	[false, false, false, true]: 8,
	[true,  false, false, true]: 9,
	[false, true,  false, true]: 10,
	[true,  true,  false, true]: 11,

	[false, false, true,  true]: 12,
	[true,  false, true,  true]: 13,
	[false, true,  true,  true]: 14,
	[true,  true,  true,  true]: 15,
}

func _ready() -> void:
	pass 

func get_tile(layer: int, neighbours: Array[TileTypes.Type]) -> TileData:

	var key := [
		neighbours[0] != TileTypes.Type.NONE,
		neighbours[1] != TileTypes.Type.NONE,
		neighbours[2] != TileTypes.Type.NONE,
		neighbours[3] != TileTypes.Type.NONE
	]

	return tiles_sets[layer][neighbours_to_index[key]]
