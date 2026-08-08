class_name TerrainController extends Node2D

var _data: TerrainData
var _artifacts: ArtifactData
var _renderer: TerrainRenderer
var mouse_left_pressed := false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			_data.select_layer(
				_renderer.cell_at_global(get_global_mouse_position())
			)
			
	if event is InputEventMouseButton and event.is_released():
		if event.button_index == MOUSE_BUTTON_LEFT:
			_data.deselect_layer()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_click(
				_renderer.cell_at_global(get_global_mouse_position())
			)
			mouse_left_pressed = event.pressed


func _process(_delta: float) -> void:
	if mouse_left_pressed:
		scratch_terrain()
		#brush(1, ToolType.Type.SHOVEL, 1, _delta)

func scratch_terrain() -> void:
	if mouse_left_pressed:
		_data.scrach_level(
			_renderer.cell_at_global(get_global_mouse_position())
		)
		
func brush(size: int, tool_type: ToolType.Type, speed: int, _delta: float) -> void:
	if mouse_left_pressed:
		_data.fancy_dig(
			_renderer.cell_at_global(get_global_mouse_position()),
			size, tool_type, speed, _delta
		)
	
func bind(data: TerrainData, renderer: TerrainRenderer) -> void:
#func _process(_delta: float) -> void:
	#if mouse_left_pressed:
		#_click(
			#_renderer.cell_at_global(get_global_mouse_position())
		#)

# A find lying in the open is picked up instead of dug, so digging can never bury one
# again or carry the ground out from under it.
func _click(cell: Vector2i) -> void:
	var artifact := _artifacts.take(cell)
	if artifact != null:
		Wallet.add(artifact.value)
		return
	_data.dig(cell)

func bind(data: TerrainData, renderer: TerrainRenderer, artifacts: ArtifactData) -> void:
	_data = data
	_renderer = renderer
	_artifacts = artifacts
