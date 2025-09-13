extends Node

@onready var soundtrack: AudioStreamPlayer = $MainSoundtrack

@export var playlist: Array[AudioStream] = []
var last_song_index: int = -1

func play_random_song() -> void:
	if playlist.size() == 0:
		return
	var song_index = randi() % playlist.size()
	while playlist.size() > 1 and song_index == last_song_index:
		song_index = randi() % playlist.size()
	last_song_index = song_index
	soundtrack.stream = playlist[song_index]
	soundtrack.play()
	if soundtrack.is_connected("finished", Callable(self, "_on_song_finished")):
		soundtrack.disconnect("finished", Callable(self, "_on_song_finished"))
	soundtrack.connect("finished", Callable(self, "_on_song_finished"))

func _on_song_finished() -> void:
	play_random_song()

func set_volume(value: float) -> void:
	soundtrack.volume_db = linear_to_db(value / 100.0)

func set_muted(muted: bool) -> void:
	soundtrack.stream_paused = muted
