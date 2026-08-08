class_name TileAtlas

const SOURCE_ID := 1
const COORDS := {
	TileTypes.Type.BRICKS: Vector2i(0, 0),
	TileTypes.Type.SAND: Vector2i(1, 0),
	TileTypes.Type.ROCK: Vector2i(2, 0),
	TileTypes.Type.DIRT: Vector2i(3, 0),
	TileTypes.Type.BEDROCK: Vector2i(7, 0),
}

static func coords_for(type: TileTypes.Type) -> Vector2i:
	return COORDS.get(type, Vector2i(0, 0))
