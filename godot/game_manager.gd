extends Node

var enemies_killed: int = 0
var total_enemies: int = 0

func end_game():
	get_tree().paused = true
	get_tree().quit()
