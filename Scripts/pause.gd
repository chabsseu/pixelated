extends Control

const MAIN_MENU: PackedScene = preload("res://Scenes/Main_menu.tscn")

@onready var continue_button: TextureButton = $Panel/ContinueButton
@onready var back_button: TextureButton = $Panel/BackButton
@onready var quit_button: TextureButton = $Panel/QuitButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	visible = false

	continue_button.pressed.connect(_on_continue_pressed)
	back_button.pressed.connect(_on_back_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func open() -> void:
	visible = true
	get_tree().paused = true

func close() -> void:
	visible = false
	get_tree().paused = false

func _on_continue_pressed() -> void:
	close()

func _on_back_pressed() -> void:
	close()   # unpause BEFORE switching scenes, or the new scene loads paused
	get_tree().change_scene_to_file("res://Scenes/Main_menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()