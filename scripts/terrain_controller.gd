class_name TerrainController extends Node2D

var _data: TerrainData
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
			_data.dig(
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
	_data = data
	_renderer = renderer
	
