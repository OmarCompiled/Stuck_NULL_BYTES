class_name Shadow extends CharacterBody3D

@onready var mesh_instance = $MeshInstance3D

var material: Material
var original_color: Color
var tween: Tween
var tween_duration: float = 0.1

@export var max_brightness: float = 0.5
@export var min_brightness: float = 0.3

func _ready():
	GameManager.total_enemies += 1
	mesh_instance.material_override = mesh_instance.material_override.duplicate()
	material = mesh_instance.material_override
	original_color = material.albedo_color

func update_brightness_from_health(health_percentage: float):
	var health_percent := 1 - health_percentage
	var target_v: float = lerp(min_brightness, max_brightness, health_percent)
	target_v = clamp(target_v, 0.0, 1.0)

	var target_color: Color = Color.from_hsv(original_color.h, original_color.s, target_v, original_color.a)

	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(material, "albedo_color", target_color, tween_duration)
