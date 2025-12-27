extends Node3D

@export var open_angle = 90.0
@export var speed = 3.0

@onready var chime = $Chime

var target_angle = 0.0

func _physics_process(delta):
	rotation_degrees.y = lerp(rotation_degrees.y, target_angle, speed * delta)

func _on_area_3d_body_entered(body):
	if body.name == "Player":
		chime.play()
		var player_forward = -body.global_transform.basis.z
		var door_forward = -global_transform.basis.z
		var side = player_forward.dot(door_forward)
		
		if side > 0:
			target_angle = -open_angle
		else:
			target_angle = open_angle

func _on_area_3d_body_exited(body):
	if is_instance_valid(body):
		if body.name == "Player":
			target_angle = 0.0
