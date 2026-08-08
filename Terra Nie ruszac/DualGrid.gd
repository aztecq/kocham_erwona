class_name DualGrid

extends Node2D

@export var tileset: TileSet

var neighbours_to_index: Dictionary = {
	[false, false, false, true]: 0,#
	[true,  true, false, false]: 1,
	[true, false,  true, true]: 2,
	[true,  false, false, true]: 3,

	[true,  false, true,  false]: 4,
	[true,  true, false,  true]: 5,
	[true, true,  true,  true]: 6,
	[false, true,  true, true]: 7,

	[false, true, false, false]: 8,
	[false,  true, true, false]: 9,
	[true,  true, true,  false]: 10,
	[false,  false,  true, true]: 11,

	[true, false, false, false]: 12,
	[false,  true, false,  true]: 13,
	[false, false, true, false]: 14,#
	[false,  false,  false,  false]: 15,
}

# `neighbours` are the four world cells meeting at the tile's centre, in the order the
# table above is keyed: top-right, bottom-right, bottom-left, top-left (clockwise from
# top-right). `block` picks one of the 4x4 material blocks in the atlas.
func get_tile(block: int, neighbours: Array[TileTypes.Type]) -> Vector2i:
	var key := [
		neighbours[0] != TileTypes.Type.NONE,
		neighbours[1] != TileTypes.Type.NONE,
		neighbours[2] != TileTypes.Type.NONE,
		neighbours[3] != TileTypes.Type.NONE
	]
	var i: int = neighbours_to_index[key]
	return Vector2i(i % 4 + block * 4, i / 4)
