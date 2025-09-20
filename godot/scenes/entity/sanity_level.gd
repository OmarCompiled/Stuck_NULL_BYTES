extends RichTextLabel

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	text = "Sanity: " + str(int($"..".value)) + "/" + str(int(GameManager.player.health_component.max_health))
