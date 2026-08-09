extends Node2D

var timer = 4
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer -= delta
	if(timer <= 0):
		queue_free()
