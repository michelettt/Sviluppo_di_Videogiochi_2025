class_name StartMenu
extends Control

signal new_game

@onready var new_game_control : LabelPicker = $ColorRect/MarginContainer/VBoxContainer/NewGame
@onready var options_control : LabelPicker = $ColorRect/MarginContainer/VBoxContainer/Options
@onready var scoreboard_control : LabelPicker = $ColorRect/MarginContainer/VBoxContainer/Scoreboard
@onready var credits_control : LabelPicker = $ColorRect/MarginContainer/VBoxContainer/Credits
@onready var activables: Array[ActivableControl] = [new_game_control, options_control, scoreboard_control, credits_control]

@export var music : MusicManager.Music

var current_selection_index := 0

func _ready() -> void:
	MenuManager.start_menu_music.connect(on_start_menu_music.bind())
	new_game_control.press.connect(on_new_game_press.bind())
	options_control.press.connect(on_options_press.bind())
	scoreboard_control.press.connect(on_scoreboard_press.bind())
	credits_control.press.connect(on_credits_press.bind())
	refresh()

func refresh() -> void:
	for i in range(0, activables.size()):
		activables[i].set_active(current_selection_index == i)

func _process(_delta: float) -> void:
	handle_input()

func handle_input() -> void:
	if Input.is_action_just_pressed("ui_down"):
		current_selection_index = clampi(current_selection_index + 1, 0, activables.size() - 1)
		refresh()
		SoundPlayer.play(SoundManager.Sound.CLICK)
	if Input.is_action_just_pressed("ui_up"):
		current_selection_index = clampi(current_selection_index - 1, 0, activables.size() - 1)
		refresh()
		SoundPlayer.play(SoundManager.Sound.CLICK)

func on_new_game_press() -> void:
	MenuManager.control_map.emit()

func on_options_press() -> void:
	MenuManager.options_screen.emit()

func on_scoreboard_press() -> void:
	MenuManager.scoreboard_screen.emit()

func on_credits_press() -> void:
	MenuManager.credits_screen.emit()

func on_start_menu_music() -> void:
	MusicPlayer.play(music)
