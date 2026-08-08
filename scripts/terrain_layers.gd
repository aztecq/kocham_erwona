class_name TerrainLayers

# The one place the layer stack is defined: bottom of the world first, surface last.
# Everything else follows from this list — TerrainGenerator builds one 2D array per
# entry, and TerrainRenderer spawns a TileMapLayer per material to draw it.
# Add, remove or reorder entries here and nothing else needs touching.
#
# One entry is one level of the world, and a level is solid: every cell of it holds some
# material. What's named here is only what a level is made of before anything is built
# into it — a structure replaces the ground it stands in, cell for cell.
const STACK: Array[TileTypes.Type] = [
	TileTypes.Type.BEDROCK,
	TileTypes.Type.SAND,
	TileTypes.Type.SAND,
	TileTypes.Type.DIRT,
	TileTypes.Type.WEIRDDIRT,
	TileTypes.Type.HUMUS,
	TileTypes.Type.GRASS
]

# Where a structure's floor goes. Its walls take the levels above, and whatever is left
# over the top of them is the ground that buries it.
const STRUCTURE_FLOOR_LEVEL := 1

# What a ruin is built out of, and the whole of what tells its floor from its walls: both
# are just materials sitting in the ground where the ruin replaced it.
const STRUCTURE_FLOOR_MATERIAL := TileTypes.Type.ROCK
const STRUCTURE_WALL_MATERIAL := TileTypes.Type.BRICKS1

static func count() -> int:
	return STACK.size()

# How many wall levels the stack has room for above a structure's floor.
static func wall_levels() -> int:
	return STACK.size() - STRUCTURE_FLOOR_LEVEL - 1
