extends CharacterBody3D
class_name Player

@export var health_component: HealthComponent

@export var walk_sound_component: SoundComponent 
@export var dash_sound_component: SoundComponent
@export var land_sound_component: SoundComponent
@export var jump_sound_component: SoundComponent

@onready var sanity_bar: Node = $SanityBar
@onready var head = $Head
@onready var camera = $Head/Camera3D

# Sanity
const SANITY_LOST_PER_SECOND = 2
var is_losing_sanity = true

# Movement
var speed = 0;
var is_sprinting = false;
const WALK_SPEED = 8.0
const SPRINT_SPEED = 15.0
const JUMP_VELOCITY = 12

# Dash
const DASH_SPEED = SPRINT_SPEED * 1.7
const DASH_DURATION = 0.3
const DASH_COOLDOWN = 2.0
var can_dash: bool = true
var is_dashing: bool = false
var dash_cooldown_timer: SceneTreeTimer
var dash_direction = Vector3.ZERO

# Camera
const SENSITIVITY = 0.0023

# Head bob
const BOB_FREQ = 1.5
const BOB_AMP = 0.2
var t_bob = 0;

# Footstep sync
var last_bob_cycle_pos = 0.0

# FOV
const BASE_FOV = 75.0
const FOV_CHANGE = 2

# Knockback
var knockback_force = 17

# Air
var was_in_air: bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GameManager.player = self
	SanityEffectsManager.set_player_health_component(health_component)
	HitEffectsManager.set_player_health_component(health_component)
	HealEffectsManager.set_player_health_component(health_component)
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _process(delta: float) -> void:	
	if is_losing_sanity: 
		health_component.take_damage(SANITY_LOST_PER_SECOND * delta, true)
		
	if dash_cooldown_timer:
		$DashCooldownBar.value = 100 - (dash_cooldown_timer.time_left / DASH_COOLDOWN) * 100
	else:
		$DashCooldownBar.value = 100

func start_dash():
	dash_sound_component.play()
	dash_cooldown_timer = get_tree().create_timer(DASH_COOLDOWN)
	can_dash = false
	is_dashing = true
	var input_dir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")

	if input_dir.length() > 0:
		dash_direction = (camera.global_transform.basis.z * input_dir.y + camera.global_transform.basis.x * input_dir.x).normalized()
	else:
		if is_on_floor():
			dash_direction = -camera.global_transform.basis.z
			dash_direction.y = 0
			dash_direction = dash_direction.normalized()
		else:
			dash_direction = -camera.global_transform.basis.z.normalized()
			
	await get_tree().create_timer(DASH_DURATION).timeout
	end_dash()
			
func end_dash() -> void:
	is_dashing = false
	# NOTE: velocity.y is unchanged for smoother movement
	velocity.x = dash_direction.x * speed
	velocity.z = dash_direction.z * speed
	await dash_cooldown_timer.timeout
	can_dash = true
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
	
func _fov(delta) -> void: 
	var velocity_clamped = clamp(velocity.length(), 0.5, DASH_SPEED)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

func _physics_process(delta: float) -> void:
	if is_dashing:
		velocity = dash_direction * DASH_SPEED
		_fov(delta)
		move_and_slide()
		return
	
	_check_landing()
	
	speed = SPRINT_SPEED if is_sprinting else WALK_SPEED
	
	if not is_on_floor():
		velocity += get_gravity() * 2.5 * delta
		walk_sound_component.player.stop()

	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sound_component.play()
		
	if Input.is_action_pressed("Sprint"):
		is_sprinting = true
		walk_sound_component.player.pitch_scale = 0.8
	else:
		is_sprinting = false
		walk_sound_component.player.pitch_scale = 0.6
	
	if Input.is_action_pressed("Dash") and can_dash: # E
		start_dash()
		
	var input_dir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	var direction = (camera.global_transform.basis.z * input_dir.y + camera.global_transform.basis.x * input_dir.x).normalized()
	direction.y = 0

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0
		velocity.z = 0
		walk_sound_component.stop()

	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor()) # only bobs when walking, not jumping
	camera.transform.origin = _headbob(t_bob)
	
	# Sync footsteps with head bob
	if direction and is_on_floor():
		var bob_cycle_pos = sin(t_bob * BOB_FREQ)	
		if bob_cycle_pos < -0.9 and last_bob_cycle_pos >= -0.9:
			walk_sound_component.play()
		last_bob_cycle_pos = bob_cycle_pos
	else:
		last_bob_cycle_pos = 0
		walk_sound_component.stop()
	
	# FOV
	_fov(delta)

	was_in_air = not is_on_floor()
	move_and_slide()
	
func die():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GameManager.end_game()

func _on_hitbox_area_entered(area: Area3D) -> void:
	if area.name == "ShadowHitbox":
		var enemy = area.get_parent()
		var knockback_dir = enemy.global_position - global_position
		health_component.take_damage(enemy.dmg)
		enemy.apply_knockback(knockback_dir * knockback_force)
		enemy.hit()
		
		
func _check_landing() -> void:
	if is_on_floor() and was_in_air:
		_play_land_sound()
		
		
func _play_land_sound():
	var fall_strength = clamp(abs(velocity.y) / JUMP_VELOCITY, 1.0, 5.0)
	
	var target_pitch = lerp(1.2, 0.8, fall_strength / 2.0)
	var target_volume = lerp(-50.0, -30.0, fall_strength / 2.0)
	
	land_sound_component.play(
		target_pitch * 0.9,
		target_pitch * 1.1,
		target_volume * 0.9,
		target_volume * 1.1
	)
