extends TextureRect
class_name PuzzlePiece

## Attach this to a TextureRect node saved as PuzzlePiece.tscn, and assign
## that scene to PuzzleBoard's `piece_scene` export in the editor.

signal piece_dropped(piece)

var correct_index: int
var correct_slot: Vector2
var piece_size: float
var is_locked: bool = false

var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO

func setup(full_tex: Texture2D, region: Rect2, size_px: float, index: int, slot: Vector2) -> void:
	# AtlasTexture lets each piece show just one rectangular slice of the shared full texture.
	var atlas := AtlasTexture.new()
	atlas.atlas = full_tex
	atlas.region = region
	texture = atlas

	custom_minimum_size = Vector2(size_px, size_px)
	size = Vector2(size_px, size_px)

	correct_index = index
	correct_slot = slot
	piece_size = size_px

	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)

func _on_gui_input(event: InputEvent) -> void:
	if is_locked:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_dragging = true
				_drag_offset = get_global_mouse_position() - global_position
				move_to_front()
			else:
				_dragging = false
				emit_signal("piece_dropped", self)

	elif event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position() - _drag_offset

func snap_to(target_pos: Vector2) -> void:
	position = target_pos
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # locked pieces stop intercepting drags