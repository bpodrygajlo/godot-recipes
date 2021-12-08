tool
extends Node2D
signal update_bridge

func add_child(node : Node, unique_name : bool = false):
	.add_child(node, unique_name)
	emit_signal("update_bridge")
