class_name Shadow extends CharacterBody3D

@onready var mesh_instance = $MeshInstance3D
var material: Material
var original_color: Color
var tween: Tween
var tween_duration: float = 0.1

func _ready():
	GameManager.total_enemies += 1
	mesh_instance.material_override = mesh_instance.material_override.duplicate()
	material = mesh_instance.material_override
	original_color = material.albedo_color

func set_highlighted(highlight: bool):
	if tween:
		tween.kill()
	
	tween = create_tween()
	
	var new_v = original_color.v * 2.5
	var target_color: Color = Color.from_hsv(original_color.h, original_color.s, new_v)
	
	if highlight:
		tween.tween_property(material, "albedo_color", target_color, tween_duration)
		
	else:
		tween.tween_property(material, "albedo_color", original_color, tween_duration)
	
