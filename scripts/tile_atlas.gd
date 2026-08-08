class_name TileAtlas

const SOURCE_ID := 1
const COORDS := {
	TileTypes.Type.BRICKS1: Vector2i(0, 0),
	TileTypes.Type.SAND: Vector2i(1, 0),
	TileTypes.Type.ROCK: Vector2i(2, 0),
	TileTypes.Type.DIRT: Vector2i(3, 0),
	TileTypes.Type.BEDROCK: Vector2i(7, 0),
}

static func coords_for(type: TileTypes.Type) -> Vector2i:
	return COORDS.get(type, Vector2i(0, 0))

# dualGridTileSet.tres defines only sources/0.
const DUAL_SOURCE_ID := 0

# kurwa.png is seven 4x4 dual grid blocks side by side, one material each.
# Block 2 is unused. Swap BEDROCK and ROCK here if they come out the wrong way round.
const BLOCKS := {
	TileTypes.Type.BEDROCK: 5,
	TileTypes.Type.DIRT: 2,
	TileTypes.Type.GRASS: 3,
	TileTypes.Type.BRICKS1: 4,
	TileTypes.Type.BRICKS2: 7,
	TileTypes.Type.BRICKS3: 8,
	TileTypes.Type.ROCK: 5,
	TileTypes.Type.SAND: 6,
	TileTypes.Type.HUMUS: 1,
	TileTypes.Type.WEIRDDIRT: 0
}

static func block_for(type: TileTypes.Type) -> int:
	return BLOCKS.get(type, 0)
