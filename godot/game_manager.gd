extends Node

var enemies_killed: int = 0
var total_enemies: int = 0

func _process(_delta: float) -> void:
	if Input.is_action_pressed("Quit"): # Esc 
		get_tree().quit()

func reset():
	enemies_killed = 0
	total_enemies = 0

func end_game():
	# Manually reset singleton data since it doesn't reload on changing scenes
	reset()
	
	# NOTE: get_tree().reload_current_scene() threw an error that would take some refactoring to fix. This is way easier to handle.
	get_tree().change_scene_to_file("res://world.tscn") 
	
