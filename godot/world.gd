extends Node

@export var generator_scene: PackedScene

func _ready() -> void:
	var generator = generator_scene.instantiate()
	add_child(generator)
	# NOTE: Without call deferred, the generator runs before some
	# data from the old scene is freed.
	generator.generate.call_deferred()
