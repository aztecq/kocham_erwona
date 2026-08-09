class_name PurchaseOptionPanel extends InteractablePanelContainer

# One skin on the shelf: the tool as it will look, what it costs, and where the player
# stands with it. It decides nothing — the shop reads the click and says what happened,
# and this redraws itself from Run and Wallet afterwards.

# What a skin the player can't afford yet is drawn at, so an empty purse reads at a
# glance without greying the shelf out entirely.
const UNAFFORDABLE_DIM := 0.45
# The frame behind a skin that's currently on its tool.
const EQUIPPED_FRAME := Color(1.0, 0.85, 0.35)

@onready var _frame: PanelContainer = %Frame
@onready var _icon: TextureRect = %Icon
@onready var _cost: Label = %LabelCost

var skin_id: StringName

func setup(id: StringName) -> void:
	skin_id = id
	_icon.texture = ToolSkins.icon(id)
	tooltip_text = ToolSkins.skin_name(id)
	refresh()

func refresh() -> void:
	if skin_id.is_empty():
		return
	var equipped := Run.skin_for(ToolSkins.tool_of(skin_id)) == skin_id
	var owned := Run.owns_skin(skin_id)
	var affordable := owned or ToolSkins.price(skin_id) <= Wallet.coins

	if equipped:
		_cost.text = "Worn"
	elif owned:
		_cost.text = "Wear"
	else:
		_cost.text = str(ToolSkins.price(skin_id))

	_frame.self_modulate = EQUIPPED_FRAME if equipped else Color.WHITE
	# The tint is the skin, so it's shown even on one that isn't bought yet — dimmed, not
	# hidden, because what the money buys is exactly this colour.
	_icon.modulate = ToolSkins.tint(skin_id)
	if not affordable:
		_icon.modulate.a = UNAFFORDABLE_DIM
	mouse_default_cursor_shape = CURSOR_ARROW if equipped else CURSOR_POINTING_HAND
