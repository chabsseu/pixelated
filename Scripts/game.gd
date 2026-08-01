extends Node2D

@export var image_path := ""
@export var image_bytes: PackedByteArray = PackedByteArray()   # used on web builds instead of image_path
@export var grid_size := 3
@onready var bg_music: AudioStreamPlayer2D = $Bg_music
@onready var puzzle_board: PuzzleBoard = $PuzzleBoard
@onready var game_over_ui: Control = $CanvasLayer/Control   # adjust path to match your actual tree
@onready var pause_menu: Control = $CanvasLayer/Pause         # adjust path to match your actual tree
@onready var ui: PuzzleUI = $CanvasLayer/UI

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):   # Esc by default
		if pause_menu.visible:
			pause_menu.close()
		else:
			pause_menu.open()

func _ready():
	game_over_ui.visible = false

	var transition = preload("res://Scenes/Transition.tscn").instantiate()
	add_child(transition)

	await transition.fade_in()
	bg_music.finished.connect(_on_music_finished)
	bg_music.play()

	puzzle_board.grid_columns = grid_size
	puzzle_board.puzzle_solved.connect(_on_puzzle_solved)
	puzzle_board.time_up.connect(_on_time_up)

	if OS.has_feature("web"):
		puzzle_board.start_puzzle_from_bytes(image_bytes)
	else:
		puzzle_board.start_puzzle(image_path)

	transition.queue_free()

	if ui:
		ui.pause_requested.connect(_on_pause_requested)

func _on_music_finished():
	bg_music.play()

func _on_puzzle_solved():
	game_over_ui.set_result(true)
	game_over_ui.visible = true

func _on_time_up():
	game_over_ui.set_result(false)
	game_over_ui.visible = true

func _on_pause_requested() -> void:
	pause_menu.open()
