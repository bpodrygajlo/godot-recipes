tool
extends Node2D

export var angle : int = 0 setget _set_angle
export var tangle : float = 2

func _set_angle(new_angle):
	var new_pos = position
	var normal_vector = Vector2.DOWN.rotated(deg2rad(angle))
	var spacing = 70
	var p0 = position
	var p1 = position + Vector2.DOWN * spacing * get_child_count() / tangle
	var p2 = position + (Vector2.DOWN * spacing * get_child_count()).rotated(deg2rad(angle))
	var i = 0.0
	for sprite in get_children():
		sprite.position = _quadratic_bezier(p0, p1, p2, i / get_child_count() )
		i += 1.0
		
	var prev_sprite : Sprite = null
	for sprite in get_children():
		if prev_sprite == null:
			prev_sprite = sprite
			continue
		prev_sprite.rotation = PI/2 + prev_sprite.position.angle_to_point(sprite.position)
		prev_sprite = sprite
	angle = new_angle
		
func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	var r = q0.linear_interpolate(q1, t)
	return r
