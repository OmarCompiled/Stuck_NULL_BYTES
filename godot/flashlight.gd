extends Node3D

func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("Flash") and $CoolDownBar.value > 0:
		$SpotLight3D.light_energy = 16
	else:
		$SpotLight3D.light_energy = 0
	
func _process(_delta: float) -> void:
	if Input.is_action_pressed("Flash"):
		$CoolDownBar.value -= 0.4
	else:
		$CoolDownBar.value += 0.1
	
