extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ColorRect/MarginContainer/HBoxContainer/Shadows.text = "Shadows Killed: " + \
	var_to_str(GameManager.enemies_killed)
	
	$ColorRect/MarginContainer/HBoxContainer/MemoryFragments.text = "Memory Shards Collected: " + \
	var_to_str(GameManager.currency)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_menu_button_pressed() -> void:
	GameManager.end_game()
