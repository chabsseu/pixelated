extends Node2D

@export var image_path := ""
@export var grid_size := 3
@onready var bg_music: AudioStreamPlayer2D = $Bg_music
@onready var puzzle_board: PuzzleBoard = $PuzzleBoard
@onready var game_over_ui: Control = $CanvasLayer/Control   # adjust path to match your actual tree

func _ready():
	game_over_ui.visible = false

	var transition = preload("res://Scenes/transition.tscn").instantiate()
	add_child(transition)

	await transition.fade_in()
	bg_music.finished.connect(_on_music_finished)
	bg_music.play()

	puzzle_board.grid_columns = grid_size
	puzzle_board.puzzle_solved.connect(_on_puzzle_solved)
	puzzle_board.time_up.connect(_on_time_up)

	puzzle_board.start_puzzle(image_path)

	transition.queue_free()

func _on_music_finished():
	bg_music.play()

func _on_puzzle_solved():
	game_over_ui.set_result(true)
	game_over_ui.visible = true

func _on_time_up():
	game_over_ui.set_result(false)
	game_over_ui.visible = true
