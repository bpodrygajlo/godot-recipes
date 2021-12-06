extends KinematicBody2D
const SPEED = 300
var velocity : Vector2 = Vector2()
func _physics_process(delta):
	if Input.is_action_pressed("ui_right"):
		velocity.x = SPEED
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -SPEED
	else:
		velocity.x = 0
	velocity += Vector2(0, 90)
	
	if Input.is_action_just_pressed("ui_up"):
		velocity += Vector2.UP * 2000
	velocity = move_and_slide(velocity, Vector2.UP, true)
	
