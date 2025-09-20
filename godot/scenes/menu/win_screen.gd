extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ColorRect/MarginContainer/VBoxContainer/Shadows.text = "Shadows Killed: " + \
	var_to_str(GameManager.enemies_killed)
	
	$ColorRect/MarginContainer/VBoxContainer/MemoryFragments.text = "Memory Shards Collected: " + \
	var_to_str(GameManager.current_run_currency)


func _on_menu_button_pressed() -> void:
	GameManager.consecutive_wins += 1
	GameManager.end_game()

func _on_continue_button_pressed() -> void:
	GameManager.consecutive_wins += 1
	$FadeTransition.show()
	$FadeTransition/AnimationPlayer.play("fade_in")
	$FadeTransition/fade_timer.start()

func _on_fade_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/other/world.tscn")
