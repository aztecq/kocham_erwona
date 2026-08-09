extends Node2D

# Fallbacks for running the scene by itself; a real run takes its size from Run.
@export var width: int = 15
@export var height: int = 15
@export var structure_count: int = 1

@onready var renderer: TerrainRenderer = $TerrainRenderer
@onready var controller: TerrainController = $TerrainController
@onready var cursor_tool: CursorTool = $CursorTool
@onready var camera: Camera2D = $Camera2D

# How far the tool in hand stands out of the rack.
const TOOL_LIFT := 8.0

# The dig's readouts, laid out in the scene. This only fills them in.
@onready var _hud: CanvasLayer = $HUD
@onready var _level_label: Label = %LabelLevel
@onready var _progress_bar: ProgressBar = %ProgressBar
@onready var _penalty_label: Label = %LabelPenalty2
@onready var _toolbar: HBoxContainer = %Toolbar

# The rack, left to right, against the tools it racks. Which tool a slot is comes from
# TerrainController's keys rather than from here, so the row can't say 3 and hand over a
# shovel — the labels in the scene are those same numbers.
var _slots: Array[Control] = []
var _slot_tools: Array[ToolType.Type] = []
# Where the row put each slot. Read back from the container after it lays the row out,
# because that line is the container's to decide and the lift is measured from it.
var _slot_home := PackedFloat32Array()

var data: TerrainData
var artifacts: ArtifactData
var score: ScoreCard

var camera_dragging := false

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_MIDDLE:
			camera_dragging = event.pressed
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom /= 1.1
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
			camera.zoom *= 1.1
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
	var worms := WormSpawner.new()
	worms.name = "WormSpawner"
	add_child(worms)
	worms.bind(data, renderer, controller)
	# On the renderer so cells are its local coordinates, above the tilemaps in draw order.
	var highlight := CursorHighlight.new()
	highlight.name = "CursorHighlight"
	renderer.add_child(highlight)
	highlight.bind(data, renderer, artifacts, controller)
	camera.global_position = renderer.world_rect().get_center()
	_bind_hud()

# The readouts are the scene's; what they say is the ledger's. Hooked up here so a number
# on screen can't drift out of step with the object it reads — nothing pushes to the HUD,
# it's redrawn whenever the score changes.
func _bind_hud() -> void:
	_level_label.text = "Level %d" % Run.level
	%ButtonEnd.pressed.connect(_finish_level)
	score.changed.connect(_show_score)
	_show_score()
	_bind_toolbar()

# The rack: a slot per tool, in the order the number keys are in, and clicking one is the
# same as pressing its number. The icons are the scene's — this only tints them the way
# the player bought them and marks which one is in hand.
func _bind_toolbar() -> void:
	var tools := TerrainController.TOOL_KEYS.values()
	for i in mini(tools.size(), _toolbar.get_child_count()):
		var slot: Control = _toolbar.get_child(i)
		var tool: ToolType.Type = tools[i]
		_slots.append(slot)
		_slot_tools.append(tool)
		# One button per slot, frame and icon included, the same way the shop's options
		# take a click anywhere on themselves.
		InteractablePanelContainer.claim_mouse(slot)
		slot.gui_input.connect(_on_slot_input.bind(tool))
		var icon := slot.find_child("Icon")
		if icon is CanvasItem:
			icon.modulate = ToolSkins.tint(Run.skin_for(tool))
	_slot_home.resize(_slots.size())

	# The row decides where the slots sit; the lift is put back on top of that decision
	# every time it re-decides, so a resize can't leave a tool stranded out of line.
	_toolbar.sort_children.connect(_place_slots)
	_toolbar.queue_sort()
	controller.tool_changed.connect(_show_tool)

func _on_slot_input(event: InputEvent, tool: ToolType.Type) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		controller.select_tool(tool)

func _place_slots() -> void:
	for i in _slots.size():
		_slot_home[i] = _slots[i].position.y
	_show_tool(controller.tool)

# The tool in hand stands a little out of the rack; the rest sit on the line the row gave
# them.
func _show_tool(tool: ToolType.Type) -> void:
	for i in _slots.size():
		_slots[i].position.y = _slot_home[i] - (TOOL_LIFT if _slot_tools[i] == tool else 0.0)

func _show_score() -> void:
	# Against the bar's own scale, so the range set in the editor is the one that counts.
	_progress_bar.value = score.fraction() * _progress_bar.max_value
	_penalty_label.text = str(score.penalty())

# The player's call that the dig is done: tools down, the ledger read out, and the pay
# handed over on the way to the shop.
func _finish_level() -> void:
	$ButtonSFX.play()
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
	title.text = "Level %d complete" % Run.level
	box.add_child(title)

	var stats := Label.new()
	stats.add_theme_font_size_override("font_size", 22)
	# The same penalty the HUD was counting up, so the summary only tells the player what
	# it comes to rather than anything new.
	stats.text = "Progress: %d%%\nUncovered: %d pts\nPenalty: %d coins\nPayout: %d coins" % [
		roundi(score.fraction() * 100), score.discovered, score.penalty(), payout
	]
	box.add_child(stats)

	var to_shop := Button.new()
	to_shop.text = "To the shop"
	to_shop.pressed.connect(func():
		$ButtonSFX.play()
		Wallet.add(payout)
		Run.advance()
		get_tree().change_scene_to_file("res://scenes/shop.tscn")
	)
	box.add_child(to_shop)
