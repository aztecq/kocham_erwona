extends Node2D

var coins = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func _on_button_1_pressed() -> void:
	if coins >= 10:
		coins -= 10
		$Monety.text = "Monety: %s" %coins
		$Button1.visible = false
	else:
		pass

func _on_button_2_pressed() -> void:
	if coins >= 20:
		coins -= 20
		$Monety.text = "Monety: %s" %coins
		$Button2.visible = false
	else:
		pass

func _on_button_3_pressed() -> void:
	if coins >= 20:
		coins -= 20
		$Monety.text = "Monety: %s" %coins
		$Button3.visible = false
	else:
		pass
