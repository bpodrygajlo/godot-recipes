tool
extends KinematicBody2D
class_name BridgeSegment

var target_position : Vector2 = position
var target_rotation : float = rotation
var is_bent = false
var bent_offset = 50

func set_target_position(pos):
	target_position = pos

func set_target_rotation(rot):
	target_rotation = rot

func _physics_process(delta):
	if not is_bent:
		position = lerp(position, target_position, delta * 5)
	else:
		var body = $Area2D.get_overlapping_bodies()[0]
		var dist = abs(body.global_position.x - global_position.x)
		var weight = range_lerp(dist, 0, 100, 1, 0.5)
		position = lerp(position, target_position + Vector2(0, bent_offset * weight), delta * 5)
		position = Vector2(int(position.x), int(position.y))
	rotation = lerp_angle(rotation, target_rotation, delta * 10)

func _on_Area2D_body_entered(body):
	is_bent = true

func _on_Area2D_body_exited(body):
	is_bent = false
