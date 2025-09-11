extends Area3D

signal room_health_depleted()

var player;

var is_healing = false
var room_health = 50
const HEAL_PER_SECOND = 50

func _process(delta):		
	if is_healing and player:
		_heal(delta)
		
func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		player = body
		player.is_losing_sanity = false
		is_healing = true
	elif body is Shadow:
		body.queue_free()
		
		
func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		player.is_losing_sanity = true
		is_healing = false


func _heal(delta) -> void:
		var needed_health = player.health_component.max_health - player.health_component.current_health 
		var health = min(HEAL_PER_SECOND * delta, room_health, needed_health)
		player.health_component.heal(health)
		room_health -= health
		if room_health <= 0:
			_deplete_room_health()
			
			
func _deplete_room_health() -> void:
		room_health_depleted.emit()
		queue_free()
