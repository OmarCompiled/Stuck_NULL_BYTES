extends Node

var heal_overlay: ColorRect
var player_health_component: HealthComponent

var current_heal_intensity: float = 0.0
var heal_intensity_target: float = 0.0
var heal_effect_timer: float = 0.0

func find_heal_overlay():
	var heal_canvas = get_tree().get_first_node_in_group("heal_canvas")
	if not heal_canvas:
		push_warning("HealingEffectManager: No heal canvas found.")
		return
		
	heal_overlay = heal_canvas.get_node("HealOverlay")
		
	if not heal_overlay:
		push_warning("HealingEffectManager: No heal overlay found.")
		return
	
	if heal_overlay.material:
		heal_overlay.material.set_shader_parameter("heal_intensity", 0.0)
		heal_overlay.material.set_shader_parameter("heal_time", 0.0)

func set_player_health_component(health_comp: HealthComponent):
	if player_health_component:
		if player_health_component.healing_received.is_connected(_on_healing_received):
			player_health_component.healing_received.disconnect(_on_healing_received)
	
	player_health_component = health_comp
	player_health_component.healing_received.connect(_on_healing_received)
	
func _on_healing_received(amount: float):
	if amount <= 0:
		return
		
	var intensity = min(amount / 20.0, 1.0)  
	
	if intensity < 0.05:
		return
		
	heal_intensity_target = intensity
	heal_effect_timer = 0.0

func _process(delta):
	heal_effect_timer += delta
	
	current_heal_intensity = lerp(current_heal_intensity, heal_intensity_target, delta * 3.0)  # Slower fade than damage
	
	if heal_intensity_target > 0:
		heal_intensity_target = max(heal_intensity_target - delta * 1.5, 0.0)  # Longer duration than damage
	
	if heal_overlay and is_instance_valid(heal_overlay) and heal_overlay.material:
		heal_overlay.material.set_shader_parameter("heal_intensity", current_heal_intensity)
		heal_overlay.material.set_shader_parameter("heal_time", heal_effect_timer)

func cleanup():
	current_heal_intensity = 0.0
	heal_intensity_target = 0.0
	heal_effect_timer = 0.0
	
	if heal_overlay and is_instance_valid(heal_overlay) and heal_overlay.material:
		heal_overlay.material.set_shader_parameter("heal_intensity", 0.0)
		heal_overlay.material.set_shader_parameter("heal_time", 0.0)
