class_name ControlMap
extends Control

func _process(_delta: float) -> void:
	handle_input()

func handle_input():
	if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
		MenuManager.exit_control_map.emit()
