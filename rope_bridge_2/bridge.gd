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
		var vertex_index = 0
		for child in $sprites.get_children():
			$CollisionPolygon2D.polygon[vertex_index] = child.position
			vertex_index += 1
		
		var diff = $sprites.get_child($sprites.get_child_count() - 1).position - $sprites.get_child(0).position
		var normal = diff.normalized()
		var surface_normal = normal.rotated(-PI / 2)
		
		for i in range($sprites.get_child_count()):
			var child = $sprites.get_child($sprites.get_child_count() - i - 1)
			$CollisionPolygon2D.polygon[vertex_index] = \
				child.position + surface_normal * thickness
			vertex_index += 1
		

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
			p2 = to_local(anchor.position)
			var normal = (p2 - p0).normalized()
			var length = (p2 - p0).length()
			var center = normal * length / 2
			
			# limit the bend on the edges and increase it in the center
			var dist_from_center = (bend_pos * normal - center).length()
			var dist_factor = range_lerp(dist_from_center, 0, length/2, 1, 0.0)
			dist_factor = max(0, dist_factor)
			
			p1 = bend_pos * normal + Vector2.DOWN * bend_factor * dist_factor
			if debug:
				update()
			
			var nr_of_segments = 50
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
					$sprites.get_child(i).position = p1.linear_interpolate(p2, weight)
	
	_update_rotation()

var iter = 0
func _physics_process(delta):
	update_bridge()
	if iter % 20 == 0:
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
	bend_pos = to_local(pos)
	
func clear_bend():
	bend_pos = null

func _draw():
	if debug:
		draw_circle(p0, 10, Color.rebeccapurple)
		draw_circle(p1, 10, Color.rebeccapurple)
		draw_circle(p2, 10, Color.rebeccapurple)

func set_debug(_debug):
	debug = _debug
	update()
