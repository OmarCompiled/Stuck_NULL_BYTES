class_name SoundComponent
extends Node

@export var player: AudioStreamPlayer3D
@export var min_pitch: float = 1.0
@export var max_pitch: float = 1.0
@export var min_volume: float = 0.0
@export var max_volume: float = 0.0


func _ready():
	if not player:
		push_error("SoundComponent: No player provided!")
		return
			
func play(
	_min_pitch: float = min_pitch, 
	_max_pitch: float = max_pitch, 
	_min_volume: float = min_volume, 
	_max_volume: float = max_volume, 
	_stop: bool = true
):
	if not player.is_inside_tree():
		return

	if _stop:
		player.stop()
		
	player.pitch_scale = randf_range(_min_pitch, _max_pitch)
	player.volume_db = randf_range(_min_volume, _max_volume)
	
	player.play()
	
	
func stop():
	player.stop()
	
	
func connect_finished(callable: Callable):
	player.finished.connect(callable)
	
	
func kill(wait: bool = true, kill_component: bool = true) -> void:
	if wait and player.playing:
		player.reparent(get_tree().current_scene)
		connect_finished(player.queue_free)
	else:
		player.queue_free()
		
	if kill_component: queue_free()
