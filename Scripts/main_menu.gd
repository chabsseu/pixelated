extends Control

const GAME_SCENE: PackedScene = preload("res://Scenes/game.tscn")

@onready var upload_button: TextureButton = $Panel/UploadButton
@onready var start_button: TextureButton = $Panel/StartButton
@onready var option_button: OptionButton = $Panel/OptionButton
@onready var file_dialog: FileDialog = $Panel/FileDialog
@onready var selected_image: Label = $Panel/SelectedImageLabel

var image_path := ""

func _ready():

	# Disable Start until an image is chosen
	start_button.disabled = true

	# Puzzle sizes
	option_button.clear()
	option_button.add_item("2 x 2", 2)
	option_button.add_item("3 x 3", 3)
	option_button.add_item("4 x 4", 4)
	option_button.add_item("5 x 5", 5)
	option_button.add_item("6 x 6", 6)

	option_button.select(1)

	# File dialog
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.filters = PackedStringArray([
		"*.png ; PNG Image",
		"*.jpg ; JPG Image",
		"*.jpeg ; JPEG Image"
	])

	upload_button.pressed.connect(_on_upload_pressed)
	file_dialog.file_selected.connect(_on_file_selected)
	start_button.pressed.connect(_on_start_pressed)


func _on_upload_pressed():
	file_dialog.popup_centered_ratio()


func _on_file_selected(path: String):

	image_path = path

	selected_image.text = path.get_file()

	start_button.disabled = false

func _on_start_pressed():

	if image_path.is_empty():
		return

	var transition = preload("res://Scenes/transition.tscn").instantiate()
	add_child(transition)
	await transition.fade_out()
	
	var game = GAME_SCENE.instantiate()

	game.image_path = image_path
	game.grid_size = option_button.get_selected_id()

	get_tree().root.add_child(game)
	get_tree().current_scene = game

	queue_free()
