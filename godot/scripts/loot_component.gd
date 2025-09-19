extends Node
class_name LootComponent

@export var loot_table: Array[LootItem] = []
@export var global_spawn_offset: Vector3 = Vector3(0, 0.5, 0)
@export var global_random_spread: float = 1.0

func drop_loot():
	if loot_table.is_empty():
		return
		
	for loot_item in loot_table:
		if randf() <= loot_item.chance:
			var count = randi_range(loot_item.min_drop, loot_item.max_drop)
			for i in range(count):
				var item = loot_item.item_scene.instantiate()
				get_parent().get_parent().add_child(item)
				
				var spawn_position = get_parent().global_position
				spawn_position += global_spawn_offset + loot_item.spawn_offset
				
				var spread = loot_item.random_spread if loot_item.random_spread > 0 else global_random_spread
				spawn_position += Vector3(
					randf_range(-spread, spread),
					0,
					randf_range(-spread, spread)
				)
				
				item.global_position = spawn_position
