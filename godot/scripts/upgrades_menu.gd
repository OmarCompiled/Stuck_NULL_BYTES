extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$MarginContainer/VBoxContainer/BarsContainer/RichTextLabel.text = "Memory Fragments: " + var_to_str(GameManager.currency)

func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
