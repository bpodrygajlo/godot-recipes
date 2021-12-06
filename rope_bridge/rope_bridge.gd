tool
extends Node2D

export(NodePath) var bridge_anchor = ""
export var _update_bridge = false setget update_bridge

func add_child(node : Node, unique_name : bool = false):
	.add_child(node, unique_name)
	update_bridge()
	
func update_bridge(_x = false):
	var anchor : Node2D = get_node_or_null(bridge_anchor)
	if anchor:
		var bridge_length : float = (position - anchor.position).length()
		var segment_length : float = bridge_length / (get_child_count() - 1)
		var normal = (anchor.position - position).normalized()
		var pos = Vector2.ZERO
		
		for child in get_children():
			child.set_target_position(pos)
			pos += normal * segment_length
	_update_rotation()

func _physics_process(delta):
	update_bridge()

func _update_rotation():
	for i in range(1, get_child_count() - 1):
		var prev_child = get_child(i - 1)
		var next_child = get_child(i + 1)
		var child = get_child(i)
		child.set_target_rotation((child.position.angle_to_point(prev_child.position) + \
			next_child.position.angle_to_point(child.position)) / 2)

func bend_at(child_index):
	pass
