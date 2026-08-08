extends Node2D


func _on_start_button_pressed() -> void:
	Run.reset()
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
