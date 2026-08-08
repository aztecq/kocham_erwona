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
	TileTypes.Type.DIRT,
	TileTypes.Type.WEIRDDIRT,
	TileTypes.Type.HUMUS,
	TileTypes.Type.GRASS
]

# Where a structure's floor goes. Its walls take the levels above, and whatever is left
# over the top of them is the ground that buries it.
const STRUCTURE_FLOOR_LEVEL := 2

# What a ruin is built out of, and the whole of what tells its floor from its walls: both
# are just materials sitting in the ground where the ruin replaced it.
const STRUCTURE_FLOOR_MATERIAL := TileTypes.Type.ROCK

# One brick per level of wall, and like STACK it reads bottom first: a wall stands on
# BRICKS3, carries BRICKS2 above that, and only the courses that make it all the way up
# are BRICKS1. Which brick a cell gets is decided by the level it's on, not by how tall
# the wall over it happens to be, so a course looks the same the whole way round a ruin.
const STRUCTURE_WALL_MATERIALS: Array[TileTypes.Type] = [
	TileTypes.Type.BRICKS3,
	TileTypes.Type.BRICKS2,
	TileTypes.Type.BRICKS1,
]

static func count() -> int:
	return STACK.size()

# Whether a material is a ruin's stonework — the stuff that costs points to destroy.
static func is_structure_material(type: TileTypes.Type) -> bool:
	return type == STRUCTURE_FLOOR_MATERIAL or STRUCTURE_WALL_MATERIALS.has(type)

# How many levels of wall there's room for above a structure's floor: what's left of the
# stack, and no more courses than there are bricks to build them out of.
static func wall_levels() -> int:
	return mini(STACK.size() - STRUCTURE_FLOOR_LEVEL - 1, STRUCTURE_WALL_MATERIALS.size())
