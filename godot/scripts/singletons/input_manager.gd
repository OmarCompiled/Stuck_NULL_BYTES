extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Quit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")

	if Input.is_action_just_pressed("Pause"):
		var current_scene := get_tree().current_scene
		if current_scene and current_scene.scene_file_path == "res://scenes/other/world.tscn":
			get_tree().paused = not get_tree().paused

	if Input.is_action_just_pressed("Fullscreen"):
		var window := get_window()
		if window:
			if window.mode == Window.MODE_FULLSCREEN:
				window.mode = Window.MODE_WINDOWED
			else:
				window.mode = Window.MODE_FULLSCREEN
