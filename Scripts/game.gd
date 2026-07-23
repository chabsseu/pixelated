extends Node2D

@export var image_path := ""
@export var grid_size := 3

@onready var puzzle_board: PuzzleBoard = $PuzzleBoard

func _ready():
	var transition = preload("res://Scenes/transition.tscn").instantiate()
	add_child(transition)

	await transition.fade_in()
	
	puzzle_board.grid_columns = grid_size
	puzzle_board.start_puzzle(image_path)