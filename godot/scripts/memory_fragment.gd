class_name Collectible
extends CharacterBody3D

@export var acceleration: float = 45.0
@export var max_speed: float = 200.0
@export var collect_distance: float = 2.0
@export var idle_rotation_speed: float = 1.3  # radians per second
@export var moving_rotation_speed: float = idle_rotation_speed * 2
@export var collect_sound_component: SoundComponent
@onready var light = $FragmentLight
@onready var base_light = light.light_energy
@onready var base_range = light.omni_range

var player: Node3D = null
var chasing: bool = false
var energy_pulse = 6
var range_pulse = 0.1
var t = 0.0
var freq = 2.0
var current_speed: float = 0.0:
	set(value):
		current_speed = min(value, max_speed)
		 
func _ready() -> void:
	velocity = Vector3(0, 5, 0)
		
		
func _on_detection_area_body_entered(body: Node3D) -> void:
	if body is Player:
		_start_chasing(body);
		
		
func _physics_process(delta: float) -> void:
	_update_light(delta)
	
	if chasing and player:
		_chase(delta)
	else:
		_idle(delta)
		
	rotate_y(idle_rotation_speed * delta)
	move_and_slide()
	
func _start_chasing(body: Player):
		chasing = true
		player = body
		
		# Turn off collisions (phase through everything)
		collision_layer = 0
		collision_mask = 0
		
		velocity = Vector3.ZERO
		
		
func _chase(delta: float) -> void:
		var to_player = player.global_position - global_position
		var dist = to_player.length()
		
		if dist < collect_distance:
			_get_collected()
			return
		
		current_speed += acceleration * delta
		var dir = to_player.normalized()
		velocity = dir * current_speed
		
		
func _idle(delta: float) -> void:
	velocity += get_gravity() * 3 * delta
		
		
func _get_collected() -> void:
	GameManager.current_run_currency += 1
	_play_sound()
	collect_sound_component.kill()
	queue_free()
	
func _update_light(delta: float) -> void:
	t += delta
	light.light_energy = clamp(base_light + sin(t * freq) * energy_pulse, 1, 16)
	light.omni_range = base_range + sin(t * freq) * range_pulse


func _play_sound():
	collect_sound_component.play(1.3, 1.5)	
