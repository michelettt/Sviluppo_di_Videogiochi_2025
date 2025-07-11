extends Node2D

const PLAYER_PREFAB := preload("res://scenes/characters/player.tscn")
const STAGE_PREFABS := [
	preload("res://scenes/stage/stage_01_streets.tscn"),
	preload("res://scenes/stage/stage_02_bar.tscn"),
]

@onready var actors_container : Node2D = $ActorsContainer
@onready var camera : Camera = $Camera
@onready var stage_container : Node2D = $StageContainer
@onready var stage_transition: StageTransition = $UI/UIContainer/StageTransition

var camera_initial_position := Vector2.ZERO
var current_stage_index := -1
var is_camera_locked := false
var is_start_menu_active := true
var is_stage_ready_for_loading := false
var player : Player = null
var start_menu : StartMenu = null

func _ready() -> void:
	camera_initial_position = camera.position
	StageManager.checkpoint_start.connect(on_checkpoint_start.bind())
	StageManager.checkpoint_complete.connect(on_checkpoint_complete.bind())
	StageManager.stage_interim.connect(load_next_stage.bind())
	MenuManager.new_game.connect(on_new_game.bind())
	MenuManager.end_game.connect(on_end_game.bind())

func _process(_delta: float) -> void:
	if is_stage_ready_for_loading:
		is_stage_ready_for_loading = false
		var stage : Stage = STAGE_PREFABS[current_stage_index].instantiate()
		stage_container.add_child(stage)
		player = PLAYER_PREFAB.instantiate()
		actors_container.add_child(player)
		player.position = stage.get_player_spawn_location()
		actors_container.player = player
		camera.position = camera_initial_position
		camera.reset_smoothing()
		stage_transition.end_transition()
		
	if player != null and not is_camera_locked and player.position.x > camera.position.x:
		camera.position.x = player.position.x

func load_next_stage() -> void:
	current_stage_index += 1
	if current_stage_index < STAGE_PREFABS.size():
		for actor : Node2D in actors_container.get_children():
			actor.queue_free()
		delete_stage()
		is_stage_ready_for_loading = true
	if current_stage_index == 1:
		StageManager.second_stage.emit()

func delete_stage() -> void:
	for existing_stage in stage_container.get_children():
		existing_stage.queue_free()

func on_new_game() -> void:
	MenuManager.delete_start_menu.emit()
	load_next_stage()

func on_checkpoint_start() -> void:
	is_camera_locked = true

func on_checkpoint_complete(_checkpoint: Checkpoint) -> void:
	is_camera_locked = false

func on_end_game() -> void:
	delete_stage()
