extends Node


class_name ToolType
static var tool_efficency: Dictionary = {
	# The brush works the loose fill and nothing else — no turf, no stone. Its numbers are
	# a yes/no only: being unpaced (see `is_unpaced`), it ignores them for speed. They'd
	# start mattering again the moment the brush is put back on the clock.
	[ToolType.Type.BRUSH, TileTypes.Type.SAND]: 		.5,
	[ToolType.Type.BRUSH, TileTypes.Type.DIRT]:  		.5,
	[ToolType.Type.BRUSH, TileTypes.Type.WEIRDDIRT]:  	.4,
	[ToolType.Type.BRUSH, TileTypes.Type.HUMUS]:  		.4,

	[ToolType.Type.PICKAXE, TileTypes.Type.ROCK]: 1,
	[ToolType.Type.PICKAXE, TileTypes.Type.BRICKS1]: 1,
	[ToolType.Type.PICKAXE, TileTypes.Type.BRICKS2]: 1,
	[ToolType.Type.PICKAXE, TileTypes.Type.BRICKS3]: 1,

	# Straight multipliers on the swing rate: 1 is the base pace, 2 is twice as fast, .5
	# is half. The hoe is built for turf and nothing else, so on grass it runs at double
	# — raise this and it keeps getting faster, there's no ceiling.
	[ToolType.Type.HOE, TileTypes.Type.GRASS]: 3.0,

	[ToolType.Type.SHOVEL, TileTypes.Type.WEIRDDIRT]: .6,
	[ToolType.Type.SHOVEL, TileTypes.Type.DIRT]: .6,
	[ToolType.Type.SHOVEL, TileTypes.Type.SAND]: .6,
	[ToolType.Type.SHOVEL, TileTypes.Type.GRASS]: .4,
	[ToolType.Type.SHOVEL, TileTypes.Type.HUMUS]: .6,

	# Stonework is missing from the shovel's row on purpose: it can't take a wall or a
	# floor apart. Swinging at one anyway isn't free, though — see `scuffs` below.
}
enum Type {
	BRUSH,
	PICKAXE,
	HOE,
	SHOVEL
}

# Seconds one swing takes at efficiency 1. A material's real pace is this divided by its
# number in the table above, in both directions: .5 takes twice as long, 2 takes half.
const BASE_SWING_TIME := 0.18

# The cells a swing takes around the cursor. The shovel moves earth in scoopfuls; the
# precise tools work one cell at a time.
static var shapes: Dictionary = {
	Type.SHOVEL: [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1, 0),  Vector2i(0, 0),  Vector2i(1, 0),
		Vector2i(-1, 1),  Vector2i(0, 1),  Vector2i(1, 1),
	],
	Type.BRUSH: [Vector2i.ZERO],
	Type.PICKAXE: [Vector2i.ZERO],
	Type.HOE: [Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0,0), Vector2i(1, 0)],
}

# Only the brush is gentle enough to unearth an artifact without harm — everything else
# knocks it into its damaged form on the way out of the ground.
static func is_gentle(tool: Type) -> bool:
	return tool == Type.BRUSH

# The brush never rests between bites: it's a sweep rather than a swing, so it clears as
# fast as the player can move the mouse. It stays honest because a press still only takes
# one level off any given cell — speed buys ground covered, never depth.
static func is_unpaced(tool: Type) -> bool:
	return tool == Type.BRUSH

# A swing that lands on stonework the tool has no entry for: the stone doesn't budge,
# but the blade leaves a mark on it. That's the price of clearing earth with a blunt
# tool next to something worth keeping — the ScoreCard charges for the mark, once per
# stone, so a careless sweep along a wall costs without levelling it.
#
# A tool that *does* work the stone isn't scuffing, it's demolishing, and gets billed for
# the whole course when the tile comes out. The brush is safe against a ruin by design:
# cleaning the stonework off is what it's for.
static func scuffs(tool: Type, type: TileTypes.Type) -> bool:
	if is_gentle(tool) or not TerrainLayers.is_structure_material(type):
		return false
	return get_tool_efficency(tool, type) <= 0.0

static func get_shape(tool: Type) -> Array:
	return shapes[tool]

static var names: Dictionary = {
	Type.BRUSH: "Pędzel",
	Type.PICKAXE: "Kilof",
	Type.HOE: "Motyka",
	Type.SHOVEL: "Łopata",
}
static func get_tool_efficency(tegoTypuBenc: ToolType.Type, tile_type: TileTypes.Type) -> float:
	var key := [tegoTypuBenc,tile_type]
	if(tool_efficency.has(key)):
		return tool_efficency[key]
	else:
		return 0;
		
