extends Node3D
class_name DetectionComponent

signal player_entered_range(player) # Entered area
signal player_exited_range(player) # Exited area
signal player_spotted(player) # Saw player in area
signal player_lost(player) # Exited area or line of sight
signal player_close(player) # In close proximity

@export var detection_area: Area3D
@export var close_area: Area3D
@export var owner_body: Node3D

var player: Player = null
var can_see_player := false

func _ready():
	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_entered)
		detection_area.body_exited.connect(_on_detection_area_exited)
	if close_area:
		close_area.body_entered.connect(_on_close_area_entered)

func _physics_process(_delta: float) -> void:
	if not player: 
		return
	_check_line_of_sight()

func _on_detection_area_entered(body: Node3D):
	if body is Player:
		player = body
		player_entered_range.emit(player)

func _on_detection_area_exited(body: Node3D):
	if body == player:
		player_exited_range.emit(player)
		player_lost.emit(player)
		player = null
		can_see_player = false

func _on_close_area_entered(body: Node3D):
	if body is Player and can_see_player:
		player_close.emit(body)

func _check_line_of_sight():
	if not player:
		return
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(owner_body.global_position, player.global_position)
	query.exclude = [owner_body]
	var result = space_state.intersect_ray(query)

	var can_see = result.is_empty() or result.collider == player
	if can_see and not can_see_player:
		can_see_player = true
		player_spotted.emit(player)
	elif not can_see and can_see_player:
		can_see_player = false
		player_lost.emit(player)

func detected() -> bool:
	return player != null and can_see_player

func get_player() -> Player:
	return player
