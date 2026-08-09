class_name CursorTool extends AnimatedSprite2D


# Narzędzie w dłoni gracza. Animacje nazwane po enumie: "shovel", "shovel_dig", ... —
# wszystkie leżą w cursor_tool_frames.tres i to one są narzędziem takim, jakie jest
# naprawdę; skórka ze sklepu tylko przemalowuje je po drodze.
const OFFSET := Vector2(10, -6)   # żeby ostrze wskazywało kafel, a nie środek grafiki

var _controller: TerrainController

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	_take_own_frames()
	# Bez kontrolera nie ma czego rysować ani za czym chodzić — kursor rusza po bind().
	set_process(false)

func bind(controller: TerrainController) -> void:
	_controller = controller
	set_process(true)
	controller.tool_changed.connect(_show_tool)
	_show_tool(controller.tool)

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position() + OFFSET
	var wanted := _animation_for(_controller.tool)
	if animation != wanted:
		play(wanted)

func _animation_for(tool: ToolType.Type) -> StringName:
	return ToolType.dig_animation(tool) if _controller.is_digging() else ToolType.animations[tool]

# Zakładanie skórki przepisuje klatki, a te są wspólnym zasobem — kursor pracuje więc na
# własnej kopii. Kopia trzyma te same tekstury, co plik, dopóki czegoś nie przemaluje.
func _take_own_frames() -> void:
	var base := ToolSkins.BASE_FRAMES
	var mine := SpriteFrames.new()
	for anim in base.get_animation_names():
		mine.add_animation(anim)
		mine.set_animation_speed(anim, base.get_animation_speed(anim))
		mine.set_animation_loop(anim, base.get_animation_loop(anim))
		for i in base.get_frame_count(anim):
			mine.add_frame(anim, base.get_frame_texture(anim, i), base.get_frame_duration(anim, i))
	# SpriteFrames zaczyna z pustą "default" — po skopiowaniu reszty nie jest już potrzebna.
	mine.remove_animation(&"default")
	sprite_frames = mine

# Zmiana narzędzia zakłada jego skórkę: barwę na wierzchu i pasek, z którego wycinane są
# klatki. Kupione leżą w Run, same skórki w ToolSkins — kursor tylko je nosi.
func _show_tool(tool: ToolType.Type) -> void:
	var skin := Run.skin_for(tool)
	modulate = ToolSkins.tint(skin)
	_reskin(tool, ToolSkins.sheet_of(skin))

# Klatki narzędzia bierzemy zawsze od nowa z pliku i dopiero wtedy przemalowujemy, więc
# zwykła skórka wraca do tego, co narysowano w edytorze, a przemalowana nie nakłada się
# na poprzednią. Ruszamy tylko animacje tego jednego narzędzia — reszta zostaje.
func _reskin(tool: ToolType.Type, sheet: Texture2D) -> void:
	var base := ToolSkins.BASE_FRAMES
	for anim in [ToolType.animations[tool], ToolType.dig_animation(tool)]:
		if not base.has_animation(anim):
			continue
		for i in base.get_frame_count(anim):
			var tex := ToolSkins.reskinned(base.get_frame_texture(anim, i), sheet)
			sprite_frames.set_frame(anim, i, tex, base.get_frame_duration(anim, i))
