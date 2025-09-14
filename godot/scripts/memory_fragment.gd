extends CharacterBody3D
class_name Collectible

@export var attraction_force: float = 1.0
@export var max_speed: float = 25.0
@export var collect_distance: float = 0.7
@export var idle_rotation_speed: float = 1.0  # radians per second

@onready var light = $FragmentLight
@onready var base_light = light.light_energy
@onready var base_range = light.omni_range

var player: Node3D = null
var chasing: bool = false
var energy_pulse = 6
var range_pulse = 0.1
var t = 0.0
var freq = 2.0


func _on_detection_area_body_entered(body: Node3D) -> void:
	if body is Player:
		player = body
		# Turn off collisions (phase through everything)
		collision_layer = 0
		collision_mask = 0
		chasing = true


func _physics_process(delta: float) -> void:
	_update_light(delta)
	
	if chasing and player:
		var to_player = player.global_position - global_position
		var dist = to_player.length()

		if dist < collect_distance:
			_get_collected()
			return
			
		var dir = to_player.normalized()
		velocity = velocity.lerp(dir * max_speed, attraction_force * delta)
	else:
		rotate_y(idle_rotation_speed * delta)
		velocity += get_gravity() * 2.5 * delta
	
	move_and_slide()
	
	
func _get_collected() -> void:
	GameManager.currency += 1
	queue_free()
	
	
func _update_light(delta: float) -> void:
	t += delta
	light.light_energy = base_light + sin(t * freq) * energy_pulse
	light.omni_range = base_range + sin(t * freq) * range_pulse
