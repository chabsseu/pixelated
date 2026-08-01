extends Control
class_name PuzzleUI

signal pause_requested

@onready var timer_label: Label = $TimerLabel
@onready var score_label: Label = $ScoreLabel
@onready var popup_layer: Control = $PopupLayer


func set_time(seconds: float):
	timer_label.text = "Time: %d" % max(0, ceil(seconds))


func set_score(score: int):
	score_label.text = "Score: %d" % score


func spawn_score_popup(pos: Vector2, points: int):

	var popup := Label.new()

	popup.text = "+%d" % points
	popup.position = pos

	popup.add_theme_font_size_override("font_size",24)
	popup.add_theme_color_override("font_color",Color.BLACK)
	popup.add_theme_color_override("font_outline_color",Color.WHITE)
	popup.add_theme_constant_override("outline_size",4)

	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE

	popup_layer.add_child(popup)

	var tween = create_tween()

	tween.set_parallel(true)

	tween.tween_property(
		popup,
		"position:y",
		pos.y-40,
		0.6
	)

	tween.tween_property(
		popup,
		"modulate:a",
		0,
		0.6
	).set_delay(.15)

	tween.chain().tween_callback(
		popup.queue_free
	)

func _on_pause_pressed():
	pause_requested.emit()
