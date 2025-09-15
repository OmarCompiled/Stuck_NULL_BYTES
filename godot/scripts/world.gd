extends Node

@export var generator_scene: PackedScene

func _ready() -> void:
	$FadeTransition.show()	
	$FadeTransition/AnimationPlayer.play("fade_out")
	$FadeTransition/fade_timer.start()
	
	var generator = generator_scene.instantiate()
	add_child(generator)
	# NOTE: Without call deferred, the generator runs before some
	# data from the old scene is freed.
	generator.generate.call_deferred()
	
	SanityEffectsManager.find_sanity_overlay()
	HitEffectsManager.find_hit_overlay()
	HealEffectsManager.find_heal_overlay()
	
	
func _on_fade_timer_timeout() -> void:
	$FadeTransition.hide()
