extends CharacterBody3D

@onready var sanity_bar: Node = $SanityBar
@export var health_component: Node

# Sanity
const SANITY_LOSS_RATE = 0.01

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
var is_dashing = false
var dash_timer = 0.0 # TODO: replace with get_tree().create_timer()
var dash_cooldown_timer = 0.0
var dash_direction = Vector3.ZERO

# Camera
const SENSITIVITY = 0.0023

# Head bob
const BOB_FREQ = 1.5
const BOB_AMP = 0.08
var t_bob = 0;

# FOV
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

var knockback_force = 17

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _process(_delta: float) -> void:	
	if Input.is_action_pressed("Quit"): # Esc 
		get_tree().quit()
	
	health_component.take_damage(SANITY_LOSS_RATE, true)
	
	if is_dashing:
		dash_timer -= _delta
		if dash_timer <= 0:
			end_dash()
	
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= _delta
		$DashCooldownBar.value = (DASH_COOLDOWN - dash_cooldown_timer) / DASH_COOLDOWN * 100
	else:
		$DashCooldownBar.value = 100

func start_dash():
	is_dashing = true
	dash_timer = DASH_DURATION
	dash_cooldown_timer = DASH_COOLDOWN

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
			
func end_dash() -> void:
	is_dashing = false
	velocity.x = dash_direction.x * speed
	velocity.z = dash_direction.z * speed
	
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
	
	speed = SPRINT_SPEED if is_sprinting else WALK_SPEED
	
	if not is_on_floor():
		velocity += get_gravity() * 2.5 * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_pressed("Sprint"):
		is_sprinting = true
	else:
		is_sprinting = false
	
	if Input.is_action_pressed("Dash") and dash_cooldown_timer <= 0 and not is_dashing: # E
		start_dash()

	var input_dir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	var direction = (camera.global_transform.basis.z * input_dir.y + camera.global_transform.basis.x * input_dir.x).normalized()
	direction.y = 0

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor()) # only bobs when walking, not jumping
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	_fov(delta)

	move_and_slide()
	
	#for index in get_slide_collision_count():
		#var collision := get_slide_collision(index)
		#var body := collision.get_collider()
		#if body is Shadow:
			#health_component.take_damage(body.dmg)
			#body.apply_knockback(-collision.get_normal() * knockback_force)
			
func die():
	GameManager.end_game()

func _on_hitbox_area_entered(area: Area3D) -> void:
	if area.name == "Hitbox":
		var enemy = area.get_parent()
		var knockback_dir = enemy.global_position - global_position
		health_component.take_damage(enemy.dmg)
		enemy.apply_knockback(knockback_dir * knockback_force)
		
