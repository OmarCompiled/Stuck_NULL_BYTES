extends Node

var enemies_killed: int = 0
var total_enemies: int = 0

func reset():
	enemies_killed = 0
	total_enemies = 0

func end_game():
	await get_tree().physics_frame
	reset()
	get_tree().change_scene_to_file("res://world.tscn")
	
