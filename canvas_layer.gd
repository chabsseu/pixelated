extends CanvasLayer

@onready var rect: ColorRect = $ColorRect

func fade_in():
	rect.modulate.a = 1.0

	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 0.0, 0.4)

	await tween.finished


func fade_out():
	rect.modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 1.0, 0.4)

	await tween.finished