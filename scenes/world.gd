extends Node2D

@export var width: int = 15
@export var height: int = 15

@onready var renderer: TerrainRenderer = $TerrainRenderer
@onready var controller: TerrainController = $TerrainController
@onready var camera: Camera2D = $Camera2D

var data: TerrainData

func _ready() -> void:
	var types: Array[TileTypes.Type] = [
		TileTypes.Type.BEDROCK, TileTypes.Type.ROCK, TileTypes.Type.ROCK,
		TileTypes.Type.SAND, TileTypes.Type.DIRT, TileTypes.Type.HUMUS
	]
	data = TerrainGenerator.flat(width, height, types)
	renderer.bind(data)
	controller.bind(data, renderer)
	camera.global_position = renderer.world_rect().get_center()
