extends Node2D

@export var width: int = 41
@export var height: int = 21

@onready var renderer: TerrainRenderer = $TerrainRenderer
@onready var controller: TerrainController = $TerrainController

var data: TerrainData

func _ready() -> void:
	var types: Array[TileTypes.Type] = [
		TileTypes.Type.BEDROCK, TileTypes.Type.ROCK, TileTypes.Type.ROCK,
		TileTypes.Type.SAND, TileTypes.Type.DIRT, TileTypes.Type.BRICKS
	]
	data = TerrainGenerator.flat(width, height, types)
	renderer.bind(data)
	controller.bind(data, renderer)
