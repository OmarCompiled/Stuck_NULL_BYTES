extends Node

var enemies_killed: int = 0
var total_enemies: int = 0
var currency: int = 0
var player: Player

func _process(_delta: float) -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if Input.is_action_pressed("Quit"): # Esc 
		get_tree().quit()
		
	# NOTE: Will remove later
	# NOTE: no need to remove now,
	# will be useful for the pause menu
	# Although we need to change it to something other than 'Q' 
	if Input.is_action_just_pressed("Pause") and get_tree().current_scene.scene_file_path == "res://world.tscn":
		get_tree().paused = true if !get_tree().paused else false

func reset():
	enemies_killed = 0
	total_enemies = 0
	player = null

func end_game():
	# Manually reset singleton data since it doesn't reload on changing scenes
	reset()
	
	# NOTE: get_tree().reload_current_scene() threw an error that would take
	# some refactoring to fix. change_scene_to_file is way easier to handle
	
	# Waiting for the physics frame to end prevents an error thrown on dying
	# when freeing the scene before physics calculations are complete
	await get_tree().physics_frame
	get_tree().change_scene_to_file("res://main_menu.tscn")
	
