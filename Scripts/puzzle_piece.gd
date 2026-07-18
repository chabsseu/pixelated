extends TextureRect
class_name PuzzlePiece

signal piece_dropped(piece)

var correct_index: int
var correct_slot: Vector2
var piece_size: float
var is_locked: bool = false
var input_locked: bool = false

var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO

const PIXEL_SHADER: Shader = preload("res://Scripts/Pixelate.gdshader")

func setup(
	full_tex: Texture2D,
	region: Rect2,
	size_px: float,
	index: int,
	slot: Vector2
) -> void:

	# Create atlas texture
	var atlas := AtlasTexture.new()
	atlas.atlas = full_tex
	atlas.region = region

	texture = atlas

	# Apply shader
	var shader_material := ShaderMaterial.new()
	shader_material.shader = PIXEL_SHADER

	shader_material.set_shader_parameter("pixel_size", 6)
	shader_material.set_shader_parameter("color_levels", 16)

	material = shader_material

	# Size
	custom_minimum_size = Vector2(size_px, size_px)
	size = Vector2(size_px, size_px)

	# Store info
	correct_index = index
	correct_slot = slot
	piece_size = size_px

	mouse_filter = Control.MOUSE_FILTER_PASS
	gui_input.connect(_on_gui_input)


func _on_gui_input(event: InputEvent) -> void:

	if is_locked or input_locked:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:

			if event.pressed:
				_dragging = true
				_drag_offset = get_global_mouse_position() - global_position
				move_to_front()

			else:
				_dragging = false
				piece_dropped.emit(self)

	elif event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position() - _drag_offset


func snap_to(target_pos: Vector2) -> void:
	position = target_pos
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func lock_input():
	input_locked = true
	_dragging = false