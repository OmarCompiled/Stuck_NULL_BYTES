extends Node

var sanity_overlay: ColorRect
var player_health_component: HealthComponent

var current_sanity_intensity: float = 0.0
var intensity_target: float = 0.0
const SANITY_START_PERCENT = 0.6

func find_sanity_overlay():
	var sanity_canvas = get_tree().get_first_node_in_group("sanity_canvas")
	if not sanity_canvas:
		push_warning("SanityEffectsHandler: No sanity canvas found. Screen effects will be disabled.")
		return
		
	sanity_overlay = sanity_canvas.get_node("SanityOverlay")
		
	if not sanity_overlay:
		push_warning("SanityEffectsHandler: No sanity overlay found. Screen effects will be disabled.")

func set_player_health_component(health_comp: HealthComponent):
	if player_health_component and player_health_component.health_changed.is_connected(_on_health_changed):
		player_health_component.health_changed.disconnect(_on_health_changed)
	
	player_health_component = health_comp
	player_health_component.health_changed.connect(_on_health_changed)
	
	_on_health_changed(health_comp.current_health)

func _on_health_changed(_new_health: float):
	if not player_health_component:
		return
		
	var health_percent = player_health_component.get_health_percentage()
	
	if health_percent > SANITY_START_PERCENT:
		intensity_target = 0.0
	else:
		var remapped_value = remap(health_percent, 0.0, SANITY_START_PERCENT, 1.0, 0.0)
		intensity_target = pow(remapped_value, 2.0)
		
		
func _process(delta):
	current_sanity_intensity = lerp(current_sanity_intensity, intensity_target, delta * 2.0)
	
	if sanity_overlay and is_instance_valid(sanity_overlay) and sanity_overlay.material:
		sanity_overlay.material.set_shader_parameter("sanity_intensity", current_sanity_intensity)
		sanity_overlay.material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)

func clear_player_health_component():
	if player_health_component and player_health_component.health_changed.is_connected(_on_health_changed):
		player_health_component.health_changed.disconnect(_on_health_changed)
	player_health_component = null
	intensity_target = 0.0
