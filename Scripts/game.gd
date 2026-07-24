extends Node2D

@export var image_path := ""
@export var grid_size := 3
@onready var bg_music: AudioStreamPlayer2D = $Bg_music
@onready var puzzle_board: PuzzleBoard = $PuzzleBoard

func _ready():
	var transition = preload("res://Scenes/transition.tscn").instantiate()
	add_child(transition)

	await transition.fade_in()
	bg_music.finished.connect(_on_music_finished)
	bg_music.play()

	puzzle_board.grid_columns = grid_size
	puzzle_board.start_puzzle(image_path)

	transition.queue_free()   # remove the transition overlay, not this whole scene


func _on_music_finished():
	bg_music.play()

