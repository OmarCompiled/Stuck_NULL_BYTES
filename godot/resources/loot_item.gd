class_name LootItem extends Resource

@export var item_scene: PackedScene
@export_range(0.0, 1.0) var chance: float = 0.5
@export var min_drop: int = 1
@export var max_drop: int = 1
@export var spawn_offset: Vector3 = Vector3.ZERO
@export var random_spread: float = 1.0
