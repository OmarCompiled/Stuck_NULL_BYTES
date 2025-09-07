extends Node3D

@export_range(0,1) var spawn_probability: float = 0.5
@export var entity_scene: PackedScene

func _ready() -> void:
	get_parent().connect("dungeon_done_generating", _spawn_entity)

func _spawn_entity():
	if randf() < spawn_probability and entity_scene:
		GameManager.total_enemies += 1
		var entity = entity_scene.instantiate()
		get_parent().add_child(entity)
		if entity is Node3D:
			entity.global_position = global_position
