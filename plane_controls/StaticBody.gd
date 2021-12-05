extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	if Input.is_action_pressed("ui_left"):
		rotate_object_local(Vector3.FORWARD, 3 * delta)
	if Input.is_action_pressed("ui_right"):
		rotate_object_local(Vector3.FORWARD, -3 * delta)
		
	var forward = -transform.basis.z
	move_and_slide(forward * 0.5, Vector3.UP)
	
	if Input.is_action_pressed("ui_up"):
		rotate_object_local(Vector3.UP, -3 * delta)
	if Input.is_action_pressed("ui_down"):
		rotate_object_local(Vector3.DOWN, -3 * delta)
