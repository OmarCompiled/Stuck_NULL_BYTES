extends CharacterBody3D
class_name Shadow

@export var health_component: HealthComponent
@export var damage_particles: PackedScene
@export var death_light_scene: PackedScene
@export var sanity_reward = 5
@export var knockback_decay: float = 0.95
@export var dmg = 15
@export var min_speed: float = 10.0
@export var max_speed: float = 12.0

var memory_fragment: PackedScene = preload("res://memory_fragment.tscn")

var speed: float
var can_see_player: bool = false
var is_knocked_back: bool = false
var knockback_timer = 0.0
var knockback_duration = 0.7

var player: Player
var look_for_player = false

func _ready() -> void:
	GameManager.total_enemies += 1
	speed = randf_range(min_speed, max_speed)

func _physics_process(delta: float) -> void:	
	if is_knocked_back:
		velocity *= knockback_decay
		knockback_timer -= delta
		is_knocked_back = knockback_timer > 0
			
	elif player:
		# If the player is inside the detection area
		if look_for_player:
			check_line_of_sight(player)
			
		# If the raycast reached the player
		if can_see_player:
			var to_player = player.global_position - global_position
			var dir = to_player.normalized()
			velocity = dir * speed
				
		look_at(player.global_position, Vector3.UP)
	
	move_and_slide()
	
func apply_knockback(force):
	knockback_timer = knockback_duration
	is_knocked_back = true
	velocity += force

func _on_damage_taken(_damage: float):
	_spawn_particles()
		
func _on_health_depleted():
	var shard = memory_fragment.instantiate()
	shard.global_position = global_position
	get_tree().get_current_scene().add_child(shard)
	
	_die()

func _die():
	GameManager.enemies_killed += 1
	
	if player:
		player.health_component.heal(sanity_reward)
		
	_spawn_death_light()
	queue_free()

func _spawn_particles():
	if damage_particles:
		var p = damage_particles.instantiate()
		# NOTE: Particles are added to the parent so they aren't freed when the monster dies.
		get_parent().add_child(p)
		p.global_position = global_position
		p.emitting = true

func _spawn_death_light():
	if death_light_scene:
		var death_light = death_light_scene.instantiate()
		get_parent().add_child(death_light)
		death_light.global_position = global_position
		death_light.base_y = global_position.y

	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is not Player: return
	look_for_player = true
	player = body
	
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is not Player: return
	look_for_player = false

func check_line_of_sight(target):
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	
	query.from = global_position
	query.to = target.global_position
	query.exclude = [self]

	var result = space_state.intersect_ray(query)
	
	# Hit nothing or hit the player => can see the player
	can_see_player = result.is_empty() or result.collider == target
