extends OmniLight3D

# The time it takes the room's light to turn off
@export var dimming_seconds = 1
var max_energy = light_energy
var dimming_rate = max_energy / dimming_seconds
var is_dimming = false

func _process(delta: float) -> void:
	if is_dimming:
		_dim_light(delta)

func _dim_light(delta: float) -> void:
	light_energy = max(0, light_energy - dimming_rate * delta);
	if light_energy == 0:
		is_dimming = false


func _on_healing_area_room_health_depleted() -> void:
	is_dimming = true
