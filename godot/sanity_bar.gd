extends ProgressBar

@export var invincible_color: Color = Color(1.2, 1.2, 1.2)
@export var normal_color: Color = Color(1, 1, 1, 1)

func _ready():
	self_modulate = normal_color

func _on_invincibility_started():
	self_modulate = invincible_color

func _on_invincibility_ended():
	self_modulate = normal_color
	
func _on_health_changed(new_health: Variant) -> void:
	value = new_health
