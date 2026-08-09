class_name InteractablePanelContainer extends PanelContainer

# A panel that behaves as one button: the whole of it takes the click, not just the gaps
# between what's laid out inside it.
#
# It has to be said out loud, because Control defaults disagree with each other — a
# PanelContainer or a TextureRect swallows the mouse where a VBoxContainer passes it on,
# so a frame or an image nested in the panel would eat both the click and the hand cursor
# over exactly the part the player aims at.

signal pressed()

func _ready() -> void:
	claim_mouse(self)

# Nothing inside is clickable on its own, so the mouse always lands on `control` itself.
# Done in code rather than node by node in the editor: it holds for whatever gets added
# to one of these later, and there's no per-node flag to forget. Static, because a panel
# put together in another scene — a toolbar slot, say — needs the same thing said about
# it without being one of these.
static func claim_mouse(control: Control) -> void:
	control.mouse_filter = Control.MOUSE_FILTER_STOP
	_ignore_below(control)

static func _ignore_below(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_ignore_below(child)

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed.emit()
