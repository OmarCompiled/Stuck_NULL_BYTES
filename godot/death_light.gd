extends OmniLight3D

@export var float_height: float = 0.5   
@export var float_speed: float = 2.0    
@export var pulse_strength: float = 2

var base_y: float
var base_energy: float
var time: float = 0.0

func _ready():
	base_y = global_position.y
	base_energy = light_energy
	$death_light_timer.start(10)

func _process(delta: float):
	time += delta

	var height_offset = sin(time * float_speed) * float_height
	global_position.y = base_y + height_offset
	light_energy = base_energy + (height_offset / float_height) * pulse_strength

func _on_death_light_timer_timeout() -> void:
	queue_free()
