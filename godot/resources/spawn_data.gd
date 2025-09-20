class_name SpawnerData extends Resource

@export_range(0, 1) var overall_spawn_probability: float = 1.0
@export var spawn_offset_range: Vector3 = Vector3.ZERO
@export var entities: Array[SpawnEntityData] = []

# Validate sum = 1
func validate_probabilities() -> bool:
	var total: float = 0.0
	for entity_data in entities:
		total += entity_data.spawn_probability
	
	return abs(total - 1.0) < 0.001 # Allow small error
