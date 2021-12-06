tool
extends Node2D

export var angle : int = 0 setget _set_angle

# tangling factor
export var tangle : float = 2 setget _set_tangle

# distance between rope nodes
export var spacing : float = 70 setget _set_spacing

# determines animation precision
export var nr_of_segments : int = 40 setget _set_nr_of_segments

# to draw debug information
export var debug = false setget _set_debug

# quadratic bezier points
var point0 : Vector2
var point1 : Vector2
var point2 : Vector2

var segment_borders = null

# sets all children positions to be equal length on a bezier curve
func _set_angle(new_angle):
	point0 = position
	point1 = position + Vector2.DOWN * spacing * get_child_count() / tangle
	point2 = position + (Vector2.DOWN * spacing * get_child_count()).rotated(deg2rad(angle))
	
	segment_borders = [{"pos": position, "length" : 0}]
	var total_len = 0
	var prev_point = _quadratic_bezier(point0, point1, point2, 0)
	for i in range(1, nr_of_segments + 1):
		var point = _quadratic_bezier(point0, point1, point2, float(i) / nr_of_segments)
		var dist = (point - prev_point).length()
		total_len += dist
		segment_borders.append({"length": total_len, "pos": point})
		prev_point = point

	var curve_len = segment_borders[nr_of_segments - 1]["length"]
	
	# we need to position only n - 1 segments ( node 0 is at start position )
	var segment_length = curve_len / (get_child_count() - 1)
	
	if debug:
		update()
	var segment_index = 0
	for i in range(1, get_child_count()):
		var arc_length = i * segment_length
		
		# find the point that is on the curve in front of our desired position
		while segment_borders[segment_index]["length"] <= arc_length:
			segment_index += 1
		
		# interpolate between the two points
		var p1 : Vector2 = segment_borders[segment_index-1]["pos"]
		var p2 : Vector2 = segment_borders[segment_index]["pos"]
		var weight = range_lerp(
			arc_length,
			segment_borders[segment_index-1]["length"],
			segment_borders[segment_index]["length"],
			0,
			1)
		
		get_child(i).position = p1.linear_interpolate(p2, weight)
		
	var prev_node = null
	for i in range(get_child_count()):
		if i == 0:
			prev_node = get_child(0)
			if get_child_count() > 1:
				prev_node.rotation = PI/2 + prev_node.position.angle_to_point(get_child(1).position)
			continue

		var node = get_child(i)
		node.rotation = PI/2 + prev_node.position.angle_to_point(node.position)
		prev_node = node
	angle = new_angle
		
func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	return (1 - t) * ((1 - t) * p0 + t * p1) + t * ((1 - t) * p1 + t * p2)

# for debug only
func _draw():
	if debug:
		var radius = 10
		draw_circle(point0, radius, Color.green)
		draw_circle(point1, radius, Color.green)
		draw_circle(point2, radius, Color.green)
		if segment_borders:
			for point in segment_borders:
				draw_circle(point["pos"], radius, Color.red)


func _set_spacing(new_spacing):
	spacing = new_spacing
	_set_angle(angle)


func _set_debug(new_debug):
	debug = new_debug
	update()


func _set_tangle(new_tangle):
	tangle = new_tangle
	_set_angle(angle)


func _set_nr_of_segments(new_nr_of_segments):
	nr_of_segments = new_nr_of_segments
	_set_angle(angle)
