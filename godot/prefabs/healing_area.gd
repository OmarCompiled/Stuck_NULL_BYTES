extends Area3D

signal health_depleted()

@onready var light = $"../OmniLight3D"

var player;

var is_healing = false
var room_health = 100
const HEAL_PER_SECOND = 20

func _process(delta):
	if is_healing and room_health <= 0:
		is_healing = false
		body_entered.disconnect(_on_body_entered)
		body_exited.disconnect(_on_body_exited)
		health_depleted.emit()
		
	if is_healing and player:
		var health = min(HEAL_PER_SECOND * delta, room_health)
		player.health_component.heal(health)
		room_health -= health
		
		
func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		player = body
		is_healing = true
		
		
func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		is_healing = false
