extends Node

var enemies_killed: int = 0
var total_enemies: int = 0
var currency: int = 0
var current_run_currency: int = 0
var player: Player

func reset():
	enemies_killed = 0
	total_enemies = 0
	current_run_currency = 0
	HitEffectsManager.cleanup()


func end_game():
	# Show cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	currency += current_run_currency
	# Manually reset singleton data since it doesn't reload on changing scenes
	reset()
	
	if player: # just for safety
		player.queue_free()
	
	
	# NOTE: get_tree().reload_current_scene() threw an error that would take
	# some refactoring to fix. change_scene_to_file is way easier to handle

	# Waiting for the physics frame to end prevents an error thrown on dying
	# when freeing the scene before physics calculations are complete
	get_tree().change_scene_to_file.bind("res://scenes/menu/main_menu.tscn").call_deferred()
	
	
