extends Node

var hit_overlay: ColorRect
var trauma: float = 0.0
var max_shake: float = 10.0
var player_health_component: HealthComponent

var current_hit_intensity: float = 0.0
var hit_intensity_target: float = 0.0
var hit_effect_timer: float = 0.0

func find_hit_overlay():
	var hit_canvas = get_tree().get_first_node_in_group("hit_canvas")
	if not hit_canvas:
		push_warning("HitEffectManager: No hit canvas found.")
		return
		
	hit_overlay = hit_canvas.get_node("HitOverlay")
		
	if not hit_overlay:
		push_warning("HitEffectManager: No hit overlay found.")
		return
	
	if hit_overlay.material:
		hit_overlay.material.set_shader_parameter("hit_intensity", 0.0)
		hit_overlay.material.set_shader_parameter("hit_time", 0.0)

func set_player_health_component(health_comp: HealthComponent):
	if player_health_component and player_health_component.damage_taken.is_connected(_on_damage_taken):
		player_health_component.damage_taken.disconnect(_on_damage_taken)
	
	player_health_component = health_comp
	player_health_component.damage_taken.connect(_on_damage_taken)
	
func _on_damage_taken(amount: float):
	if amount <= 0:
		return
		
	var intensity = min(amount / 15.0, 1.0)
	
	if intensity < 0.1:
		return
		
	hit_intensity_target = intensity
	hit_effect_timer = 0.0
	trauma = min(trauma + (0.2 * intensity), 1.0)

func _process(delta):
	hit_effect_timer += delta
	
	current_hit_intensity = lerp(current_hit_intensity, hit_intensity_target, delta * 5.0)
	
	if hit_intensity_target > 0:
		hit_intensity_target = max(hit_intensity_target - delta * 2.0, 0.0)
	
	if hit_overlay and is_instance_valid(hit_overlay) and hit_overlay.material:
		hit_overlay.material.set_shader_parameter("hit_intensity", current_hit_intensity)
		hit_overlay.material.set_shader_parameter("hit_time", hit_effect_timer)
	
	if trauma > 0:
		trauma = max(trauma - delta * 1.5, 0.0)
		if GameManager.player:
			apply_screen_shake()

func apply_screen_shake():
	if trauma <= 0:
		return
	
	var shake = trauma * trauma * max_shake
	var camera = GameManager.player.get_node("Head/Camera3D")
	if camera:
		camera.h_offset = randf_range(-shake, shake)
		camera.v_offset = randf_range(-shake, shake)
	else:
		var viewport_camera = get_viewport().get_camera_3d()
		if viewport_camera:
			viewport_camera.h_offset = randf_range(-shake, shake)
			viewport_camera.v_offset = randf_range(-shake, shake)

func cleanup():
	current_hit_intensity = 0.0
	hit_intensity_target = 0.0
	hit_effect_timer = 0.0
	trauma = 0.0
	
	if hit_overlay and is_instance_valid(hit_overlay) and hit_overlay.material:
		hit_overlay.material.set_shader_parameter("hit_intensity", 0.0)
		hit_overlay.material.set_shader_parameter("hit_time", 0.0)
	
	var camera = GameManager.player.get_node("Head/Camera3D") if GameManager.player else null
	if camera and is_instance_valid(camera):
		camera.h_offset = 0.0
		camera.v_offset = 0.0
	else:
		var viewport_camera = get_viewport().get_camera_3d()
		if viewport_camera:
			viewport_camera.h_offset = 0.0
			viewport_camera.v_offset = 0.0
