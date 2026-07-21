extends Node2D

@export var image_path := ""
@export var grid_size := 3

@onready var puzzle_board: PuzzleBoard = $PuzzleBoard

func _ready():

	puzzle_board.grid_columns = grid_size
	puzzle_board.start_puzzle(image_path)