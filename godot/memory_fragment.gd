extends CharacterBody3D
class_name Collectible

@export var attraction_force: float = 10.0
@export var max_speed: float = 20.0
@export var collect_distance: float = 1.0

@onready var light = $FragmentLight
@onready var base_light = light.light_energy
@onready var base_range = light.omni_range

var player: Node3D = null
var chasing: bool = false
var energy_pulse = 6;
var radius_pulse = 0.2
var t = 0;
var freq = 2


func _on_detection_area_body_entered(body: Node3D) -> void:
	if body is Player:
		player = body
		# Turn off collisions (phase through everything)
		collision_layer = 0
		collision_mask = 12
		chasing = true

>>>>>>> 83067c5cabc576b5dcc2af6bcd92ab67812dd6ef
func _physics_process(delta: float) -> void:
	_update_light(delta)
	if chasing and player:
		var to_player = player.global_position - global_position
		var dist = to_player.length()

		if dist < collect_distance:
			GameManager.currency += 1
			queue_free()
			return
			
		var dir = to_player.normalized()
		velocity = velocity.lerp(dir * max_speed, attraction_force * delta)
	else:
		velocity += get_gravity() * 2.5 * delta
	
	move_and_slide()

func _on_shard_hitbox_area_entered(area: Area3D) -> void:
	if area.get_parent() is Player:
		GameManager.currency += 1
		queue_free()
		
func _update_light(delta: float) -> void:
	t += delta
	light.light_energy = base_light + sin(t * freq) * energy_pulse
	light.omni_range = base_range + sin(t * freq) * radius_pulse
