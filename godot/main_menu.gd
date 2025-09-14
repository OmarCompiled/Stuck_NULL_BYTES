extends Control

var button: String = ""
var buttons = ["start", "upgrades", "options"]

# Template functions; leave as is; might need them later
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	if button == buttons[1]:
		get_tree().change_scene_to_file("res://upgrades_menu.tscn")
	elif button == buttons[2]:
		pass

func _on_start_pressed() -> void:
	button = buttons[0]
	$FadeTransition.show()
	$FadeTransition/AnimationPlayer.play("fade_in")
	$FadeTransition/FadeTimer.start()
	
	$MarginContainer/VBoxContainer/ButtonContainer.hide()

func _on_upgrades_pressed() -> void:
	button = buttons[1]

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_fade_timer_timeout() -> void:
	$FadeTransition.hide()
	if button == buttons[0]:
		get_tree().change_scene_to_file("res://world.tscn")
	
