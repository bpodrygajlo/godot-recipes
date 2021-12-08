tool
extends Sprite

var target_position : Vector2 = position
var target_rotation : float = rotation

func set_target_position(pos):
	target_position = pos

func set_target_rotation(rot):
	target_rotation = rot

func _physics_process(delta):
	position = lerp(position, target_position, delta * 5)
	rotation = lerp_angle(rotation, target_rotation, delta * 10)
