class_name DashShadow extends Shadow

@export var health_component: HealthComponent
@export var detection_component: DetectionComponent
@export var loot_component: LootComponent
@export var chase_sound_component: SoundComponent
@export var dash_sound_component: SoundComponent
@export var death_sound_component: SoundComponent
@export var hit_sound_component: SoundComponent
@export var dash_commit_sound_component: SoundComponent

@export var damage_particles: PackedScene
@export var death_light_scene: PackedScene

@export var sanity_reward = 17

@export var knockback_duration: float = 0.7
@export var knockback_decay: float = 0.95

@export var regular_dmg = 8
@export var dash_dmg = 18

@export var min_speed: float = 18.0
@export var max_speed: float = 21.0

@export var min_whoosh_interval: float = 3.0
@export var max_whoosh_interval: float = 5.0
@export_range(0.0, 1.0) var whoosh_probability: float = 1.0

var speed: float = randf_range(min_speed, max_speed)
var knockback_impulse: Vector3 = Vector3.ZERO
var dmg: float = regular_dmg
var dash_dir: Vector3 = Vector3.ZERO
var state_machine: AI.StateMachine
var sound_components: Array[SoundComponent] = []

func _ready() -> void:
	super._ready()
	
	sound_components = [
		chase_sound_component,
		dash_sound_component,
		death_sound_component,
		hit_sound_component,
		dash_commit_sound_component
	]
	
	state_machine = AI.StateMachine.new()
	add_child(state_machine)
	
	health_component.health_depleted.connect(func() -> void:
		state_machine.trigger_event(AI.Events.HEALTH_DEPLETED)
	)
	
	detection_component.player_first_spotted.connect(func(_player: Player) -> void:
		state_machine.trigger_event(AI.Events.PLAYER_SPOTTED)
	)
	
	detection_component.player_lost.connect(func(_player: Player):
		state_machine.trigger_event(AI.Events.PLAYER_OUT_OF_SIGHT)  
	)
	
	detection_component.player_exited_range.connect(func(_player: Player):
		state_machine.trigger_event(AI.Events.PLAYER_OUT_OF_RANGE)  
	)
	
	detection_component.player_close.connect(func(_player: Player):
		state_machine.trigger_event(AI.Events.PLAYER_CLOSE)
	)
	
	var idle := AI.StateIdle.new(self)
	
	var chase := AI.StateChase.new(self)
	chase.speed = speed
	
	var charge_up := AI.StateCharge.new(self, AI.ChargeType.UP)
	var charge_down := AI.StateCharge.new(self, AI.ChargeType.DOWN)
	var dash := AI.StateDash.new(self)
	var die := AI.StateDie.new(self)
	var stagger := AI.StateStagger.new(self)
	
	state_machine.transitions = {
		idle: {
			AI.Events.PLAYER_SPOTTED: chase,
		},
		chase: {
			AI.Events.PLAYER_CLOSE: charge_up,  
			AI.Events.PLAYER_OUT_OF_SIGHT: chase,  
		},
		charge_up: {
			AI.Events.FINISHED: dash,
			AI.Events.PLAYER_OUT_OF_SIGHT: chase,  
		},
		dash: {
			AI.Events.FINISHED: charge_down,
		},
		charge_down: {
			AI.Events.FINISHED: chase,  
			AI.Events.PLAYER_CLOSE: charge_up,  
		},
		stagger: {
			AI.Events.FINISHED: chase,  
		},
		die: {},
	}
	
	state_machine.add_transition_to_all_states(AI.Events.PLAYER_OUT_OF_RANGE, idle)
	state_machine.add_transition_to_all_states(AI.Events.HEALTH_DEPLETED, die)
	state_machine.add_transition_to_all_states(AI.Events.ATTACKED, stagger)
	
	state_machine.activate(idle)

func _spawn_particles():
	if damage_particles:
		var p = damage_particles.instantiate()
		get_parent().add_child(p)
		p.global_position = global_position
		p.emitting = true
		
func apply_knockback(force):
	knockback_impulse += force
	state_machine.trigger_event(AI.Events.ATTACKED)

func _on_damage_taken(_damage: float):
	_spawn_particles()
