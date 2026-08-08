class_name TerrainRenderer extends Node2D

# Shared by every spawned layer. Set on the TerrainRenderer node in the scene.
@export var tile_set: TileSet

@onready var dual_grid: DualGrid = $DualGrid

# One TileMapLayer per material present in a level, keyed by material: _passes[level].
#
# A display tile is a single tile out of a single material's block, but it straddles the
# four world cells at its corners. When those four cells aren't all the same material, no
# one tile can draw them — so each material gets a pass of its own, drawn masked to its
# own cells and letting the passes beside it show through. A level of one material, which
# is most of them, still comes out as one node.
var _passes: Array[Dictionary] = []

var _data: TerrainData

func bind(data: TerrainData) -> void:
	_data = data
	data.tile_changed.connect(_on_tile_changed)
	_build_passes()
	_redraw_all()

# The scene holds no layer nodes: how many there are is a property of the terrain, so
# they're spawned to match it. Added bottom level first, which is also the draw order.
func _build_passes() -> void:
	for level_passes in _passes:
		for tilemap in level_passes.values():
			# Removed before freeing so the new nodes can reuse the same names.
			remove_child(tilemap)
			tilemap.queue_free()
	_passes.clear()

	for level in _data.layers.size():
		var level_passes := {}
		for material in _materials_in(level):
			var tilemap := TileMapLayer.new()
			tilemap.name = "Level%d_%s" % [level + 1, TileTypes.Type.keys()[material]]
			tilemap.tile_set = tile_set
			# A display tile straddles the four world cells at its corners, so the tilemap
			# layers sit half a tile down and right of the world grid they describe.
			tilemap.position = Vector2(tile_set.tile_size) / 2.0
			add_child(tilemap)
			level_passes[material] = tilemap
		_passes.append(level_passes)

# What a level is actually made of, its own ground material first so anything built into
# it draws over the top. Digging only ever takes material away, so a level never gains a
# material later and this holds for the life of the terrain.
func _materials_in(level: int) -> Array[TileTypes.Type]:
	var found: Array[TileTypes.Type] = []
	for y in _data.height:
		for x in _data.width:
			var material: TileTypes.Type = _data.layers[level][y][x]
			if material != TileTypes.Type.NONE and not found.has(material):
				found.append(material)
	var ground := _data.layer_types[level]
	if found.has(ground):
		found.erase(ground)
		found.push_front(ground)
	return found

func _on_tile_changed(level: int, cell: Vector2i, _type: TileTypes.Type):
	# Four display tiles touch the changed cell: the ones up-left of it through to itself.
	_edit_terrain(level, cell, Vector2i(4, 4))

func _redraw_all():
	for level in _data.layers.size():
		_redraw_level(level)

func _redraw_level(level: int) -> void:
	# Display cells run from -1 so the map's top and left edges get drawn too.
	for y in range(-1, _data.height):
		for x in range(-1, _data.width):
			_set_display_cell(level, x, y)

# Bounds of the world grid in global space. Like cell_at_global, this ignores the
# layers' half-tile display offset — it describes world cells, not display tiles.
func world_rect() -> Rect2:
	return Rect2(global_position, Vector2(_data.width, _data.height) * Vector2(tile_set.tile_size))

# Centre of a world cell in global space — where anything standing on the terrain goes.
# The inverse of cell_at_global, and free of the display offset for the same reason.
func global_at_cell(cell: Vector2i) -> Vector2:
	return to_global((Vector2(cell) + Vector2(0.5, 0.5)) * Vector2(tile_set.tile_size))

func cell_at_global(global_pos: Vector2) -> Vector2i:
	# Deliberately not via a TileMapLayer: those carry the half-tile display offset,
	# and this has to return a world cell.
	var local := to_local(global_pos)
	var tile_size := tile_set.tile_size
	return Vector2i(floori(local.x / tile_size.x), floori(local.y / tile_size.y))

func _edit_terrain(level: int, grid_position: Vector2i, fragment_size: Vector2i) -> void:
	var start := grid_position - fragment_size / 2
	for y in range(start.y, start.y + fragment_size.y):
		for x in range(start.x, start.x + fragment_size.x):
			_set_display_cell(level, x, y)

# Every pass of the level is redrawn together: a cell dropping out of one material's mask
# moves where that pass's edge falls, and the pass beside it has to take the edge up.
func _set_display_cell(level: int, x: int, y: int) -> void:
	if x < -1 or y < -1 or x >= _data.width or y >= _data.height:
		return
	for material in _passes[level]:
		# Clockwise from top-right, which is the order DualGrid's lookup table is keyed in.
		var corners: Array[TileTypes.Type] = [
			_material_at(level, material, x + 1, y),
			_material_at(level, material, x + 1, y + 1),
			_material_at(level, material, x, y + 1),
			_material_at(level, material, x, y)
		]
		var tilemap: TileMapLayer = _passes[level][material]
		# None of this material meets here. Erased rather than drawn as the block's empty
		# tile: it saves a draw on every cell a pass doesn't reach, which is most of them,
		# and a block cut from a sheet with a blank bottom-right corner has no empty tile
		# to ask for in the first place.
		if _is_blank(corners):
			tilemap.erase_cell(Vector2i(x, y))
			continue
		tilemap.set_cell(
			Vector2i(x, y), TileAtlas.DUAL_SOURCE_ID,
			dual_grid.get_tile(TileAtlas.block_for(material), corners)
		)

static func _is_blank(corners: Array[TileTypes.Type]) -> bool:
	for corner in corners:
		if corner != TileTypes.Type.NONE:
			return false
	return true

# A cell holding some other material reads as empty to this pass — that's what leaves a
# gap for the pass drawing that other material to fill. Cells off the edge of the map
# read as empty too, so the border resolves to a proper edge instead of wrapping around
# to the far side of the array.
func _material_at(level: int, material: TileTypes.Type, x: int, y: int) -> TileTypes.Type:
	if x < 0 or y < 0 or x >= _data.width or y >= _data.height:
		return TileTypes.Type.NONE
	var found: TileTypes.Type = _data.layers[level][y][x]
	return found if found == material else TileTypes.Type.NONE
