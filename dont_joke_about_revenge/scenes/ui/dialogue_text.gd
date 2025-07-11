class_name DialogueText
extends Label

@export var dialogue_duration : int

func set_dialogue(dialogue : String) -> void:
	text = dialogue

func get_current_dialog() -> String:
	return text

func refresh() -> void:
		get_tree().paused = true
		set_process_input(true)
		#print(can_process())
		if Input.is_action_just_pressed("jump"):
			get_tree().paused = false
