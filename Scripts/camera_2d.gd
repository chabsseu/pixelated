extends Camera2D
class_name ZoomCamera

@export var zoom_step: float = 0.1        # how much each scroll notch changes zoom
@export var min_zoom: float = 0.5         # smaller = allows zooming in further
@export var max_zoom: float = 2.0         # larger = allows zooming out further
@export var zoom_speed: float = 8.0       # higher = snappier zoom transition
@export var pan_button: MouseButton = MOUSE_BUTTON_RIGHT

var target_zoom: Vector2
var _panning: bool = false
var _pan_start_mouse: Vector2
var _pan_start_camera_pos: Vector2

func _ready() -> void:
	target_zoom = zoom

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_adjust_zoom(+zoom_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_adjust_zoom(-zoom_step)
		elif event.button_index == pan_button:
			if event.pressed:
				_panning = true
				_pan_start_mouse = get_viewport().get_mouse_position()
				_pan_start_camera_pos = position
			else:
				_panning = false

	elif event is InputEventMouseMotion and _panning:
		var mouse_delta: Vector2 = get_viewport().get_mouse_position() - _pan_start_mouse
		# Divide by zoom so panning feels consistent regardless of current zoom level
		# (dragging a fixed screen distance should move the same world-distance visually).
		position = _pan_start_camera_pos - mouse_delta / zoom.x

func _adjust_zoom(amount: float) -> void:
	var new_zoom_value: float = clamp(target_zoom.x + amount, min_zoom, max_zoom)
	target_zoom = Vector2(new_zoom_value, new_zoom_value)

func _process(delta: float) -> void:
	# Smoothly ease current zoom toward target_zoom instead of snapping instantly.
	zoom = zoom.lerp(target_zoom, zoom_speed * delta)