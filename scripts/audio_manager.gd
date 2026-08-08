extends AudioStreamPlayer

@export var songs: Array[AudioStream] = []

var current_song := 0

func _ready():
	play_next_song()

func play_next_song():
	if songs.is_empty():
		return

	stream = songs[current_song]
	play()

	current_song = (current_song + 1) % songs.size()


func _on_finished() -> void:
	await get_tree().create_timer(1.0).timeout
	play_next_song()
