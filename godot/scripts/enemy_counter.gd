extends RichTextLabel

func _process(_delta: float) -> void:
	# NOTE: Only require a fraction of the enemies to be killed,
	# since killing 100% is too difficult without a map.
	var to_kill = int(GameManager.total_enemies / 3)
	text = "Shadows Killed: " + str(GameManager.enemies_killed) + "/" + str(to_kill)
	
	if (GameManager.enemies_killed == to_kill):
		GameManager.handle_player_win()
