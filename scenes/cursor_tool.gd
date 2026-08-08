class_name CursorTool extends AnimatedSprite2D


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

# Narzędzie w dłoni gracza. Animacje nazwane po enumie: "shovel", "shovel_dig", ...
const OFFSET := Vector2(10, -6)   # żeby ostrze wskazywało kafel, a nie środek grafiki

var _controller: TerrainController

func bind(controller: TerrainController) -> void:
	_controller = controller
	controller.tool_changed.connect(_show_tool)
	_show_tool(controller.tool)

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position() + OFFSET
	var wanted := _animation_for(_controller.tool)
	if animation != wanted:
		play(wanted)

func _animation_for(tool: ToolType.Type) -> StringName:
	var base: String
	match tool:
		ToolType.Type.BRUSH: 	base = 'brush'
		ToolType.Type.PICKAXE: 	base = 'pickaxe'
		ToolType.Type.HOE: 		base = 'hoe'
		ToolType.Type.SHOVEL: 	base = 'shovel'
	return StringName(base + "_dig" if _controller.is_digging() else base)
	
func _show_tool(tool):
	pass
