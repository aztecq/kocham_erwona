extends Node2D

var coins: int = 100
var tool1: bool = false
var tool2: bool = false
var tool3: bool = false

# TODO: tu bedzie sie wczytywalo ilosc kasy z poprzedniego lvla
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
		tool1 = true
	else:
		pass

func _on_button_2_pressed() -> void:
	if coins >= 20:
		coins -= 20
		$Monety.text = "Monety: %s" %coins
		$Button2.visible = false
		tool2 = true
	else:
		pass

func _on_button_3_pressed() -> void:
	if coins >= 20:
		coins -= 20
		$Monety.text = "Monety: %s" %coins
		$Button3.visible = false
		tool3 = true
	else:
		pass
