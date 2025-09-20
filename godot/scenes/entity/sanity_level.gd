extends RichTextLabel

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	text = "Sanity: " + str(int($"..".value)) + "/" + str(int(UpgradesManager.upgrades.Sanity))
