class_name TerrainController extends Node2D

var _data: TerrainData
var _renderer: TerrainRenderer

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		_data.dig(_renderer.cell_at_global(get_global_mouse_position()))

func bind(data: TerrainData, renderer: TerrainRenderer) -> void:
	_data = data
	_renderer = renderer
	#data.tile_changed.connect(_on_tile_changed)
	
