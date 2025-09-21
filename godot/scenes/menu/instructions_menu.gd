extends Control

var _ready_button_pressed:bool = false

func _ready() -> void:
	$FadeTransition.show()
	$FadeTransition/AnimationPlayer.play("fade_out")
	$FadeTransition/fade_timer.start()

func _on_ready_button_pressed() -> void:
	_ready_button_pressed = true;
	$TextureRect/MarginContainer/VBoxContainer/ReadyButton.hide()
	$FadeTransition.show()
	$FadeTransition/AnimationPlayer.play("fade_in")
	$FadeTransition/fade_timer.start()

func _on_fade_timer_timeout() -> void:
	if !_ready_button_pressed:
		$FadeTransition.hide()
	else:
		get_tree().change_scene_to_file("res://scenes/other/world.tscn")
