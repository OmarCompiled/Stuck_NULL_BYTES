extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4
const SENSETIVITY = 0.03

var gravity = 9.8

@onready var head = $Head
@onready var cam  = $Head/Camera3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSETIVITY)
		cam.rotate_x(-event.relative.y * SENSETIVITY)
		cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _process(delta: float) -> void:
	$SanityBar.value -= 0.01

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var input_dir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	
	move_and_slide()
