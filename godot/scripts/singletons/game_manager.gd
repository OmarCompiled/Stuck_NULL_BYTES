extends Node

var enemies_killed: int = 0
var total_enemies: int = 0
var currency: int = 0
var player: Player

func reset():
	enemies_killed = 0
	total_enemies = 0
	player = null
	HitEffectsManager.cleanup()
	HealEffectsManager.cleanup()

func end_game():
	# Show cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Manually reset singleton data since it doesn't reload on changing scenes
	reset()
	
	# NOTE: get_tree().reload_current_scene() threw an error that would take
	# some refactoring to fix. change_scene_to_file is way easier to handle
	
	# Waiting for the physics frame to end prevents an error thrown on dying
	# when freeing the scene before physics calculations are complete
	await get_tree().physics_frame
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
	
	
