@tool
extends Area3D

@export var angle: float = 45.0:
	set(value):
		angle = clamp(value, 1.0, 179.9)
		update_configuration_warnings()
		if Engine.is_editor_hint():
			update_cone()

@warning_ignore("shadowed_global_identifier")
@export var range: float = 5.0:
	set(value):
		range = max(value, 0.1)
		update_configuration_warnings()
		if Engine.is_editor_hint():
			update_cone()

@export var points: int = 12:
	set(value):
		points = max(value, 3)
		if Engine.is_editor_hint():
			update_cone()

@onready var col_shape: CollisionShape3D = $Cone
@onready var spot_light: SpotLight3D = $SpotLight3D

func _ready():
	if Engine.is_editor_hint():
		update_cone()
	else:
		update_cone()


func _get_configuration_warnings():
	var warnings = []
	if not col_shape:
		warnings.append("Missing CollisionShape3D child node named 'Cone'")
	if not spot_light:
		warnings.append("Missing SpotLight3D child node")
	return warnings
	
	
func update_cone():
	if not col_shape or not spot_light:
		return

	var radius = range * tan(deg_to_rad(angle / 2.0))
	
	# NOTE: Decreased due to the stupid nature of spotlights.
	spot_light.spot_range = range / 12
	spot_light.spot_angle = angle / 2
	

	var shape = ConvexPolygonShape3D.new()
	shape.points = generate_conic_points(range, radius, points)
	col_shape.shape = shape
	
	
func generate_conic_points(_range: float, _radius: float, _points: int) -> PackedVector3Array:
	var verts = PackedVector3Array()
	var angle_step = TAU / _points
	var tip = Vector3(0, 0, 0)

	verts.append(tip)
	
	for i in range(_points):
		var _angle = i * angle_step
		var x = cos(_angle) * _radius
		var y = sin(_angle) * _radius
		verts.append(Vector3(x, y, -_range))
	
	return verts
