class_name UI
extends CanvasLayer

const CONTROL_MAP_SCREEN_PREFAB := preload("res://scenes/ui/control_map.tscn")
const CREDITS_SCREEN_PREFAB := preload("res://scenes/ui/credits.tscn")
const DEATH_SCREEN_PREFAB := preload("res://scenes/ui/death_screen.tscn")
const END_GAME := preload("res://scenes/ui/end_game.tscn")
const GAME_OVER_PREFAB := preload("res://scenes/ui/game_over_screen.tscn")
const OPTIONS_SCREEN_PREFAB := preload("res://scenes/ui/options_screen.tscn")
const SCOREBOARD_SCREEN_PREFAB := preload("res://scenes/ui/scoreboard.tscn")
const START_MENU_PREFAB := preload("res://scenes/ui/start_menu.tscn")

@onready var combo_indicator : ComboIndicator = $UIContainer/ComboIndicator
@onready var dialogue_text : DialogueText = $UIContainer/DialogueText
@onready var enemy_avatar : TextureRect = $UIContainer/EnemyAvatar
@onready var enemy_healthbar : Healthbar = $UIContainer/EnemyHealthbar
@onready var go_indicator : FlickeringTextureRect = $UIContainer/GoIndicator
@onready var player_healthbar : Healthbar = $UIContainer/PlayerHealthbar
@onready var press_to_continue : DialogueText = $UIContainer/DialogueText
@onready var score_indicator : ScoreIndicator = $UIContainer/ScoreIndicator
@onready var stage_transition: StageTransition = $UIContainer/StageTransition
@export var duration_healthbar_visible : int

var control_map_screen : ControlMap = null
var credits_screen: Credits = null
var death_screen : DeathScreen = null
var end_game_screen : EndGame = null
var game_over_screen : GameOverScreen = null
var options_screen : OptionsScreen = null
var scoreboard_screen : Scoreboard = null
var start_menu : StartMenu = null
var music := true
var dialogue_active := false
var is_credits_screen_active := false
var is_game_active := false
var is_options_screen_active := false
var is_scoreboard_screen_active := false
var is_start_menu_active := false
var time_start_healthbar_visible := Time.get_ticks_msec()
var time_game_pause := Time.get_ticks_msec()
var checkpoints_count : int = 0

const avatar_map : Dictionary = {
	Character.Type.GOON: preload("res://assets/art/ui/avatars/avatar-goon.png"),
	Character.Type.PUNK: preload("res://assets/art/ui/avatars/avatar-punk.png"),
	Character.Type.THUG: preload("res://assets/art/ui/avatars/avatar-thug.png"),
	Character.Type.BOUNCER: preload("res://assets/art/ui/avatars/avatar-boss.png"),
}

func _init() -> void:
	DamageManager.health_change.connect(on_character_health_change.bind())
	StageManager.checkpoint_complete.connect(on_checkpoint_complete.bind())
	StageManager.player_stage_complete.connect(on_player_stage_complete.bind())

func _ready() -> void:
	enemy_avatar.visible = false
	enemy_healthbar.visible = false
	combo_indicator.combo_reset.connect(on_combo_reset.bind())
	MenuManager.delete_start_menu.connect(on_delete_start_menu.bind())
	MenuManager.options_screen.connect(on_options_screen.bind())
	MenuManager.exit_options.connect(on_exit_options.bind())
	MenuManager.scoreboard_screen.connect(on_scoreboard_screen.bind())
	MenuManager.exit_scoreboard.connect(on_exit_scoreboard.bind())
	MenuManager.credits_screen.connect(on_credits_screen.bind())
	MenuManager.exit_credits.connect(on_exit_credits.bind())
	MenuManager.control_map.connect(on_control_map.bind())
	MenuManager.exit_control_map.connect(on_exit_control_map.bind())
	StageManager.second_stage.connect(on_second_stage.bind())
	load_start_menu()

func _process(_delta: float) -> void:
	if enemy_healthbar.visible and (Time.get_ticks_msec() - time_start_healthbar_visible > duration_healthbar_visible):
		enemy_avatar.visible = false
		enemy_healthbar.visible = false
	handle_input()

func handle_input() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if start_menu != null:
			return
		elif is_game_active == true:
			on_options_screen()

func load_start_menu() -> void:
	is_start_menu_active = true
	if start_menu == null:
		start_menu = START_MENU_PREFAB.instantiate()
		add_child(start_menu)
	if music:
		MenuManager.start_menu_music.emit()
		music = false

func on_delete_start_menu() -> void:
	is_start_menu_active = false
	if start_menu != null:
		unpause(start_menu)
	is_game_active = true

func on_options_screen() -> void:
	if end_game_screen != null:
		return
	if start_menu != null:
		start_menu.queue_free()
	if options_screen == null:
		options_screen = OPTIONS_SCREEN_PREFAB.instantiate()
		add_child(options_screen)
		if is_game_active:
			get_tree().paused = true
	else:
		unpause(options_screen)

func on_exit_options() -> void:
	unpause(options_screen)
	if is_game_active == false:
		load_start_menu()

func on_scoreboard_screen() -> void:
	if start_menu != null:
		start_menu.queue_free()
	if scoreboard_screen == null:
		scoreboard_screen = SCOREBOARD_SCREEN_PREFAB.instantiate()
		add_child(scoreboard_screen)
	else:
		unpause(scoreboard_screen)

func on_exit_scoreboard() -> void:
	unpause(scoreboard_screen)
	load_start_menu()

func on_credits_screen() -> void:
	if start_menu != null:
		start_menu.queue_free()
	if credits_screen == null:
		credits_screen = CREDITS_SCREEN_PREFAB.instantiate()
		add_child(credits_screen)
	else:
		unpause(credits_screen)

func on_exit_credits() -> void:
	unpause(credits_screen)
	load_start_menu()

func on_control_map() -> void:
	if start_menu != null:
		start_menu.queue_free()
	if control_map_screen == null:
		control_map_screen = CONTROL_MAP_SCREEN_PREFAB.instantiate()
		add_child(control_map_screen)
	else:
		unpause(control_map_screen)

func on_exit_control_map() -> void:
	unpause(control_map_screen)
	MenuManager.new_game.emit()

func unpause(screen) -> void:
	screen.queue_free()
	if is_game_active:
		get_tree().paused = false

func on_combo_reset(points: int) -> void:
	score_indicator.add_combo(points)

func on_character_health_change(type: Character.Type, current_health: int, max_health: int) -> void:
	if type == Character.Type.PLAYER:
		player_healthbar.refresh(current_health, max_health)
		if current_health == 0 and death_screen == null:
			death_screen = DEATH_SCREEN_PREFAB.instantiate()
			death_screen.game_over.connect(on_game_over.bind())
			add_child(death_screen)
			
	else:
		time_start_healthbar_visible = Time.get_ticks_msec()
		enemy_avatar.texture = avatar_map[type]
		enemy_healthbar.refresh(current_health, max_health)
		enemy_avatar.visible = true
		enemy_healthbar.visible = true

func on_game_over() -> void:
	if game_over_screen == null:
		game_over_screen = GAME_OVER_PREFAB.instantiate()
		game_over_screen.set_score(score_indicator.real_score)
		add_child(game_over_screen)

func on_checkpoint_complete(_checkpoint: Checkpoint) -> void:
	go_indicator.start_flickering()
	await get_tree().create_timer(1.0).timeout 
	if checkpoints_count == 0:
		dialogue_text.set_dialogue("I forgot: I can do jumpkick! (Press 'x' to continue...)")
	if dialogue_text.get_current_dialog() == "I forgot: I can do jumpkick! (Press 'x' to continue...)":
			get_tree().paused = true
			dialogue_active = true 
	checkpoints_count += 1
	if checkpoints_count == 4:
		MenuManager.end_game.emit()
		if is_game_active:
			get_tree().paused = true
		end_game_screen = END_GAME.instantiate()
		add_child(end_game_screen)

func _input(event: InputEvent) -> void:
	if get_tree().paused and dialogue_active: 
		if event.is_action_pressed("jump"): 
			get_tree().paused = false
			dialogue_active = false 
			dialogue_text.set_dialogue("")
			press_to_continue.set_dialogue("")

func on_player_stage_complete() -> void:
	stage_transition.start_transition()

func on_second_stage() -> void:
	dialogue_text.set_dialogue("Defeat Chun Li-Hao! (Press 'x' to continue...)")
	if dialogue_text.get_current_dialog() == "Defeat Chun Li-Hao! (Press 'x' to continue...)":
			get_tree().paused = true
			dialogue_active = true 
