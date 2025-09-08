extends Node3D

@export_range(0,1) var spawn_probability: float = 1
@export var spawn_offset_range: Vector3 = Vector3.ZERO
@export var entity_scene: PackedScene

func _ready() -> void:
	get_parent().connect("dungeon_done_generating", _spawn_entity)

func _spawn_entity():
	if randf() < spawn_probability and entity_scene:
		var entity = entity_scene.instantiate()
		get_parent().add_child(entity)
		if entity is Node3D:
			# Add offset to get varied positions
			entity.global_position = global_position + Vector3(
				spawn_offset_range.x * randf(),
				spawn_offset_range.y * randf(),
				spawn_offset_range.z * randf()
			)
