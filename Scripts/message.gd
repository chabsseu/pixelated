extends Control
class_name MessageUI

@onready var center_message: Label = $CenterMessage

# Called when the node enters the scene tree for the first time.
func show_message(text: String):

	# center_message.add_theme_color_override("font_color",color)
	# center_message.add_theme_color_override("font_outline_color",outline_color)
	center_message.visible = true
	center_message.text = text

	center_message.modulate.a = 0
	center_message.scale = Vector2(.5,.5)

	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		center_message,
		"modulate:a",
		1.0,
		0.4
	)

	tween.tween_property(
		center_message,
		"scale",
		Vector2.ONE,
		0.4
	)


func hide_message():
	center_message.visible = false
