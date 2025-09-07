extends Node3D

@onready var ray = $RayCast3D

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
func _physics_process(delta: float) -> void:
	ray.force_raycast_update()
	if ray.is_colliding():
		var collided_object = ray.get_collider()
		if collided_object is Shadow:
			collided_object.health -= 25
