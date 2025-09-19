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
	
	
func handle_player_death():
	get_tree().paused = true
	InputManager.can_quit = false
	SanityEffectsManager.death_sequence_finished.connect(_on_death_sequence_finished, CONNECT_ONE_SHOT)
	SanityEffectsManager.play_death_sequence()	
	

func handle_player_win():
	get_tree().paused = true
	InputManager.can_quit = false
	SanityEffectsManager.win_sequence_finished.connect(_on_win_sequence_finished, CONNECT_ONE_SHOT)
	SanityEffectsManager.play_win_sequence()	


func _on_death_sequence_finished():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file.bind("res://scenes/menu/death_screen.tscn").call_deferred()
	get_tree().paused = false
	
	
func _on_win_sequence_finished():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file.bind("res://scenes/menu/win_screen.tscn").call_deferred()
	get_tree().paused = false
