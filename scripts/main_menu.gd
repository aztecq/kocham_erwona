extends Node2D


func _on_start_button_pressed() -> void:
	$SFX.play()
	Run.reset()
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_quit_button_pressed() -> void:
	$SFX.play()
	get_tree().quit()
	
	
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_6:
			$CanvasLayer/Mammon3.visible = true
