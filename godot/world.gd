extends Node

@export var generator_scene: PackedScene

func _ready() -> void:
	var generator = generator_scene.instantiate()
	add_child(generator)
	generator.generate.call_deferred()
