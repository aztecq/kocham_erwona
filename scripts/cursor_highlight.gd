class_name CursorHighlight extends Node2D

# Outlines the cells the current tool would touch, in the language of consequences:
# white for ground it will bite, gold for a find waiting to be picked up, red for
# stonework or a buried find the tool would wreck, dim for materials it refuses.
# A child of the TerrainRenderer, so cell coordinates are local coordinates.

const BITES := Color(1, 1, 1, 0.9)
const REFUSES := Color(1, 1, 1, 0.25)
const PICKUP := Color(1.0, 0.85, 0.3, 0.95)
const WRECKS := Color(0.95, 0.3, 0.25, 0.95)
const LINE_WIDTH := 2.0

var _data: TerrainData
var _artifacts: ArtifactData
var _renderer: TerrainRenderer
var _controller: TerrainController

func bind(
	data: TerrainData,
	renderer: TerrainRenderer,
	artifacts: ArtifactData,
	controller: TerrainController
) -> void:
	_data = data
	_renderer = renderer
	_artifacts = artifacts
	_controller = controller

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if _data == null:
		return
	var center := _renderer.cell_at_global(get_global_mouse_position())
	var tile_size := Vector2(_renderer.tile_set.tile_size)
	for offset: Vector2i in ToolType.get_shape(_controller.tool):
		var cell: Vector2i = center + offset
		if not _data.is_inside(cell):
			continue
		draw_rect(Rect2(Vector2(cell) * tile_size, tile_size), _color_for(cell), false, LINE_WIDTH)

func _color_for(cell: Vector2i) -> Color:
	if _artifacts.at(cell) != null:
		return PICKUP
	var top := _data.top_type(cell)
	if ToolType.get_tool_efficency(_controller.tool, top) <= 0.0:
		return REFUSES
	# The tool bites — the question is what. Stonework going under it, or a find lying
	# just beneath this tile with a rough tool over it, means the swing costs points.
	if TerrainLayers.is_structure_material(top):
		return WRECKS
	if not ToolType.is_gentle(_controller.tool) and _buried_find_just_below(cell):
		return WRECKS
	return BITES

func _buried_find_just_below(cell: Vector2i) -> bool:
	var artifact := _artifacts.buried_at(cell)
	return artifact != null and _data.top_level(cell) == artifact.level
