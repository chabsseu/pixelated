extends Control
class_name PuzzleBoard

@export var piece_scene: PackedScene       # assign PuzzlePiece.tscn in the editor
@export var grid_columns: int = 2
@export var board_size: Vector2 = Vector2(600, 600)
@export var pixelate_grid_size := 6   # lower = chunkier/harder pixelation
@export var color_levels := 64     # lower = flatter "cartoon" palette, 255 = off
@export var snap_threshold_ratio: float = 0.6   # % of piece size counted as "close enough" to snap

var pieces: Array = []
var slot_positions: Array = []
var pieces_correct: int = 0
var total_pieces: int = 0
var _ghost_nodes: Array = []

signal puzzle_solved

func _ready() -> void:
	puzzle_solved.connect(_on_puzzle_solved)
	start_puzzle("res://test.jpg")
func _on_puzzle_solved() -> void:
	var win_label := Label.new()

	win_label.text = "PUZZLE COMPLETE!"
	win_label.add_theme_font_size_override("font_size", 64)

	win_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	win_label.set_anchors_preset(Control.PRESET_FULL_RECT)

	win_label.modulate.a = 0.0
	win_label.scale = Vector2(0.5, 0.5)
	win_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(win_label)

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		win_label,
		"modulate:a",
		1.0,
		0.4
	)

	tween.tween_property(
		win_label,
		"scale",
		Vector2.ONE,
		0.4
	)

	print("Puzzle solved!")

func start_puzzle(image_path: String) -> void:
	var raw_img := PixelateUtil.load_image_from_path(image_path)
	if raw_img == null:
		return

	# Crop to square first
	raw_img = PixelateUtil.crop_to_square(raw_img)

	# Resize to the puzzle size
	raw_img.resize(
		int(board_size.x),
		int(board_size.y),
		Image.INTERPOLATE_LANCZOS
	)

	var processed := PixelateUtil.pixelate(
		raw_img,
		pixelate_grid_size,
		color_levels
	)

	_build_pieces(processed)
func _build_pieces(processed_image: Image) -> void:
	_clear_board()

	var full_tex := PixelateUtil.to_texture(processed_image)
	var piece_px := board_size.x / float(grid_columns)
	total_pieces = grid_columns * grid_columns
	pieces_correct = 0

	var img_w := processed_image.get_width()
	var region_size := img_w / float(grid_columns)

	# Center the puzzle board inside this Control
	var board_offset := (size - board_size) / 2

	# Create the correct slot positions
	slot_positions.clear()
	for row in range(grid_columns):
		for col in range(grid_columns):
			slot_positions.append(
				board_offset + Vector2(col * piece_px, row * piece_px)
			)

	# Create ghost pieces
	for i in range(slot_positions.size()):
		var row: int = i / grid_columns
		var col: int = i % grid_columns
		var region := Rect2(
			col * region_size,
			row * region_size,
			region_size,
			region_size
		)

		var ghost := TextureRect.new()
		var atlas := AtlasTexture.new()
		atlas.atlas = full_tex
		atlas.region = region

		ghost.texture = atlas
		ghost.custom_minimum_size = Vector2(piece_px, piece_px)
		ghost.size = Vector2(piece_px, piece_px)
		ghost.position = slot_positions[i]
		ghost.modulate = Color(1, 1, 1, 0.08)
		ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE

		add_child(ghost)
		_ghost_nodes.append(ghost)

	# Create puzzle pieces
	var index := 0
	for row in range(grid_columns):
		for col in range(grid_columns):
			var piece: PuzzlePiece = piece_scene.instantiate()
			add_child(piece)

			var region := Rect2(
				col * region_size,
				row * region_size,
				region_size,
				region_size
			)

			piece.setup(
				full_tex,
				region,
				piece_px,
				index,
				slot_positions[index]
			)

			piece.piece_dropped.connect(_on_piece_dropped)

			pieces.append(piece)
			index += 1

	_shuffle_pieces()
	queue_redraw()

func _shuffle_pieces() -> void:
	# Scatter pieces randomly within the board bounds, avoiding their own correct slot.
	var scatter_area := Vector2(board_size.x * 1.6, board_size.y * 1.1)
	for piece in pieces:
		var random_pos := Vector2(
			randf_range(0, scatter_area.x - piece.piece_size),
			randf_range(0, scatter_area.y - piece.piece_size)
		)
		piece.position = random_pos

func _on_piece_dropped(piece: PuzzlePiece) -> void:
	var target: Vector2 = slot_positions[piece.correct_index]
	var snap_threshold := piece.piece_size * snap_threshold_ratio
	var dist := piece.position.distance_to(target)

	print("Piece %d dropped at %s | target %s | distance %s | threshold %s" % [
		piece.correct_index,
		piece.position,
		target,
		dist,
		snap_threshold
	])

	if dist <= snap_threshold:
		piece.snap_to(target)

		if not piece.is_locked:

			piece.is_locked = true

			# Fade out the ghost under this piece
			if piece.correct_index < _ghost_nodes.size():
				var ghost: TextureRect = _ghost_nodes[piece.correct_index]

				var ghost_tween := create_tween()
				ghost_tween.tween_property(
					ghost,
					"modulate:a",
					0.0,
					0.2
				)

			# Small pop animation
			piece.scale = Vector2(1.1, 1.1)

			var piece_tween := create_tween()
			piece_tween.tween_property(
				piece,
				"scale",
				Vector2.ONE,
				0.12
			)

			pieces_correct += 1

			if pieces_correct >= total_pieces:
				puzzle_solved.emit()

func _clear_board() -> void:
	for piece in pieces:
		piece.queue_free()
	pieces.clear()
	for ghost in _ghost_nodes:
		ghost.queue_free()
	_ghost_nodes.clear()
	slot_positions.clear()
	pieces_correct = 0

func _draw() -> void:
	if grid_columns <= 0:
		return

	var cell := board_size.x / float(grid_columns)
	var offset := (size - board_size) / 2
	var grid_color := Color(1, 1, 1, 0.25)

	for i in range(grid_columns + 1):
		draw_line(
			offset + Vector2(i * cell, 0),
			offset + Vector2(i * cell, board_size.y),
			grid_color,
			2.0
		)

		draw_line(
			offset + Vector2(0, i * cell),
			offset + Vector2(board_size.x, i * cell),
			grid_color,
			2.0
		)