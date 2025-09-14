extends Node

func _ready() -> void:
	$"..".connect("dungeon_done_generating", remove_unused_doors)

func remove_unused_doors():
	for door in $"..".get_doors():
		if door.get_room_leads_to() == null:
			door.door_node.queue_free()
