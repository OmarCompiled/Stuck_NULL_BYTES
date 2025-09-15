extends OmniLight3D

# The time it takes the room's light to turn off
@export var dimming_seconds = 1
var tween: Tween

func _on_healing_area_room_health_depleted() -> void:
	tween = create_tween()
	tween.tween_property(self, "light_energy", 0.0, dimming_seconds)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.finished.connect(queue_free)
