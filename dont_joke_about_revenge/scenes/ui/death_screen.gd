class_name DeathScreen
extends MarginContainer

signal game_over

@onready var countdown_label : Label = $Border/MarginContainer/Content/VBoxContainer/CountdownLabel
@onready var timer : Timer = $Timer

@export var countdown_start : int

var current_count := 0

func _ready() -> void:
	current_count = countdown_start
	timer.timeout.connect(on_timer_timeout.bind())
	DamageManager.player_revive.connect(on_player_revive.bind())
	refresh()

func refresh() -> void:
	countdown_label.text = str(current_count)

func _process(_delta: float) -> void:
	if current_count < countdown_start and Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("jump"):
		DamageManager.press_revive.emit()

func on_player_revive() -> void:
	queue_free()

func on_timer_timeout() -> void:
	if current_count > 0:
		current_count -= 1
		refresh()
	else:
		game_over.emit()
		queue_free()
