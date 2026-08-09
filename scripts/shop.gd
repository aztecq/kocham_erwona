class_name Shop extends PanelContainer

# The between-levels shop, where a dig's pay turns into looks for the tools. Money is
# Wallet's, what's been bought is Run's, and what there is to buy is ToolSkins' — this
# scene only lays the shelf out, reads the clicks, and sends the player on to the next
# dig.
#
# Nothing sold here changes how a tool digs: a skin is art and a tint, so a run can be
# finished having bought nothing at all.

const OPTION_SCENE := preload("res://scenes/purchase_option_panel.tscn")

@onready var _grid: GridContainer = %GridContainer
@onready var _coins: Label = %HBoxWallet/Label
@onready var _wallet: Control = %HBoxWallet

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Wallet.coins_changed.connect(_show_coins)
	_show_coins(Wallet.coins)
	%NextLevelButton.pressed.connect(_next_level)
	_build_shelf()

# One panel per skin, in catalog order — the grid's four columns make that a column per
# tool, its free skin over what the tool can be traded up to. The panels sitting in the
# scene are the editor's preview of exactly this and are dropped on the way in, so adding
# a skin to the catalog is enough to put it on the shelf.
func _build_shelf() -> void:
	for placeholder in _grid.get_children():
		_grid.remove_child(placeholder)
		placeholder.queue_free()
	for id: StringName in ToolSkins.ids():
		var option: PurchaseOptionPanel = OPTION_SCENE.instantiate()
		_grid.add_child(option)
		option.setup(id)
		option.pressed.connect(_on_option_pressed.bind(option))

# A click buys the skin if it isn't owned and puts it on either way. Wearing what's
# already worn is the one click that does nothing — there's no selling back, so the free
# skin above it is how a look is taken off.
func _on_option_pressed(option: PurchaseOptionPanel) -> void:
	var id := option.skin_id
	if Run.skin_for(ToolSkins.tool_of(id)) == id:
		return
	if not Run.owns_skin(id):
		# Wallet.spend refuses rather than going into debt, so this is the price check too.
		if not Wallet.spend(ToolSkins.price(id)):
			_refuse()
			return
		Run.unlock_skin(id)
	Run.equip_skin(id)
	$SFX.play()
	_refresh_shelf()

# Every panel, not just the one clicked: a purchase moves the tool's other skins off
# "worn" and can put the rest of the shelf out of reach.
func _refresh_shelf() -> void:
	for option: PurchaseOptionPanel in _grid.get_children():
		option.refresh()

# Nothing was taken from a purse that couldn't cover it — the coins flinch so the click
# doesn't read as broken.
func _refuse() -> void:
	var tween := create_tween()
	tween.tween_property(_wallet, "modulate", Color(1, 0.35, 0.3), 0.08)
	tween.tween_property(_wallet, "modulate", Color.WHITE, 0.25)

func _show_coins(coins: int) -> void:
	_coins.text = str(coins)

func _next_level() -> void:
	$SFX.play()
	get_tree().change_scene_to_file("res://scenes/world.tscn")
