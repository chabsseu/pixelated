extends Control

const GAME_SCENE: PackedScene = preload("res://Scenes/game.tscn")

@export var click_particle_scene: PackedScene
@onready var bg_music: AudioStreamPlayer2D = $bg_music
@onready var mouse_click: AudioStreamPlayer2D = $mouse_click
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

	bg_music.finished.connect(_on_music_finished)
	_fade_music_in()

func _on_upload_pressed():
	_spawn_click_particle()
	mouse_click.play()
	await get_tree().create_timer(0.15).timeout
	file_dialog.popup_centered_ratio()
	

func _on_file_selected(path: String):
	image_path = path

	selected_image.text = path.get_file()

	start_button.disabled = false

func _on_start_pressed():
	_spawn_click_particle()
	mouse_click.play()
	if image_path.is_empty():
		return
	
	await _fade_music_out()

	var transition = preload("res://Scenes/Transition.tscn").instantiate()
	add_child(transition)
	await transition.fade_out()
	
	var game = GAME_SCENE.instantiate()

	game.image_path = image_path
	game.grid_size = option_button.get_selected_id()

	get_tree().root.add_child(game)
	get_tree().current_scene = game

	queue_free()


func _spawn_click_particle() -> void:
	if click_particle_scene == null:
		push_warning("click_particle_scene not assigned — skipping particle spawn")
		return

	var particles := click_particle_scene.instantiate() as CPUParticles2D
	if particles == null:
		push_warning("click_particle_scene is not a CPUParticles2D!")
		return

	get_tree().current_scene.add_child(particles)
	particles.global_position = get_viewport().get_mouse_position()

	particles.restart()
	particles.emitting = true

	get_tree().create_timer(particles.lifetime + 0.2).timeout.connect(
		particles.queue_free
	)

func _on_music_finished():
	bg_music.play()

func _fade_music_out(duration: float = 0.6) -> void:
	var tween := create_tween()
	tween.tween_property(bg_music, "volume_db", -40.0, duration)
	await tween.finished
	bg_music.stop()

func _fade_music_in(duration: float = 0.6) -> void:
	bg_music.volume_db = -40.0
	bg_music.play()
	var tween := create_tween()
	tween.tween_property(bg_music, "volume_db", 0.0, duration)