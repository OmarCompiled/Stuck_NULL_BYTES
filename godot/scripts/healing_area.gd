extends Area3D

signal room_health_depleted()

@export var heal_sound_component: SoundComponent

var player: Player
var enemies: Array[Shadow] = []
var is_healing = false
var room_health = 50
const HEAL_PER_SECOND = 50
var can_play_sound: bool = true

func _process(delta):		
	if is_healing and player:
		_heal(delta)
	
	_damage_enemies(delta)
		
		
func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		_handle_player_entered(body)
	elif body is Shadow:
		enemies.append(body)
		
		
func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		_handle_player_exited(body)
	elif body is Shadow:
		enemies.erase(body)
		
		
func _handle_player_entered(player_body: Player) -> void:
	player = player_body
	player.is_losing_sanity = false
	is_healing = true
	if can_play_sound:
		heal_sound_component.play()
		can_play_sound = false
		await get_tree().create_timer(30.0).timeout
		can_play_sound = true
	
	
func _handle_player_exited(player_body: Player) -> void:
	player_body.is_losing_sanity = true
	is_healing = false
	
	
func _heal(delta) -> void:
	var needed_health = player.health_component.max_health - player.health_component.current_health 
	if needed_health <= 0: return
	var health = _calculate_transfer_amount(HEAL_PER_SECOND * delta, needed_health)
	player.health_component.heal(health)
	_consume_room_health(health)
			
			
func _damage_enemies(delta) -> void:
	for enemy in enemies:
		if is_instance_valid(enemy):
			var damage = _calculate_transfer_amount(HEAL_PER_SECOND * delta / 4, enemy.health_component.current_health)
			enemy.health_component.take_damage(damage)
			_consume_room_health(damage)
			
			
func _calculate_transfer_amount(target: float, target_limit: float) -> float:
	return min(target, target_limit, room_health)
	
	
func _consume_room_health(amount: float) -> void:
	room_health -= amount
	if room_health <= 0:
		_deplete_room_health()
		
		
func _deplete_room_health() -> void:
	room_health_depleted.emit()
	heal_sound_component.play(0.45, 0.45)
	queue_free()
	
