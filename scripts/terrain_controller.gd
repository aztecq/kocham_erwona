class_name TerrainController extends Node2D

# Digging works a level at a time, the way an excavation should: the press picks the
# level, and dragging only strips that level until the button comes back up. Cells
# already deeper are left alone, so sweeping across a half-cleared pit doesn't gouge
# holes in its floor.
#
# What the drag actually does is the tool's business: its shape says which cells a swing
# covers, the efficiency table says whether it bites a material at all and how fast, and
# only the brush brings artifacts out of the ground undamaged.

signal tool_changed(tool: ToolType.Type)
# A swing landed on stonework this tool can't work. The stone stays where it is; the
# ScoreCard decides what the mark costs.
signal stone_struck(cell: Vector2i)
# Where the blade came down, whether it moved any earth or not. Everything living on the
# ground it swept through is in the way of it.
signal swing_landed(cells: Array[Vector2i])

const TOOL_KEYS := {
	KEY_1: ToolType.Type.SHOVEL,
	KEY_2: ToolType.Type.BRUSH,
	KEY_3: ToolType.Type.PICKAXE,
	KEY_4: ToolType.Type.HOE,
}

var tool: ToolType.Type = ToolType.Type.SHOVEL

# The level being stripped by the current drag; NOT_DIGGING between drags.
const NOT_DIGGING := -1
var _locked_level := NOT_DIGGING
# Time left until the swing under way lands. The first one lands immediately.
var _swing := 0.0

var _data: TerrainData
var _artifacts: ArtifactData
var _renderer: TerrainRenderer

func bind(data: TerrainData, renderer: TerrainRenderer, artifacts: ArtifactData) -> void:
	_data = data
	_renderer = renderer
	_artifacts = artifacts

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and TOOL_KEYS.has(event.keycode):
		tool = TOOL_KEYS[event.keycode]
		tool_changed.emit(tool)
		return
	if event is not InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT:
		return
	if event.pressed:
		_press(_renderer.cell_at_global(get_global_mouse_position()))
	else:
		_locked_level = NOT_DIGGING

func _process(delta: float) -> void:
	if _locked_level != NOT_DIGGING:
		_drag(_renderer.cell_at_global(get_global_mouse_position()), delta)

# A find lying in the open is picked up instead of dug, so digging can never bury one
# again or carry the ground out from under it. Otherwise the press locks onto the level
# it hit and the first swing lands at once. Nobody pays here: the ScoreCard hears about
# the pickup and the money comes at the end of the level, priced by how the dig went.
func _press(cell: Vector2i) -> void:
	if _artifacts.take(cell) != null:
		return
	if _data.is_inside(cell):
		_locked_level = _data.top_level(cell)
		_swing = 0.0

func _drag(center: Vector2i, delta: float) -> void:
	var targets := _swing_targets(center)
	var struck := _struck_stone(center)
	# No early out on an empty swing: a blade coming down on cleared ground still comes
	# down, and whatever is standing there is still under it.
	_swing -= delta
	if _swing > 0.0:
		return
	# The swing paces itself by the slowest material under it, so a tool crossing easy
	# sand doesn't speed up clearing the stubborn patch beside it. Efficiency above 1
	# really does run faster — that's how a tool built for one material beats a
	# general-purpose one at it. A swing at nothing but stone has no material to pace
	# against, and takes one full swing.
	var slowest := 1.0
	if not targets.is_empty():
		slowest = 0.0
		for cell in targets:
			slowest = maxf(slowest, 1.0 / _efficiency_at(cell))
	_swing = 0.0 if ToolType.is_unpaced(tool) else ToolType.BASE_SWING_TIME * slowest
	# The blade lands before the earth moves, and the order matters: whatever is standing
	# here is caught by this swing, but whatever the swing turns up crawls out of ground
	# that has already been cut. Emitted the other way round, every worm a dig produced
	# would be killed by the dig that produced it.
	swing_landed.emit(_swing_area(center))
	for cell in targets:
		_dig_cell(cell)
	for cell in struck:
		stone_struck.emit(cell)

# The cells this swing will actually bite: covered by the tool, made of something the
# tool works on, and not holding an uncovered find — those wait for a deliberate click.
func _swing_targets(center: Vector2i) -> Array[Vector2i]:
	var targets: Array[Vector2i] = []
	for cell in _cells_under(center):
		if _artifacts.at(cell) != null or _efficiency_at(cell) <= 0.0:
			continue
		targets.append(cell)
	return targets

# The cells the same swing hits without being able to work them: stonework under a tool
# that has no business on it. They aren't dug, only marked.
func _struck_stone(center: Vector2i) -> Array[Vector2i]:
	var struck: Array[Vector2i] = []
	for cell in _cells_under(center):
		if ToolType.scuffs(tool, _data.top_type(cell)):
			struck.append(cell)
	return struck

# Every cell the tool's shape reaches on the map. This is the swing itself, level lock or
# not — the blade passes over these whether or not there's anything here it can work.
func _swing_area(center: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for offset: Vector2i in ToolType.get_shape(tool):
		var cell := center + offset
		if _data.is_inside(cell):
			cells.append(cell)
	return cells

# The part of the swing this drag may work: still at the level the press locked onto.
# Cells already deeper belong to earlier swings and are left alone.
func _cells_under(center: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for cell in _swing_area(center):
		if _data.top_level(cell) == _locked_level:
			cells.append(cell)
	return cells

func _efficiency_at(cell: Vector2i) -> float:
	return ToolType.get_tool_efficency(tool, _data.top_type(cell))

# One dig, plus its consequence: if it brought a find into the open, anything but the
# brush knocks the find into its damaged form on the way out of the ground.
func _dig_cell(cell: Vector2i) -> void:
	if _data.dig(cell) == TileTypes.Type.NONE:
		return
	var artifact := _artifacts.at(cell)
	if artifact != null and not ToolType.is_gentle(tool):
		_artifacts.degrade(artifact)
		
func is_digging() -> bool:
	return _locked_level != NOT_DIGGING
