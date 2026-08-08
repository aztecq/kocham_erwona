class_name TerrainController extends Node2D

var _data: TerrainData
var _renderer: TerrainRenderer
var mouse_left_pressed := false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			mouse_left_pressed = event.pressed


func _process(_delta: float) -> void:
	if mouse_left_pressed:
		_data.dig(
			_renderer.cell_at_global(get_global_mouse_position())
		)
func bind(data: TerrainData, renderer: TerrainRenderer) -> void:
	_data = data
	_renderer = renderer
	
