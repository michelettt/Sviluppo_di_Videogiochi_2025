class_name Scoreboard
extends Control

@onready var return_control_scoreboard : LabelPicker = $ColorRect/MarginContainer/VBoxContainer/LabelPicker
@onready var activables: Array[ActivableControl] = [return_control_scoreboard]

var current_selection_index := 0

func _ready() -> void:
	return_control_scoreboard.press.connect(on_return_press.bind())
	refresh()

func refresh() -> void:
	for i in range(0, activables.size()):
		activables[i].set_active(current_selection_index == i)

func on_return_press() -> void:
	MenuManager.exit_scoreboard.emit()
