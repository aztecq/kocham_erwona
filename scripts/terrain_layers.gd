class_name TerrainLayers

# The one place the layer stack is defined: bottom of the world first, surface last.
# Everything else follows from this list — TerrainGenerator builds one 2D array per
# entry, and TerrainRenderer spawns one TileMapLayer node per entry to draw it.
# Add, remove or reorder entries here and nothing else needs touching.
const STACK: Array[TileTypes.Type] = [
	TileTypes.Type.BEDROCK,
	TileTypes.Type.HUMUS,
]

static func count() -> int:
	return STACK.size()
