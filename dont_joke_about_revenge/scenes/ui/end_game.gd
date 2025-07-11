class_name EndGame
extends Control

@export var music : MusicManager.Music

func _ready() -> void:
	OptionsManager.set_music_volume(1)
	MusicPlayer.play(music)
