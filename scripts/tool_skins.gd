class_name ToolSkins extends RefCounted

# What the shop sells: a look for a tool, never a change to how it digs. Efficiency,
# shape and pace stay in ToolType, so a skin can never be a shortcut past the dig — it's
# a strip of art plus a tint over it, and the only thing that reads it is the cursor.
#
# Adding one is a row in `catalog`. Leave `sheet` empty and the skin is the tool's own
# art under a different tint; point it at another image to reskin the tool outright. What
# "the tool's own art" means is never written down twice — it's whatever the cursor's
# frames say, so animations redrawn in the editor turn up in the game and on the shop
# shelf without a line changing here.
#
# A skin that brings its own sheet has to keep the frame layout of the one it replaces:
# the frames keep their regions and only change which image they're cut from.

const BASE_FRAMES := preload("res://scenes/cursor_tool_frames.tres")

# The shelf, in the order the shop lays it out: a column per tool, the plain one every
# run starts with on top and what it can be traded for underneath. A price of 0 means the
# skin is owned from the first level — that's what makes the top row the way back.
static var catalog: Dictionary = {
	&"shovel_plain": {tool = ToolType.Type.SHOVEL, name = "Shovel", price = 0, sheet = "", tint = Color.WHITE},
	&"brush_plain": {tool = ToolType.Type.BRUSH, name = "Brush", price = 0, sheet = "", tint = Color.WHITE},
	&"pickaxe_plain": {tool = ToolType.Type.PICKAXE, name = "Pickaxe", price = 0, sheet = "", tint = Color.WHITE},
	&"hoe_plain": {tool = ToolType.Type.HOE, name = "Hoe", price = 0, sheet = "", tint = Color.WHITE},

	&"shovel_bronze": {tool = ToolType.Type.SHOVEL, name = "Bronze Shovel", price = 50, sheet = "", tint = Color(0.85, 0.55, 0.3)},
	&"brush_azure": {tool = ToolType.Type.BRUSH, name = "Azure Brush", price = 50, sheet = "", tint = Color(0.55, 0.75, 1.0)},
	&"pickaxe_ruby": {tool = ToolType.Type.PICKAXE, name = "Ruby Pickaxe", price = 50, sheet = "", tint = Color(1.0, 0.45, 0.45)},
	&"hoe_emerald": {tool = ToolType.Type.HOE, name = "Emerald Hoe", price = 50, sheet = "", tint = Color(0.45, 0.95, 0.6)},
}

# Built the first time they're asked for and kept: the shop redraws every panel on every
# purchase, and cutting the same icon out eight times over would show.
static var _sheet_cache: Dictionary = {}
static var _icon_cache: Dictionary = {}

static func ids() -> Array:
	return catalog.keys()

static func get_skin(id: StringName) -> Dictionary:
	return catalog[id]

static func tool_of(id: StringName) -> ToolType.Type:
	return catalog[id].tool

static func price(id: StringName) -> int:
	return catalog[id].price

static func skin_name(id: StringName) -> String:
	return catalog[id].name

static func tint(id: StringName) -> Color:
	return catalog[id].tint

# The one a tool wears until something is bought for it: the free skin on its column.
static func default_for(tool: ToolType.Type) -> StringName:
	for id in catalog:
		if catalog[id].tool == tool and catalog[id].price == 0:
			return id
	return &""

# The image a skin's frames are cut from, or null when it wears the tool's own art —
# which is the answer for every skin that's only a tint, and the reason nothing here has
# to know where the cursor's strips live.
static func sheet_of(id: StringName) -> Texture2D:
	if not _sheet_cache.has(id):
		var path: String = catalog[id].sheet
		_sheet_cache[id] = load(path) if not path.is_empty() else null
	return _sheet_cache[id]

# The resting frame on its own, for the shop shelf: the same picture the cursor rests in,
# so the shelf can't show a tool the game doesn't. Untinted — whoever draws it applies the
# skin's tint, and can dim it when the player can't afford it.
static func icon(id: StringName) -> Texture2D:
	if not _icon_cache.has(id):
		var resting := BASE_FRAMES.get_frame_texture(ToolType.animations[catalog[id].tool], 0)
		_icon_cache[id] = reskinned(resting, sheet_of(id))
	return _icon_cache[id]

# The same frame cut from a skin's sheet instead: the region is kept, only the image
# under it changes. A skin without a sheet of its own is handed back the frame untouched.
static func reskinned(frame: Texture2D, sheet: Texture2D) -> Texture2D:
	if sheet == null or frame is not AtlasTexture or frame.atlas == sheet:
		return frame
	var swapped := AtlasTexture.new()
	swapped.atlas = sheet
	swapped.region = frame.region
	swapped.margin = frame.margin
	swapped.filter_clip = frame.filter_clip
	return swapped
