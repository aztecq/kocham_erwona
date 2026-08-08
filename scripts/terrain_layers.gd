class_name TerrainLayers

# The one place the layer stack is defined: bottom of the world first, surface last.
# Everything else follows from this list — TerrainGenerator builds one 2D array per
# entry, and TerrainRenderer spawns one TileMapLayer node per entry to draw it.
# Add, remove or reorder entries here and nothing else needs touching.
#
# A layer draws every one of its cells with the same material, so ground and stonework
# can't live in the same array. A structure gets overlay layers instead, each sitting
# directly on top of the ground layer it belongs with: what the overlay fills in, that
# ground layer gives up. The two are exact opposites, so between them every cell of the
# level is covered and the ground stays solid all the way down.
const STACK: Array[TileTypes.Type] = [
	TileTypes.Type.BEDROCK,
	TileTypes.Type.DIRT,
	TileTypes.Type.ROCK,    # ruin floors
	TileTypes.Type.DIRT,
	TileTypes.Type.BRICKS,  # ruin walls, first level up
	TileTypes.Type.DIRT,
	TileTypes.Type.BRICKS,  # second
	TileTypes.Type.DIRT,
	TileTypes.Type.BRICKS,  # third
	TileTypes.Type.DIRT,
	TileTypes.Type.HUMUS,
]

# The overlay layers, by index into STACK and bottom first: the first takes a structure's
# floor, the rest one wall level each. They're the only layers that start empty, and only
# where a ruin stands does anything go in them. Everything above them is plain ground,
# which is what leaves a ruin buried.
const STRUCTURE_LAYERS: Array[int] = [2, 4, 6, 8]

static func count() -> int:
	return STACK.size()

static func is_structure_layer(index: int) -> bool:
	return STRUCTURE_LAYERS.has(index)

# How many wall levels the stack has room for above a structure's floor.
static func wall_levels() -> int:
	return STRUCTURE_LAYERS.size() - 1

# The highest layer a wall can reach. Everything above it is ground to dig through.
static func top_structure_layer() -> int:
	return STRUCTURE_LAYERS[-1]
