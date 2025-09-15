extends RichTextLabel

func _process(_delta: float) -> void:
	text = "Shards Collected: " + str(GameManager.current_run_currency)
