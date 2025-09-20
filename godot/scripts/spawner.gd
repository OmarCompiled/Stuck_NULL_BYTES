extends Node3D

@export var spawner_data: SpawnerData

func _ready() -> void:
	get_parent().connect("dungeon_done_generating", _spawn_entity)

func _spawn_entity():
	if not spawner_data:
		push_error("SpawnerData resource not assigned!")
		return
	
	if randf() >= spawner_data.overall_spawn_probability:
		return
	
	if not spawner_data.validate_probabilities():
		push_error("Entity probabilities greater than 1")
		return
	
	var selected_entity_data: SpawnEntityData = _select_entity_by_probability()
	
	if selected_entity_data and selected_entity_data.entity_scene:
		var entity = selected_entity_data.entity_scene.instantiate()
		get_parent().add_child(entity)
		
		if entity is Node3D:
			entity.global_position = global_position + Vector3(
				spawner_data.spawn_offset_range.x * randf_range(-1, 1),
				spawner_data.spawn_offset_range.y * randf_range(-1, 1),
				spawner_data.spawn_offset_range.z * randf_range(-1, 1)
			)

func _select_entity_by_probability() -> SpawnEntityData:
	var random_value := randf()
	var cumulative_probability := 0.0
	
	for entity_data in spawner_data.entities:
		cumulative_probability += entity_data.spawn_probability
		if random_value <= cumulative_probability:
			return entity_data
	
	return spawner_data.entities.back() if spawner_data.entities.size() > 0 else null
