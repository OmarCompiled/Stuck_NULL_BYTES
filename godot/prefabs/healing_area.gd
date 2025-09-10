extends Area3D

signal room_health_depleted()

@onready var light = $"../OmniLight3D"

var player;

var is_healing = false
var room_health = 50
const HEAL_PER_SECOND = 50

func _process(delta):		
	if is_healing and player:
		_heal(delta)
		
func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		player = body
		player.is_losing_sanity = false
		is_healing = true
		
		
		
func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		player.is_losing_sanity = true
		is_healing = false


func _heal(delta) -> void:
		var needed_health = player.health_component.max_health - player.health_component.current_health 
		var health = min(HEAL_PER_SECOND * delta, room_health, needed_health)
		player.health_component.heal(health)
		room_health -= health
		if room_health <= 0:
			_deplete_room()
			
			
func _deplete_room() -> void:
		player.is_losing_sanity = true
		is_healing = false
		body_entered.disconnect(_on_body_entered)
		body_exited.disconnect(_on_body_exited)
		room_health_depleted.emit()
		
