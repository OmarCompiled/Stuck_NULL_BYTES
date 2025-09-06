extends Node3D

func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("Flash") and $ProgressBar.value > 0:
		$SpotLight3D.light_energy = 5
	else:
		$SpotLight3D.light_energy = 0
	
func _process(delta: float) -> void:
	if Input.is_action_pressed("Flash"):
		$ProgressBar.value -= 0.2
	else:
		$ProgressBar.value += 0.1
	
