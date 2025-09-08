extends RichTextLabel

func _process(_delta: float) -> void:
	# NOTE: Only require half the enemies to be killed,
	# since killing 100% is too difficult without a map.
	var to_kill = GameManager.total_enemies / 2
	text = "Kills: " + str(GameManager.enemies_killed) + "/" + str(to_kill)
	if (GameManager.enemies_killed == to_kill):
		GameManager.end_game()
