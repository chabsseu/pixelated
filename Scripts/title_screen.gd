extends Node2D
const game_screen: PackedScene = preload("res://Scenes/Main_menu.tscn")


func _on_texture_button_pressed() -> void:
	var transition = preload("res://Scenes/transition.tscn").instantiate()
	add_child(transition)
	await transition.fade_out()
	
	var game_screen = game_screen.instantiate()

	get_tree().root.add_child(game_screen)
	get_tree().current_scene = game_screen

	queue_free()