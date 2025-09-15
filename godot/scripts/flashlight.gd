extends Node3D

@onready var spot_light = $DetectionArea/SpotLight3D
@onready var cooldown = $CoolDownBar
@onready var detection_area = $DetectionArea
@export var on_sound_component: SoundComponent
@export var off_sound_component: SoundComponent
@export var damage_per_second: float = 150.0
@export var drain_per_second: float = 50
@export var recharge_per_second: float = 100/3

var is_flashlight_on = false
var enemies_in_area = []

func _ready():
	spot_light.light_energy = 0

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Flash") and cooldown.value > 0 and not is_flashlight_on:
		_turn_flashlight_on()
	elif Input.is_action_just_released("Flash") and is_flashlight_on:
		_turn_flashlight_off()

func _process(delta: float) -> void:
	if is_flashlight_on:
		cooldown.value = max(cooldown.value - drain_per_second * delta, 0)
		_damage_enemies_in_light(delta)
	else:
		cooldown.value += recharge_per_second * delta
		
	if cooldown.value == 0:
		_turn_flashlight_off()
		
func _turn_flashlight_on():
	off_sound_component.stop()
	on_sound_component.play()
	
	is_flashlight_on = true
	spot_light.light_energy = 16
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
		
	# Add any enemies already in the area
	for body in detection_area.get_overlapping_bodies():
		if body is Shadow:
			enemies_in_area.append(body)
	
func _turn_flashlight_off():
	on_sound_component.stop()
	off_sound_component.play()
	
	is_flashlight_on = false
	spot_light.light_energy = 0
	
	detection_area.body_entered.disconnect(_on_body_entered)
	detection_area.body_exited.disconnect(_on_body_exited)
	enemies_in_area.clear()
	
func _on_body_entered(body: Node3D):
	if body is Shadow and not enemies_in_area.has(body):
		enemies_in_area.append(body)

func _on_body_exited(body: Node3D):
	if body is Shadow and enemies_in_area.has(body):
		enemies_in_area.erase(body)

func _damage_enemies_in_light(delta: float):
	for enemy in enemies_in_area:
		if is_instance_valid(enemy) and _check_ray(enemy):
			enemy.health_component.take_damage(damage_per_second * delta)

func _check_ray(body: Node3D):
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	
	query.from = spot_light.global_transform.origin
	query.to = body.global_transform.origin
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	
	var in_sight = result and result.collider == body
	return in_sight
