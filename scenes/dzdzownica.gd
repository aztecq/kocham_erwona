class_name Dzdzownica extends Area2D

var speed := 5.0
@export var grave: PackedScene

func _ready():
	var flip = true if randi_range(0, 1) else false
	if flip:
		speed *= -1.0
		$AnimatedSprite2D.flip_h = true

func _process(_delta):
	# `speed * delta` — pixels per second. Added, this was 100 pixels *per frame*, which
	# put the worm off the map in the frame after it appeared.
	position.x += speed * _delta

# Caught under a tool. Stops moving first, so nothing carries it another frame while it's
# on its way out — and that's the seam to hang a death animation on later: play it here
# and free the worm when it finishes instead of straight away.
func die() -> void:
	var object = grave.instantiate()
	get_parent().get_parent().add_child(object)
	object.global_position = global_position
	speed = 0.0
	queue_free()
	
	
