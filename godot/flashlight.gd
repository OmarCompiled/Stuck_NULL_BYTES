extends Node3D

@onready var ray = $RayCast3D
@onready var spot_light = $SpotLight3D
@onready var cooldown = $CoolDownBar

const DMG = 5
const DRAIN = 0.25
const RECHARGE = 0.15

func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("Flash") and cooldown.value > 0:
		spot_light.light_energy = 16
	else:
		spot_light.light_energy = 0

func _process(_delta: float) -> void:
	if Input.is_action_pressed("Flash"):
		cooldown.value = max(cooldown.value - DRAIN, 0)
	else:
		cooldown.value += RECHARGE
		
func _physics_process(_delta: float) -> void:
	_attack()

func _attack():
	if spot_light.light_energy > 0:	
		ray.force_raycast_update()
		if ray.is_colliding():
			var collided_object = ray.get_collider()
			if collided_object is Shadow:
				collided_object.health_component.take_damage(DMG)
