extends Node3D
class_name DetectionComponent

signal player_entered_range(player: Player) # Entered area
signal player_exited_range(player: Player) # Exited area  
signal player_spotted(player: Player) # Saw player in area (any time)
signal player_first_spotted(player: Player) # Saw player for the first time
signal player_lost(player: Player) # Exited line of sight
signal player_close(player: Player) # In close proximity AND visible
signal player_left_close(player: Player) # No longer in close proximity OR no longer visible

@export var detection_area: Area3D
@export var close_area: Area3D
@export var owner_body: Node3D

var player: Player = null
var can_see_player := false
var has_spotted_player := false
var player_in_close_area := false
var was_player_close := false

func _ready():
	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_entered)
		detection_area.body_exited.connect(_on_detection_area_exited)
	if close_area:
		close_area.body_entered.connect(_on_close_area_entered)
		close_area.body_exited.connect(_on_close_area_exited)

func _physics_process(_delta: float) -> void:
	if not player: 
		return
	_check_line_of_sight()
	_check_player_close_state()  

func _on_detection_area_entered(body: Node3D):
	if body is Player:
		player = body
		has_spotted_player = false
		player_entered_range.emit(player)

func _on_detection_area_exited(body: Node3D):
	if body is Player:
		player_exited_range.emit(player)
		player = null
		can_see_player = false
		has_spotted_player = false
		player_in_close_area = false
		
		if was_player_close:
			was_player_close = false
			player_left_close.emit(body)

func _on_close_area_entered(body: Node3D):
	if body is Player:
		player_in_close_area = true
		_check_player_close_state()

func _on_close_area_exited(body: Node3D):
	if body is Player:
		player_in_close_area = false
		_check_player_close_state()

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
		if not has_spotted_player:
			has_spotted_player = true
			player_first_spotted.emit(player)
		_check_player_close_state()
	elif not can_see and can_see_player:
		can_see_player = false
		player_lost.emit(player)
		_check_player_close_state()

func _check_player_close_state():
	var is_player_close_now = player_in_close_area and can_see_player
	
	
	if is_player_close_now and not was_player_close:
		player_close.emit(player)
		was_player_close = true
	
	elif not is_player_close_now and was_player_close:
		player_left_close.emit(player)
		was_player_close = false
		
		
func detected() -> bool:
	return player != null and can_see_player
	
	
func close() -> bool:
	return player != null and player_in_close_area and can_see_player
	
	
func get_player() -> Player:
	return player
