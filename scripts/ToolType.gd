extends Node


class_name ToolType
static var tool_efficency: Dictionary = {
	[ToolType.Type.BRUSH, TileTypes.Type.SAND]: .5,
	[ToolType.Type.BRUSH, TileTypes.Type.DIRT]:  .5,
	[ToolType.Type.BRUSH, TileTypes.Type.WEIRDDIRT]:  .4,
	[ToolType.Type.BRUSH, TileTypes.Type.HUMUS]:  .4,
	
	[ToolType.Type.PICKAXE, TileTypes.Type.ROCK]: 1,

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
static func get_tool_efficency(tegoTypuBenc: ToolType.Type, tile_type: TileTypes.Type) -> float:
	var key := [tegoTypuBenc,tile_type]
	if(tool_efficency.has(key)):
		return tool_efficency[key]
	else:
		return 0;
		
