extends CharacterBody3D
class_name Shadow

# NOTE: this works now because shadows are only instanced after dungeon generation
# is done (check the spawner script for details)
@onready var player = get_tree().get_first_node_in_group("Player")
@export var damage_particles: PackedScene
@export var health = 100
@export var sanity_reward = 20

const STOP_DIST = 2
const DMG = 0.4

var min_speed: float = 7.0
var max_speed: float = 10.0
var speed: float

func _ready() -> void:
	GameManager.total_enemies += 1
	speed = randf_range(min_speed, max_speed)

func _physics_process(_delta: float) -> void:
	if not player:
		return

	var pos = global_transform.origin
	var target = player.global_transform.origin
	var to_player = target - pos
	var dist = to_player.length()
	
	if dist > 0.1:
		var dir = to_player / dist
		var move_speed = speed
		if dist < STOP_DIST:
			move_speed *= dist / STOP_DIST
		velocity = dir * move_speed
	else:
		velocity = Vector3.ZERO
	
	if dist < STOP_DIST:
		player.take_damage(0.05)
	
	move_and_slide()
	look_at(player.global_transform.origin, Vector3.UP)
	
	for index in get_slide_collision_count():
		var collision := get_slide_collision(index)
		var body := collision.get_collider()
		if body and body.is_in_group("Player"):
			body.take_damage(DMG)


func take_damage(damage: float):
	health = max(0, health - damage)
	_spawn_particles()
	if health == 0:
		player.heal(sanity_reward)
		GameManager.enemies_killed += 1
		queue_free()

func _spawn_particles():
	if damage_particles:
		var p = damage_particles.instantiate()
		get_parent().add_child(p)
		p.global_position = global_position
		p.emitting = true
