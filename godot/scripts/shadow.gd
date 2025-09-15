extends CharacterBody3D
class_name Shadow

@export var health_component: HealthComponent
@export var chase_sound_component: SoundComponent
@export var close_sound_component: SoundComponent
@export var death_sound_component: SoundComponent
@export var hit_sound_component: SoundComponent

@export var damage_particles: PackedScene
@export var death_light_scene: PackedScene
@export var memory_fragment: PackedScene

@export var sanity_reward = 8

@export var knockback_decay: float = 0.95

@export var dmg = 15

@export var min_speed: float = 10.0
@export var max_speed: float = 12.0

@export var min_shards: int = 1
@export var max_shards: int = 3

@export var min_whoosh_interval: float = 3.0
@export var max_whoosh_interval: float = 5.0
@export_range(0.0, 1.0) var whoosh_probability: float = 1

@onready var chase_timer = $ChaseTimer

var speed: float = randf_range(min_speed, max_speed)
var can_see_player: bool = false
var is_knocked_back: bool = false
var knockback_timer = 0.0
var knockback_duration = 0.7
var shard_count: int = randi_range(min_shards, max_shards)
var player: Player
var look_for_player = false
var has_played_first_whoosh = false
var can_play_close_sound = true
var is_close = false;

func _ready() -> void:
	GameManager.total_enemies += 1
	_reset_whoosh_timer()

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
			
			# Play sound 100% on first sighting
			if not has_played_first_whoosh:
				_play_random_whoosh()
				has_played_first_whoosh = true
			
	move_and_slide()
	
func apply_knockback(force):
	knockback_timer = knockback_duration
	is_knocked_back = true
	velocity += force

func _on_damage_taken(_damage: float):
	_spawn_particles()
		
func _on_health_depleted():
	_die()

func _die():
	GameManager.enemies_killed += 1
	
	if player:
		player.health_component.heal(sanity_reward)
		
	_spawn_death_light()
	
	for i in range(shard_count):
		_spawn_shard()
		
	_play_death_woosh()
	chase_sound_component.kill()
	close_sound_component.kill()
	death_sound_component.kill()
	hit_sound_component.kill()
	
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


func _spawn_shard():
	var shard = memory_fragment.instantiate()
	get_parent().add_child(shard)
	
	var offset = Vector3(
		randf_range(-0.5, 0.5),
		0.2,
		randf_range(-0.5, 0.5)
	)
	
	shard.global_position = global_position + offset


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is not Player: return
	look_for_player = true
	player = body
	
	
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is not Player: return
	look_for_player = false
	can_see_player = false
	has_played_first_whoosh = false

func check_line_of_sight(target):
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	
	query.from = global_position
	query.to = target.global_position
	query.exclude = [self]

	var result = space_state.intersect_ray(query)
	
	# Hit nothing or hit the player => can see the player
	can_see_player = result.is_empty() or result.collider == target


func _on_chase_timer_timeout() -> void:
	if can_see_player and randf() < whoosh_probability:
		_play_random_whoosh()
		
	_reset_whoosh_timer()
	
	
func _play_random_whoosh():		
	chase_sound_component.play()
		
		
func _play_death_woosh():
	death_sound_component.play()


func _reset_whoosh_timer():
	if not chase_timer.is_inside_tree():
		return
	chase_timer.wait_time = randf_range(min_whoosh_interval, max_whoosh_interval)
	chase_timer.start()


func hit():
	hit_sound_component.play()
	_reset_whoosh_timer()
	
	
func _play_close_sound() -> void:
	close_sound_component.play()
	
func _on_close_detection_area_body_entered(body: Node3D) -> void:
	check_line_of_sight(body)
	if body is Player and can_play_close_sound and can_see_player:
		_reset_whoosh_timer()
		_play_close_sound()
		can_play_close_sound = false
		await get_tree().create_timer(randf_range(5, 10)).timeout
		can_play_close_sound = true
