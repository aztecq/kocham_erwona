extends Node2D

# Fallbacks for running the scene by itself; a real run takes its size from Run.
@export var width: int = 15
@export var height: int = 15
@export var structure_count: int = 1

@onready var renderer: TerrainRenderer = $TerrainRenderer
@onready var controller: TerrainController = $TerrainController
@onready var cursor_tool: CursorTool = $CursorTool
@onready var camera: Camera2D = $Camera2D

var data: TerrainData
var artifacts: ArtifactData
var score: ScoreCard

var _hud: CanvasLayer
var _coins_label: Label
var _progress_bar: ProgressBar
var _damage_label: Label
var _tool_label: Label

var camera_dragging := false

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_MIDDLE:
			camera_dragging = event.pressed
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom *= 1.1
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
			camera.zoom /= 1.1
	if event is InputEventMouseMotion:
		if camera_dragging:
			camera.position -= event.relative

func _ready() -> void:
	var params := Run.level_params()
	width = params.width
	height = params.height
	structure_count = params.structures

	data = TerrainGenerator.flat(width, height, structure_count)
	artifacts = ArtifactGenerator.bury(data)
	# All plain Nodes, parented rather than left dangling — otherwise they outlive the
	# scene and the engine reports them leaked on the way out.
	data.name = "TerrainData"
	add_child(data)
	add_child(artifacts)
	score = ScoreCard.new()
	score.name = "ScoreCard"
	add_child(score)
	score.bind(data, artifacts, controller)
	renderer.bind(data)
	cursor_tool.bind(controller)
	# Added from code, after the terrain, so the finds draw over it. How many there are
	# is a property of the site rather than of the scene, so there's nothing to place by
	# hand in the editor.
	var artifact_renderer := ArtifactRenderer.new()
	artifact_renderer.name = "ArtifactRenderer"
	add_child(artifact_renderer)
	artifact_renderer.bind(artifacts, renderer)
	controller.bind(data, renderer, artifacts)
	# On the renderer so cells are its local coordinates, above the tilemaps in draw order.
	var highlight := CursorHighlight.new()
	highlight.name = "CursorHighlight"
	renderer.add_child(highlight)
	highlight.bind(data, renderer, artifacts, controller)
	camera.global_position = renderer.world_rect().get_center()
	_build_hud()

# Coins in the same words the shop uses, the dig's progress against everything the site
# holds, and the way out. Built here rather than in the scene so it can't drift out of
# step with the objects it reads.
func _build_hud() -> void:
	_hud = CanvasLayer.new()
	_hud.name = "HUD"
	add_child(_hud)

	var panel := VBoxContainer.new()
	panel.position = Vector2(16, 12)
	_hud.add_child(panel)

	var level_label := Label.new()
	level_label.add_theme_font_size_override("font_size", 18)
	level_label.text = "Poziom %d" % Run.level
	panel.add_child(level_label)

	_coins_label = Label.new()
	_coins_label.add_theme_font_size_override("font_size", 28)
	panel.add_child(_coins_label)

	_progress_bar = ProgressBar.new()
	_progress_bar.custom_minimum_size = Vector2(240, 22)
	_progress_bar.max_value = 1.0
	_progress_bar.step = 0.001
	panel.add_child(_progress_bar)

	_damage_label = Label.new()
	_damage_label.add_theme_font_size_override("font_size", 18)
	_damage_label.add_theme_color_override("font_color", Color(0.9, 0.35, 0.3))
	panel.add_child(_damage_label)

	_tool_label = Label.new()
	_tool_label.add_theme_font_size_override("font_size", 18)
	panel.add_child(_tool_label)

	var finish := Button.new()
	finish.text = "Zakończ wykopaliska"
	finish.pressed.connect(_finish_level)
	panel.add_child(finish)

	Wallet.coins_changed.connect(_show_coins)
	_show_coins(Wallet.coins)
	score.changed.connect(_show_score)
	_show_score()
	controller.tool_changed.connect(_show_tool)
	_show_tool(controller.tool)

func _show_coins(coins: int) -> void:
	_coins_label.text = "Monety: %s" % coins

func _show_tool(tool: ToolType.Type) -> void:
	_tool_label.text = "[1-4] %s" % ToolType.names[tool]

func _show_score() -> void:
	_progress_bar.value = score.fraction()
	_damage_label.text = "Zniszczenia: %d" % score.damaged
	_damage_label.visible = score.damaged > 0

# The player's call that the dig is done: tools down, the ledger read out, and the pay
# handed over on the way to the shop.
func _finish_level() -> void:
	controller.set_process(false)
	controller.set_process_unhandled_input(false)
	_summary()

func _summary() -> void:
	var payout := score.payout()

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hud.add_child(dim)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	box.grow_vertical = Control.GROW_DIRECTION_BOTH
	dim.add_child(box)

	var title := Label.new()
	title.add_theme_font_size_override("font_size", 34)
	title.text = "Poziom %d zakończony" % Run.level
	box.add_child(title)

	var stats := Label.new()
	stats.add_theme_font_size_override("font_size", 22)
	stats.text = "Postęp: %d%%\nOdkryto: %d pkt\nZniszczenia: %d pkt\nWypłata: %d monet" % [
		roundi(score.fraction() * 100), score.discovered, score.damaged, payout
	]
	box.add_child(stats)

	var to_shop := Button.new()
	to_shop.text = "Do sklepu"
	to_shop.pressed.connect(func():
		Wallet.add(payout)
		Run.advance()
		get_tree().change_scene_to_file("res://scenes/sklepito.tscn")
	)
	box.add_child(to_shop)
