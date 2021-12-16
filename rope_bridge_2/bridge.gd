tool
extends KinematicBody2D

# The anchor on the other side of the bridge
export(NodePath) var bridge_anchor = ""
# Updates bridge segment position
export var _update_bridge = false setget update_bridge
# To generate the polygon for the bridge
export var _create_polygon = false setget create_polygon
# How deep does the birdge bend
export var bend_factor = 40
# How thick is the bridge
export var thickness = 40

# ratio of bend on the edges
export var edge_bend_factor = 0.0

# determines where the bend stats working. E.g 0.9 means the outer 10% of each side
# doesn't bend. Value of .8 means 20% of each side is not bendable
export var edge_bend_cutoff = 0.8


# to draw some debug info
export var debug = false setget set_debug

# bezier curve points
var p0 : Vector2
var p1 : Vector2
var p2 : Vector2

func add_child(node : Node, unique_name : bool = false):
	.add_child(node, unique_name)
	update_bridge()


# This genrates the collision polygon	
func create_polygon(_x = false):
	var anchor : Node2D = get_node_or_null(bridge_anchor)
	if anchor:
		var poly : Array = []
		for child in $sprites.get_children():
			poly.append(child.position)
		
		var diff = $sprites.get_child($sprites.get_child_count() - 1).position - $sprites.get_child(0).position
		var normal = diff.normalized()
		var surface_normal = normal.rotated(-PI / 2)
		
		for i in range($sprites.get_child_count()):
			var child = $sprites.get_child($sprites.get_child_count() - i - 1)
			poly.append(child.position + surface_normal * thickness)
		
		$CollisionPolygon2D.polygon = PoolVector2Array(poly)


# This updated the polygon points
func update_polygon():
	var anchor : Node2D = get_node_or_null(bridge_anchor)
	if anchor:
		var new_poly = []
		for child in $sprites.get_children():
			new_poly.append(child.position)
		
		var diff = $sprites.get_child($sprites.get_child_count() - 1).position - $sprites.get_child(0).position
		var normal = diff.normalized()
		var surface_normal = normal.rotated(-PI / 2)
		
		for i in range($sprites.get_child_count()):
			var child = $sprites.get_child($sprites.get_child_count() - i - 1)
			new_poly.append(child.position + surface_normal * thickness)
			
		$CollisionPolygon2D.polygon = new_poly
		

func update_bridge(_x = false):
	var anchor : Node2D = get_node_or_null(bridge_anchor)
	if anchor:
		if bend_pos == null:
			var bridge_length : float = (global_position - anchor.global_position).length()
			var segment_length : float = bridge_length / ($sprites.get_child_count() - 1)
			var normal = (anchor.global_position - global_position).normalized()
			var pos = Vector2.ZERO
			
			for child in $sprites.get_children():
				child.set_target_position(pos)
				pos += normal * segment_length
		else:
			p0 = $sprites.position
			p2 = to_local(anchor.global_position)
			var normal = p0.direction_to(p2)
			var length = (p2 - p0).length()
			var center = normal * length / 2
			
			# limit the bend on the edges and increase it in the center
			var dist_factor = 0.0
			var dist_from_center = ((bend_pos.x - p0.x) * normal - center).length()
			if dist_from_center/(length/2) < edge_bend_cutoff:
				dist_factor = range_lerp(dist_from_center, 0, length/2, 1, edge_bend_factor)
				dist_factor = max(0, dist_factor)
			
			p1 = (bend_pos.x - p0.x) * normal + Vector2.DOWN * bend_factor * dist_factor
			
			if debug:
				update()
			
			# This determines the amount of bezier segments to calculate and has
			# big impact on perfromacne
			# The bridge doesnt look good with little segments (tested with 5 and 10)
			# TODO: either optimize this further or fix the display issue when there is
			# few segments
			var nr_of_segments = 15
			var sprite_count = $sprites.get_child_count()
			var segments = Bezier.quadratic_segments(p0, p1, p2, nr_of_segments)
			var segment_length = segments[segments.size() - 1]["length"] / (sprite_count - 1)
			var segment_index = 0
			for i in range(1, sprite_count - 1):
				var arc_length = i * segment_length
				
				# find the point that is on the curve in front of our desired position
				while segments[segment_index]["length"] <= arc_length:
					segment_index += 1
				
				if segment_index < nr_of_segments:	
					# interpolate between the two points
					var p1 : Vector2 = segments[segment_index-1]["pos"]
					var p2 : Vector2 = segments[segment_index]["pos"]
					var weight = range_lerp(
						arc_length,
						segments[segment_index-1]["length"],
						segments[segment_index]["length"],
						0,
						1)
					$sprites.get_child(i).target_position = p1.linear_interpolate(p2, weight)
	
	_update_rotation()


var time_since_last_bend = 0
func _physics_process(delta):
	# Avoid recalculating the polygon if the bridge has already returned to its
	# rest position. Assumption here is that it woudn't take more than 2 seconds
	if bend_pos == null and time_since_last_bend < 2:
		time_since_last_bend += delta
		update_bridge()
		update_polygon()

# rotates the bridge segments 
func _update_rotation():
	for i in range(1, $sprites.get_child_count() - 1):
		var prev_child = $sprites.get_child(i - 1)
		var next_child = $sprites.get_child(i + 1)
		var child = $sprites.get_child(i)
		child.set_target_rotation((child.position.angle_to_point(prev_child.position) + \
			next_child.position.angle_to_point(child.position)) / 2)


func _on_sprites_update_bridge():
	update_bridge()


var bend_pos = null
func bend(pos : Vector2):
	var new_bend_pos = to_local(pos)
	# Do not recalculate the polygon if the bend position is close to the previous bend position
	if bend_pos == null or abs(new_bend_pos.x - bend_pos.x) > 1 or bend_pos.y < new_bend_pos.y:
		time_since_last_bend = 0
		bend_pos = new_bend_pos
		update_bridge()
		update_polygon()
		
func clear_bend():
	bend_pos = null

func _draw():
	if debug:
		draw_circle(p0, 10, Color.rebeccapurple)
		draw_circle(p1, 10, Color.rebeccapurple)
		draw_circle(p2, 10, Color.rebeccapurple)
		draw_line(p0, p2, Color.aqua)
		draw_line(p0, p1, Color.aqua)
		draw_line(p2, p1, Color.aqua)

func set_debug(_debug):
	debug = _debug
	update()
