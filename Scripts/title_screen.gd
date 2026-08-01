extends Node2D

const game_screen: PackedScene = preload("res://Scenes/Main_menu.tscn")
const YOUTUBE_URL := "https://www.youtube.com/@StrawberrySoftoware"
const FB_URL := "https://www.facebook.com/profile.php?id=61584113526649"
const ITCH_URL := "https://liufyx.itch.io/"

@export var click_particle_scene: PackedScene   # assign a CPUParticles2D scene here
@onready var bg_music: AudioStreamPlayer2D = $bg_music
@onready var mouse_click: AudioStreamPlayer2D = $mouse_click

func _ready() -> void:
	
	bg_music.finished.connect(_on_music_finished)
	_fade_music_in()

func _on_texture_button_pressed() -> void:
	_spawn_click_particle()
	mouse_click.play()
	await _fade_music_out()

	var transition = preload("res://Scenes/Transition.tscn").instantiate()
	add_child(transition)
	await transition.fade_out()

	var game_screen = game_screen.instantiate()

	get_tree().root.add_child(game_screen)
	get_tree().current_scene = game_screen

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

func _on_plug_pressed() -> void:
	mouse_click.play()
	_spawn_click_particle()
	OS.shell_open(YOUTUBE_URL)


func _on_plug_2_pressed() -> void:
	mouse_click.play()
	_spawn_click_particle()
	OS.shell_open(FB_URL)


func _on_plug_3_pressed() -> void:
	mouse_click.play()
	_spawn_click_particle()
	OS.shell_open(ITCH_URL)