extends Node2D

# The between-levels shop. Money is Wallet's, what's been bought is Run's — this scene
# only draws buttons for whatever's still for sale and sends the player on to the next
# dig. What the tools actually do is the team's to decide; the flags wait in
# Run.owned_tools under the button's name.

const PRICES := {
	"Button1": 10,
	"Button2": 20,
	"Button3": 20,
}

func _ready() -> void:
	_show_coins()
	for button_name in PRICES:
		get_node(button_name).visible = not Run.owned_tools.get(button_name, false)

	var next := Button.new()
	next.text = "Następny poziom (%d)" % Run.level
	next.add_theme_font_size_override("font_size", 24)
	next.position = Vector2(300, 500)
	next.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/world.tscn"))
	add_child(next)

func _buy(button_name: String) -> void:
	if not Wallet.spend(PRICES[button_name]):
		return
	Run.owned_tools[button_name] = true
	get_node(button_name).visible = false
	_show_coins()

func _show_coins() -> void:
	$Monety.text = "Monety: %s" % Wallet.coins

func _on_button_1_pressed() -> void:
	_buy("Button1")

func _on_button_2_pressed() -> void:
	_buy("Button2")

func _on_button_3_pressed() -> void:
	_buy("Button3")
