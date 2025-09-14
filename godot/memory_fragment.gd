extends CharacterBody3D
class_name Collectible

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

func _on_shard_hitbox_area_entered(area: Area3D) -> void:
	if area.get_parent() is Player:
		GameManager.currency += 1
		queue_free()
