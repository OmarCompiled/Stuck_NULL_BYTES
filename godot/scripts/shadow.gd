extends CharacterBody3D
class_name Shadow

@export var health_component: HealthComponent
@export var whoosh_player: AudioStreamPlayer3D
@export var hit_player: AudioStreamPlayer3D
@export var damage_particles: PackedScene
@export var death_light_scene: PackedScene
@export var memory_fragment: PackedScene

@export var sanity_reward = 8 # 5 was too low

@export var knockback_decay: float = 0.95

@export var dmg = 15

@export var min_speed: float = 10.0
@export var max_speed: float = 12.0

@export var min_shards: int = 1
@export var max_shards: int = 3

@export var min_whoosh_interval: float = 3.0
@export var max_whoosh_interval: float = 5.0
@export_range(0.0, 1.0) var whoosh_probability: float = 1

@export var min_chase_pitch: float = 0.5
@export var max_chase_pitch: float = 0.8
@export var min_death_pitch: float = 1.4
@export var max_death_pitch: float = 1.6
@export var min_volume: float = -20.0
@export var max_volume: float = -15.0

@onready var chase_timer = $ChaseTimer

var speed: float = randf_range(min_speed, max_speed)
var can_see_player: bool = false
var is_knocked_back: bool = false
var knockback_timer = 0.0
var knockback_duration = 0.7
var shard_count: int = randi_range(min_shards, max_shards)
var player: Player
var look_for_player = false
var has_played_first_whoosh = false  # Renamed for clarity

func _ready() -> void:
	GameManager.total_enemies += 1
	_reset_whoosh_timer()  # Start the timer initially

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
	_reparent_player(whoosh_player)
	_reparent_player(hit_player)
	
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
	if whoosh_player.playing:
		whoosh_player.stop()
		
	whoosh_player.pitch_scale = randf_range(min_chase_pitch, max_chase_pitch)
	whoosh_player.volume_db = randf_range(min_volume, max_volume)
	whoosh_player.play()
		
func _play_death_woosh():
	var death_player = AudioStreamPlayer3D.new()
	get_tree().current_scene.add_child(death_player)
	death_player.global_position = global_position
	death_player.max_distance = 35.0
	death_player.stream = whoosh_player.stream
	death_player.pitch_scale = randf_range(min_death_pitch, max_death_pitch)
	death_player.volume_db = randf_range(min_volume, max_volume) + 25
	death_player.play()
	death_player.connect("finished", death_player.queue_free)


func _reset_whoosh_timer():
	chase_timer.wait_time = randf_range(min_whoosh_interval, max_whoosh_interval)
	chase_timer.start()


func _reparent_player(sound_player: AudioStreamPlayer3D):
	if sound_player.playing:
		var world = get_tree().current_scene
		sound_player.reparent(world)
		sound_player.finished.connect(sound_player.queue_free)
		

func hit():
	hit_player.pitch_scale = randf_range(0.7, 1.3)
	hit_player.play()
	_reset_whoosh_timer()
