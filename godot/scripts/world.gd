extends Node

@export var generator_scene: PackedScene
var generator

func _ready() -> void:
	_generate()
	
	$FadeTransition.show()	
	$FadeTransition/AnimationPlayer.play("fade_out")
	$FadeTransition/fade_timer.start()
	
	SanityEffectsManager.find_sanity_overlay()
	HitEffectsManager.find_hit_overlay()
	HealEffectsManager.find_heal_overlay()
	
	InputManager.can_quit = true
	
	
func _on_fade_timer_timeout() -> void:
	$FadeTransition.hide()


func _generate():
	generator = generator_scene.instantiate()
	add_child(generator)
	# NOTE: Without call deferred, the generator runs before some
	# data from the old scene is freed.
	generator.generate.call_deferred()
