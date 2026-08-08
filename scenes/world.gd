extends Node2D

@export var width: int = 15
@export var height: int = 15

@onready var renderer: TerrainRenderer = $TerrainRenderer
@onready var controller: TerrainController = $TerrainController
@onready var camera: Camera2D = $Camera2D

var data: TerrainData
var artifacts: ArtifactData

var _coins_label: Label

func _ready() -> void:
	data = TerrainGenerator.flat(width, height)
	artifacts = ArtifactGenerator.bury(data)
	# Both are Nodes, so they're parented rather than left dangling — otherwise they
	# outlive the scene and the engine reports them leaked on the way out.
	data.name = "TerrainData"
	add_child(data)
	add_child(artifacts)
	renderer.bind(data)
	# Added from code, after the terrain, so the finds draw over it. How many there are
	# is a property of the site rather than of the scene, so there's nothing to place by
	# hand in the editor.
	var artifact_renderer := ArtifactRenderer.new()
	artifact_renderer.name = "ArtifactRenderer"
	add_child(artifact_renderer)
	artifact_renderer.bind(artifacts, renderer)
	controller.bind(data, renderer, artifacts)
	camera.global_position = renderer.world_rect().get_center()
	_build_hud()

# The coin counter, in the same words the shop uses. Built here rather than in the scene
# so it can't drift out of step with the Wallet it reads.
func _build_hud() -> void:
	var hud := CanvasLayer.new()
	hud.name = "HUD"
	add_child(hud)
	_coins_label = Label.new()
	_coins_label.add_theme_font_size_override("font_size", 28)
	_coins_label.position = Vector2(16, 12)
	hud.add_child(_coins_label)
	Wallet.coins_changed.connect(_show_coins)
	_show_coins(Wallet.coins)

func _show_coins(coins: int) -> void:
	_coins_label.text = "Monety: %s" % coins
