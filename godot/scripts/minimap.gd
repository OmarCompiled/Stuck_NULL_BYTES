extends Control

@export var dungeon_generator : DungeonGenerator3D
@export var room_size_pixels : Vector2 = Vector2(16, 16)
@export var room_color : Color = Color(0.8, 0.8, 0.8)
@export var border_color : Color = Color(0, 0, 0)
@export var border_width : float = 2.0
@export var background_color : Color = Color(0.1, 0.1, 0.1, 0.7)
@export var player_arrow_color : Color = Color.WHITE
@export var player_arrow_size : float = 8.0


@export var flip_door_z_axis: bool = false
@export var flip_door_x_axis: bool = false

@export var door_cell_fraction: float = 0.6  

var _room_icons := []
var player: Node3D
var _player_room: DungeonRoom3D = null
var _player_camera: Camera3D = null

@export var room_colors: Array = [
	{"key": "ChestRoom", "color": Color(0.9, 0.7, 0.2)},
	{"key": "HealingRoom", "color": Color(0.2, 0.8, 0.2)},
	{"key": "BigRoom", "color": Color(0.6, 0.1, 0.1)},
	{"key": "Corridor", "color": Color(0.4, 0.4, 0.4)},
	{"key": "StairRoom", "color": Color(0.5, 0.2, 0.7)},
	{"key": "EntranceRoom", "color": Color(0.261, 0.033, 0.451, 1.0)}
]

var color_map: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	color_map.clear()
	for entry in room_colors:
		if entry.has("key") and entry.has("color"):
			color_map[entry["key"]] = entry["color"]

	var background = ColorRect.new()
	background.color = background_color
	background.size = size
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.name = "Background"
	add_child(background)
	move_child(background, 0)

	resized.connect(_on_resized)


func _on_resized() -> void:
	var background = get_node("Background")
	if background:
		background.size = size


func update() -> void:
	_update_minimap()
	_ensure_control_size_once()
	_anchor_top_right()


func init_minimap(generator: DungeonGenerator3D) -> void:
	dungeon_generator = generator


func _ensure_control_size_once() -> void:
	if not dungeon_generator:
		return
	var dsize = dungeon_generator.dungeon_size
	var total_pixels = Vector2(dsize.x, dsize.z) * room_size_pixels
	size = total_pixels
	pivot_offset = size * 0.5


func _anchor_top_right(padding_top: float = 47.0, padding_right: float = 83.0) -> void:
	anchor_left = 1.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 0.0

	offset_left = -size.x - padding_right
	offset_top = padding_top
	offset_right = -padding_right
	offset_bottom = size.y + padding_top


func _update_minimap():
	player = GameManager.player

	if player and not _player_camera:
		_find_player_camera()

	for icon in _room_icons:
		if is_instance_valid(icon):
			icon.queue_free()
	_room_icons.clear()
	_player_room = null

	if not dungeon_generator or not player:
		return

	var player_grid_pos = world_to_dungeon_grid(player.global_position)
	var player_floor_y = player_grid_pos.y

	_player_room = _find_room_containing_gridpos(player_grid_pos)

	if _player_room:
		_player_room.visited = true

	for room in dungeon_generator._rooms_placed:
		var room_aabbi = room.get_grid_aabbi(false)
		if room_aabbi.position.y <= player_floor_y and player_floor_y < room_aabbi.position.y + room_aabbi.size.y:
			if room.visited:
				_draw_room(room)

	_draw_player_direction()


func _find_player_camera():
	if player.has_node("Head"):
		var head = player.get_node("Head")
		if head and head.has_node("Camera3D"):
			_player_camera = head.get_node("Camera3D")

	if not _player_camera:
		for child in player.get_children():
			if child is Camera3D:
				_player_camera = child
				return
			elif child.has_node("Camera3D"):
				_player_camera = child.get_node("Camera3D")
				return
				
				
func _find_room_containing_gridpos(grid_pos: Vector3i) -> DungeonRoom3D:
	if not dungeon_generator:
		return null
	for room in dungeon_generator._rooms_placed:
		var aabbi = room.get_grid_aabbi(false)
		if aabbi.contains_point(grid_pos):
			return room
	return null


func world_to_dungeon_grid(world_pos: Vector3) -> Vector3i:
	if not dungeon_generator:
		return Vector3i.ZERO

	var local_pos = world_pos - dungeon_generator.global_transform.origin
	var scaled_pos = local_pos / dungeon_generator.voxel_scale
	var grid_pos = scaled_pos + Vector3(dungeon_generator.dungeon_size) / 2.0
	return Vector3i(grid_pos.floor())


func _draw_room(room: DungeonRoom3D) -> void:
	var grid_pos := room.get_grid_pos()
	var grid_size := room.get_grid_aabbi(false).size

	var top_left := Vector2(grid_pos.x, grid_pos.z) * room_size_pixels
	var pixel_size := Vector2(grid_size.x, grid_size.z) * room_size_pixels
	
	var fill_color = get_color_for_room_name(room.name)
	var room_rect := ColorRect.new()
	room_rect.color = fill_color
	room_rect.position = top_left
	room_rect.size = pixel_size
	add_child(room_rect)
	_room_icons.append(room_rect)
	
	_draw_room_border_with_doors(top_left, pixel_size, room)

func _draw_room_border_with_doors(top_left: Vector2, pixel_size: Vector2, room: DungeonRoom3D) -> void:
	var border_thickness = border_width
	
	var top_p1 = top_left
	var top_p2 = top_left + Vector2(pixel_size.x, 0)
	var bottom_p1 = top_left + Vector2(0, pixel_size.y)
	var bottom_p2 = top_left + Vector2(pixel_size.x, pixel_size.y)
	var left_p1 = top_left
	var left_p2 = top_left + Vector2(0, pixel_size.y)
	var right_p1 = top_left + Vector2(pixel_size.x, 0)
	var right_p2 = top_left + Vector2(pixel_size.x, pixel_size.y)

	var sides = [ [top_p1, top_p2], [bottom_p1, bottom_p2], [left_p1, left_p2], [right_p1, right_p2] ]
	for seg in sides:
		var line = Line2D.new()
		line.width = border_thickness
		line.default_color = border_color
		line.points = [ seg[0], seg[1] ]
		add_child(line)
		_room_icons.append(line)

	var cell_w = room_size_pixels.x
	var cell_h = room_size_pixels.y
	
	for door in room.get_doors():
		
		if door.local_pos == null:
			continue
		
		var exit_vec = Vector3i(door.exit_pos_grid) - Vector3i(door.grid_pos)
		
		if flip_door_x_axis:
			exit_vec.x = -exit_vec.x
		if flip_door_z_axis:
			exit_vec.z = -exit_vec.z
			
		var cell_cx = top_left.x + (float(door.local_pos.x) + 0.5) * cell_w
		var cell_cy = top_left.y + (float(door.local_pos.z) + 0.5) * cell_h
		
		var door_len_h = min(cell_w * door_cell_fraction, cell_w - border_thickness)
		var door_len_v = min(cell_h * door_cell_fraction, cell_h - border_thickness)

		var p1 := Vector2.ZERO
		var p2 := Vector2.ZERO

		if exit_vec.x > 0:
			p1 = Vector2(top_left.x + pixel_size.x, cell_cy - door_len_v * 0.5)
			p2 = Vector2(top_left.x + pixel_size.x, cell_cy + door_len_v * 0.5)
		elif exit_vec.x < 0:
			p1 = Vector2(top_left.x, cell_cy - door_len_v * 0.5)
			p2 = Vector2(top_left.x, cell_cy + door_len_v * 0.5)
		elif exit_vec.z > 0:
			p1 = Vector2(cell_cx - door_len_h * 0.5, top_left.y + pixel_size.y)
			p2 = Vector2(cell_cx + door_len_h * 0.5, top_left.y + pixel_size.y)
		elif exit_vec.z < 0:
			p1 = Vector2(cell_cx - door_len_h * 0.5, top_left.y)
			p2 = Vector2(cell_cx + door_len_h * 0.5, top_left.y)
		else:
			var is_front = door.dir == DungeonUtils.Direction.FRONT
			var is_back  = door.dir == DungeonUtils.Direction.BACK
			var is_left  = door.dir == DungeonUtils.Direction.LEFT
			var is_right = door.dir == DungeonUtils.Direction.RIGHT
			if flip_door_z_axis:
				var tmp_z = is_front; is_front = is_back; is_back = tmp_z
			if flip_door_x_axis:
				var tmp_x = is_left; is_left = is_right; is_right = tmp_x

			if is_front:
				p1 = Vector2(cell_cx - door_len_h * 0.5, top_left.y)
				p2 = Vector2(cell_cx + door_len_h * 0.5, top_left.y)
			elif is_back:
				p1 = Vector2(cell_cx - door_len_h * 0.5, top_left.y + pixel_size.y)
				p2 = Vector2(cell_cx + door_len_h * 0.5, top_left.y + pixel_size.y)
			elif is_left:
				p1 = Vector2(top_left.x, cell_cy - door_len_v * 0.5)
				p2 = Vector2(top_left.x, cell_cy + door_len_v * 0.5)
			elif is_right:
				p1 = Vector2(top_left.x + pixel_size.x, cell_cy - door_len_v * 0.5)
				p2 = Vector2(top_left.x + pixel_size.x, cell_cy + door_len_v * 0.5)
			else:

				p1 = Vector2(cell_cx - door_len_h * 0.5, cell_cy)
				p2 = Vector2(cell_cx + door_len_h * 0.5, cell_cy)

		var door_color = get_color_for_room_name(room.name)
		var door_line = Line2D.new()
		door_line.width = border_thickness
		door_line.default_color = door_color
		door_line.points = [ p1, p2 ]
		add_child(door_line)
		_room_icons.append(door_line)

func _draw_player_direction():
	if not _player_camera or not _player_room:
		return

	var player_forward = -_player_camera.global_transform.basis.z
	var player_forward_2d = Vector2(player_forward.x, player_forward.z).normalized()

	var room_aabbi = _player_room.get_grid_aabbi(false)
	var room_center_grid = Vector2(
		room_aabbi.position.x + room_aabbi.size.x / 2.0,
		room_aabbi.position.z + room_aabbi.size.z / 2.0
	)
	var player_minimap_pos = room_center_grid * room_size_pixels

	var arrow_tip = player_minimap_pos + player_forward_2d * player_arrow_size
	var arrow_left = player_minimap_pos + player_forward_2d.rotated(deg_to_rad(140)) * player_arrow_size * 0.6
	var arrow_right = player_minimap_pos + player_forward_2d.rotated(deg_to_rad(-140)) * player_arrow_size * 0.6

	var arrow = Line2D.new()
	arrow.width = 2.0
	arrow.default_color = player_arrow_color
	arrow.points = [arrow_tip, arrow_left, arrow_tip, arrow_right]
	arrow.closed = false
	add_child(arrow)
	_room_icons.append(arrow)


func get_color_for_room_name(room_name: String) -> Color:
	for key in color_map.keys():
		if room_name.begins_with(key):
			return color_map[key]
	return room_color
