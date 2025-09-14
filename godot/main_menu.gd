extends Control

var button: String = ""

# Template functions; leave as is; might need them later
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_pressed() -> void:
	button = "start"
	$FadeTransition.show()
	$FadeTransition/AnimationPlayer.play("fade_in")
	$FadeTransition/FadeTimer.start()
	
	$MarginContainer/VBoxContainer/ButtonContainer.hide()
	

func _on_fade_timer_timeout() -> void:
	if button == "start":
		get_tree().change_scene_to_file("res://world.tscn")
