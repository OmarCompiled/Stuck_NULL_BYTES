extends Node

var sanity_overlay: ColorRect
var player_health_component: HealthComponent

var current_sanity_intensity: float = 0.0
var intensity_target: float = 0.0
const SANITY_START_PERCENT = 0.6
const LAUGH_THRESHOLD = 0.4  # 40% sanity

# Laugh sound variables
var laugh_sound: AudioStream
var laugh_player: AudioStreamPlayer
var laugh_cooldown: float = 0.0
var laugh_chance: float = 0.2  
var min_laugh_delay: float = 15.0 
var max_laugh_delay: float = 45.0 

func _ready():
	laugh_sound = preload("res://assets/sfx/general/laugh2.wav")
	
	laugh_player = AudioStreamPlayer.new()
	laugh_player.volume_db = 10.0
	add_child(laugh_player)

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
		
	_try_play_laugh_sound(health_percent)
		
		
func _process(delta):
	current_sanity_intensity = lerp(current_sanity_intensity, intensity_target, delta * 2.0)
	
	if sanity_overlay and is_instance_valid(sanity_overlay) and sanity_overlay.material:
		sanity_overlay.material.set_shader_parameter("sanity_intensity", current_sanity_intensity)
		sanity_overlay.material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)
	
	if laugh_cooldown > 0:
		laugh_cooldown = max(laugh_cooldown - delta, 0.0)


func _try_play_laugh_sound(health_percent: float):
	if health_percent <= LAUGH_THRESHOLD and laugh_cooldown <= 0:
		var dynamic_chance = remap(health_percent, 0.0, LAUGH_THRESHOLD, 0.5, 0.2)
		
		if randf() < dynamic_chance:
			_play_laugh_sound()
			
			var min_delay = remap(health_percent, 0.0, LAUGH_THRESHOLD, 10.0, 20.0)
			var max_delay = remap(health_percent, 0.0, LAUGH_THRESHOLD, 30.0, 45.0)
			laugh_cooldown = randf_range(min_delay, max_delay)


func _play_laugh_sound():
	if laugh_sound and laugh_player:
		laugh_player.stream = laugh_sound
		laugh_player.pitch_scale = randf_range(0.8, 1.2)
		laugh_player.play()
		
func clear_player_health_component():
	if player_health_component and player_health_component.health_changed.is_connected(_on_health_changed):
		player_health_component.health_changed.disconnect(_on_health_changed)
	player_health_component = null
	intensity_target = 0.0
