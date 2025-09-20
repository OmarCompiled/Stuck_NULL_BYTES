class_name AI extends RefCounted


enum Events {
	NONE,
	FINISHED,
	PLAYER_SPOTTED,
	PLAYER_OUT_OF_SIGHT,
	PLAYER_OUT_OF_RANGE,
	PLAYER_CLOSE,
	TOOK_DAMAGE,
	HEALTH_DEPLETED,
	ATTACKED,
}

enum ChargeType { UP, DOWN }

class StateMachine extends Node:
	
	var transitions := {}: set = set_transitions
	
	var current_state: State

	func _init() -> void:
		set_physics_process(false)
		
		
	func set_transitions(new_transitions: Dictionary) -> void:
		transitions = new_transitions
		if OS.is_debug_build():
			for state: State in transitions:
				assert(
					state is State,
					"Invalid state in the transitions dictionary. " +
					"Expected a State object, but got " + str(state)
				)
				for event: Events in transitions[state]:
					assert(
						event is Events,
						"Invalid event in the transitions dictionary. " +
						"Expected an Events object, but got " + str(event)
					)
					assert(
						transitions[state][event] is State,
						"Invalid state in the transitions dictionary. " +
						"Expected a State object, but got " +
						str(transitions[state][event])
					)
					
					
	func activate(initial_state: State = null) -> void:
		if initial_state != null:
			current_state = initial_state
		assert(
			current_state != null,
			"Activated the state machine but the state variable is null. " +
			"Please assign a starting state to the state machine."
		)
		current_state.finished.connect(_on_state_finished.bind(current_state))
		current_state.enter()
		set_physics_process(true)
		
			
	func add_transition_to_all_states(event: Events, end_state: State) -> void:
		for state: State in transitions:
			transitions[state][event] = end_state
			
			
	func trigger_event(event: Events) -> void:
		assert(
			transitions[current_state],
			"Current state doesn't exist in the transitions dictionary."
		)
		if not transitions[current_state].has(event):
			print_debug(
				"Trying to trigger event " + Events.keys()[event] +
				" from state " + current_state.name +
				" but the transition does not exist."
			)
			return
		var next_state =  transitions[current_state][event]
		_transition(next_state)
		
		
	func _physics_process(delta: float) -> void:
		var event := current_state.update(delta)
		if event == Events.NONE:
			return
		trigger_event(event)
		
		
	func _transition(new_state: State) -> void:
		current_state.exit()
		current_state.finished.disconnect(_on_state_finished)
		current_state = new_state
	
		current_state.finished.connect(_on_state_finished.bind(current_state))
	
		current_state.enter()
		
		
	func _on_state_finished(finished_state: State) -> void:
		assert(
			Events.FINISHED in transitions[current_state],
			"Received a state that does not have a transition for the FINISHED event, " + current_state.name + ". " +
			"Add a transition for this event in the transitions dictionary."
		)
		_transition(transitions[finished_state][Events.FINISHED])
		
		
class State extends RefCounted:
	
	signal finished
	
	var name := "State"
	var mob: Shadow = null
	
	func _init(init_name: String, init_mob: Shadow) -> void:
		name = init_name
		mob = init_mob
		
		
	func update(_delta: float) -> Events:
		return Events.NONE
		
		
	func enter() -> void:
		pass
		
		
	func exit() -> void:
		pass
		
		
class StateIdle extends State:
	func _init(init_mob: Shadow) -> void:
		super("Idle", init_mob)
		
	func enter() -> void:
		mob.velocity = Vector3.ZERO
		
		
class StateWait extends State:
	
	var duration := 0.5
	var _time := 0.0
	
	
	func _init(init_mob: Shadow) -> void:
		super("Wait", init_mob)
		
		
	func enter() -> void:
		_time = 0.0
		
		
	func update(delta: float) -> Events:
		_time += delta
		if _time >= duration:
			return Events.FINISHED
		return Events.NONE
		
		
class StateChase extends State:
	var whoosh_timer: Timer
	var whoosh_probability := 1.0
	var speed: float = 8.0

	func _init(init_mob: Shadow) -> void:
		super("Chase", init_mob)
		whoosh_timer = Timer.new()
		mob.add_child(whoosh_timer)
		whoosh_timer.one_shot = true
		whoosh_timer.timeout.connect(_on_whoosh_timer_timeout)

	func enter() -> void:
		if mob.chase_sound_component:
			mob.chase_sound_component.play()
		_reset_whoosh_timer()

	func update(_delta: float) -> AI.Events:
		var player: Player = mob.detection_component.get_player()
		if not player:
			return Events.NONE
			
		var dir = (player.global_position - mob.global_position).normalized()
		mob.velocity = dir * speed
		mob.move_and_slide()
		
		if mob.detection_component.close():
			return Events.PLAYER_CLOSE

		return Events.NONE

	func exit() -> void:
		whoosh_timer.stop()

	func _on_whoosh_timer_timeout() -> void:
		if mob.detection_component.detected() and randf() < whoosh_probability:
			mob.chase_sound_component.play()
		_reset_whoosh_timer()

	func _reset_whoosh_timer():
		whoosh_timer.wait_time = randf_range(mob.min_whoosh_interval, mob.max_whoosh_interval)
		if whoosh_timer.is_inside_tree():
			whoosh_timer.start()
			
			
class StateCharge extends State:
	var glow: OmniLight3D
	var original_radius: float
	var original_energy: float
	var charge_duration: float
	var charge_type: ChargeType
	var initial_velocity: Vector3
	var tween: Tween
	var commit_buffer: float = 0.7
	var current_time: float = 0.0
	var has_committed: bool = false

	func _init(init_mob: Shadow, type: ChargeType = ChargeType.UP) -> void:
		super("Charge" + ChargeType.keys()[type], init_mob)
		charge_type = type
		
		glow = mob.get_node("Glow")
		if glow:
			original_radius = glow.omni_range
			original_energy = glow.light_energy
		
		match type:
			ChargeType.UP:
				charge_duration = 0.7
			ChargeType.DOWN:
				charge_duration = randf_range(1.0, 1.5)
			_:
				push_error("Unknown charge type: " + ChargeType.keys()[type])

	func enter() -> void:
		current_time = 0.0
		has_committed = false
		initial_velocity = mob.velocity
		
		if not glow:
			push_error("Glow not defined on enemy")
		
		tween = mob.create_tween()
		tween.set_parallel(true)
		
		match charge_type:
			ChargeType.UP:
				var target_radius = original_radius * 2.0
				var target_energy = original_energy * 3.0
				
				tween.tween_property(glow, "omni_range", target_radius, charge_duration).set_ease(Tween.EASE_OUT)
				tween.tween_property(glow, "light_energy", target_energy, charge_duration).set_ease(Tween.EASE_OUT)
				tween.tween_method(_decelerate_velocity, 1.0, 0.0, charge_duration).set_ease(Tween.EASE_OUT)
				
			ChargeType.DOWN:
				tween.tween_property(glow, "omni_range", original_radius, charge_duration).set_ease(Tween.EASE_OUT)
				tween.tween_property(glow, "light_energy", original_energy, charge_duration).set_ease(Tween.EASE_OUT)
				tween.tween_method(_decelerate_velocity, mob.velocity.length(), 0.0, charge_duration / 2).set_ease(Tween.EASE_OUT)
		
		tween.finished.connect(_on_tween_finished)

	func update(delta: float) -> Events:
		current_time += delta
		mob.move_and_slide()
		
		if (charge_type == ChargeType.UP and not has_committed 
			and charge_duration - current_time <= commit_buffer):
				has_committed = true
				_commit_dash_direction()
		
		return Events.NONE
		
	func _commit_dash_direction():
		if mob.detection_component and mob.detection_component.detected():
			var player = mob.detection_component.get_player()
			mob.dash_dir = (player.global_position - mob.global_position).normalized()
		else:
			mob.dash_dir = mob.transform.basis.z
		
		mob.dash_commit_sound_component.play()
	
	func _decelerate_velocity(factor: float) -> void:
		mob.velocity = initial_velocity.normalized() * factor

	func _on_tween_finished() -> void:
		mob.velocity = Vector3.ZERO
		finished.emit()

	func exit() -> void:
		if tween:
			tween.kill()
		mob.velocity = Vector3.ZERO
		glow.omni_range = original_radius
		glow.light_energy = original_energy		
			
			
class StateDie extends State:
	func _init(init_mob: Shadow) -> void:
		super("Die", init_mob)
		
	func enter() -> void:
		GameManager.enemies_killed += 1
		GameManager.player.health_component.heal(mob.sanity_reward)
		mob.loot_component.drop_loot()	
		_spawn_death_light()
		_kill_players()
		mob.queue_free()
		
		
	func _spawn_death_light():
		if mob.death_light_scene:
			var death_light = mob.death_light_scene.instantiate()
			mob.get_parent().add_child(death_light)
			death_light.global_position = mob.global_position
			death_light.base_y = mob.global_position.y
			
			
	func _kill_players() -> void:
		mob.death_sound_component.play()
		for sound_component in mob.sound_components:
			sound_component.kill()
		
		
class StateDash extends State:
	var dash_duration := 0.2
	var dash_speed := 40.0
	var _time := 0.0

	func _init(init_mob: Shadow) -> void:
		super("Dash", init_mob)

	func enter() -> void:
		mob.dash_sound_component.play()
		mob.dmg = mob.dash_dmg
		_time = 0.0

		mob.velocity = mob.dash_dir * dash_speed

	func update(delta: float) -> Events:
		_time += delta
		mob.move_and_slide()
		if _time >= dash_duration:
			return Events.FINISHED
		return Events.NONE
		
		
	func exit() -> void:
		mob.dmg = mob.regular_dmg
		
		
class StateStagger extends State:
	var knockback_duration := 0.7
	var knockback_decay := 0.95
	var knockback_timer: float

	func _init(init_mob: Shadow) -> void:
		super("Stagger", init_mob)

	func enter() -> void:
		mob.velocity += mob.knockback_impulse
		knockback_timer = knockback_duration
		mob.hit_sound_component.play()

	func update(delta: float) -> Events:
		mob.velocity *= knockback_decay
		knockback_timer -= delta
		mob.move_and_slide()
		if knockback_timer <= 0:
			return Events.FINISHED
		return Events.NONE
		
