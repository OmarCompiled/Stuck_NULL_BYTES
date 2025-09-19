extends CharacterBody3D
class_name Shadow

@export var health_component: HealthComponent
@export var chase_sound_component: SoundComponent
@export var close_sound_component: SoundComponent
@export var death_sound_component: SoundComponent
@export var hit_sound_component: SoundComponent
@export var detection_component: DetectionComponent
@export var loot_component: LootComponent

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
var is_knocked_back: bool = false
var knockback_timer = 0.0
var knockback_duration = 0.7
var shard_count: int = randi_range(min_shards, max_shards)
var has_played_first_whoosh = false
var can_play_close_sound = true

func _ready() -> void:
	GameManager.total_enemies += 1
	_reset_whoosh_timer()
	
	detection_component.player_spotted.connect(_on_player_spotted)
	detection_component.player_close.connect(_on_player_entered_close_range)
	

func _physics_process(delta: float) -> void:	
	if is_knocked_back:
		velocity *= knockback_decay
		knockback_timer -= delta
		is_knocked_back = knockback_timer > 0
			
	elif detection_component and detection_component.detected():
		var player = detection_component.get_player()
		var to_player = player.global_position - global_position
		var dir = to_player.normalized()
		velocity = dir * speed
			
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
	
	if detection_component and detection_component.get_player():
		detection_component.get_player().health_component.heal(sanity_reward)
		
	_spawn_death_light()
	
	loot_component.drop_loot()
		
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


func _on_player_spotted(_player: Player):
	# Play sound with a 100% chance on first sighting
	if not has_played_first_whoosh:
		_play_random_whoosh()
		has_played_first_whoosh = true


func _on_player_entered_close_range(_player: Player):
	if can_play_close_sound and detection_component.detected():
		_reset_whoosh_timer()
		_play_close_sound()
		can_play_close_sound = false
		await get_tree().create_timer(randf_range(5, 10)).timeout
		can_play_close_sound = true


func _on_chase_timer_timeout() -> void:
	if detection_component and detection_component.detected() and randf() < whoosh_probability:
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
