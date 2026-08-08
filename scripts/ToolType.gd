extends Node


class_name ToolType
static var tool_efficency: Dictionary = {
	[ToolType.Type.BRUSH, TileTypes.Type.SAND]: .5,
	[ToolType.Type.BRUSH, TileTypes.Type.DIRT]:  .5,
	[ToolType.Type.BRUSH, TileTypes.Type.WEIRDDIRT]:  .4,
	[ToolType.Type.BRUSH, TileTypes.Type.HUMUS]:  .4,
	
	[ToolType.Type.PICKAXE, TileTypes.Type.ROCK]: 1,
	[ToolType.Type.PICKAXE, TileTypes.Type.BRICKS1]: 1,
	[ToolType.Type.PICKAXE, TileTypes.Type.BRICKS2]: 1,
	[ToolType.Type.PICKAXE, TileTypes.Type.BRICKS3]: 1,

	[ToolType.Type.HOE, TileTypes.Type.GRASS]: 1,

	[ToolType.Type.SHOVEL, TileTypes.Type.WEIRDDIRT]: 1,
	[ToolType.Type.SHOVEL, TileTypes.Type.DIRT]: 1,
	[ToolType.Type.SHOVEL, TileTypes.Type.SAND]: 1,
	[ToolType.Type.SHOVEL, TileTypes.Type.GRASS]: 0.8,
	[ToolType.Type.SHOVEL, TileTypes.Type.HUMUS]: 1
}
enum Type {
	BRUSH,
	PICKAXE,
	HOE,
	SHOVEL
}

# Seconds one swing takes on efficiency 1. A material's real pace is this divided by the
# table above, so the brush at .5 sweeps half as fast as the shovel digs.
const BASE_SWING_TIME := 0.01

# The cells a swing takes around the cursor. The shovel moves earth in scoopfuls; the
# precise tools work one cell at a time.
static var shapes: Dictionary = {
	Type.SHOVEL: [
		Vector2i.ZERO,
		Vector2i(0, -1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, 1),
	],
	Type.BRUSH: [Vector2i.ZERO],
	Type.PICKAXE: [Vector2i.ZERO],
	Type.HOE: [Vector2i.ZERO, Vector2i(-1, 0), Vector2i(1, 0)],
}

# Only the brush is gentle enough to unearth an artifact without harm — everything else
# knocks it into its damaged form on the way out of the ground.
static func is_gentle(tool: Type) -> bool:
	return tool == Type.BRUSH

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
		
