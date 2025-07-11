class_name Credits
extends Control

@onready var return_control_credits : LabelPicker = $ColorRect/MarginContainer/VBoxContainer/LabelPicker
@onready var activables: Array[ActivableControl] = [return_control_credits]

var current_selection_index := 0

func _ready() -> void:
	return_control_credits.press.connect(on_return_press.bind())
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

func on_return_press() -> void:
	MenuManager.exit_credits.emit()
