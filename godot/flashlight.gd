extends Node3D

@onready var ray = $RayCast3D
@onready var spot_light = $SpotLight3D
@onready var cooldown = $CoolDownBar

@export var dmg: float = 5
@export var drain: float = 0.25
@export var recharge: float = 0.15

func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("Flash") and cooldown.value > 0:
		spot_light.light_energy = 16
	else:
		spot_light.light_energy = 0

func _process(_delta: float) -> void:
	if Input.is_action_pressed("Flash"):
		cooldown.value = max(cooldown.value - drain, 0)
	else:
		cooldown.value += recharge
		
func _physics_process(_delta: float) -> void:
	_attack()

func _attack():
	if spot_light.light_energy > 0: # Only attack if the flashlight is on
		ray.force_raycast_update()
		if ray.is_colliding():
			var collided_object = ray.get_collider()
			if collided_object is Shadow:
				collided_object.health_component.take_damage(dmg)
