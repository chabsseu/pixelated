extends Control

@onready var win_lose_label: Label = $Win_Lose_label

func set_result(did_win: bool) -> void:
	if did_win:
		win_lose_label.text = "YOU WIN!"
	else:
		win_lose_label.text = "YOU LOSE!"

func _on_new_game_button_pressed() -> void:
	var transition = preload("res://Scenes/transition.tscn").instantiate()
	add_child(transition)
	await transition.fade_out()

	get_tree().change_scene_to_file("res://Scenes/Main_menu.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()