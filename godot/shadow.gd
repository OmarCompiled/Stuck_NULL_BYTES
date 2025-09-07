extends CharacterBody3D
class_name Shadow

@export var health = 100

const SPEED = 4.0
const STOP_DIST = 3

@onready var player

func _physics_process(delta: float) -> void:
	if health == 0:
		queue_free()
	# I know what you're thinking, but this fixed a major problem
	player = get_tree().get_first_node_in_group("Player")
	
	if player == null:
		return
	var pos = global_transform.origin
	var target = player.global_transform.origin
	var to_player = target - pos
	
	var plane = Vector3(to_player.x, 0.0, to_player.z)
	var dist = plane.length()
	
	if dist >= STOP_DIST:
		var dir = plane / dist
		velocity.x = dir.x * SPEED
		velocity.z = dir.z * SPEED
	else:
		player.sanity_bar.value -= 0.05
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		velocity.z = move_toward(velocity.z, 0.0, SPEED)
	
	move_and_slide()
	
	basis.looking_at(player.position, Vector3.UP)
