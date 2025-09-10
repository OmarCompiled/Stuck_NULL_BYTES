extends Area3D

var player;
var is_healing = false
const HEAL_PER_SECOND = 20

func _process(delta):
	if is_healing and player:
		player.health_component.heal(HEAL_PER_SECOND * delta)


func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		player = body
		is_healing = true


func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		is_healing = false
