extends KinematicBody2D
const SPEED = 300
var velocity : Vector2 = Vector2()


var bridge = null

func _physics_process(delta):
	if Input.is_action_pressed("ui_right"):
		velocity.x = SPEED
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -SPEED
	else:
		velocity.x = 0
	velocity += Vector2.DOWN * 90
	
	var is_jumping = false
	if Input.is_action_just_pressed("ui_up"):
		is_jumping = true
		velocity += Vector2.UP * 2000
	
	
	# Find a bridge which could collide with the body in up to two frames
	var collision = move_and_collide(velocity * delta * 2, true, true, true)
	if collision:
		if bridge != null:
			bridge.clear_bend()
		bridge = collision.collider
		
		
	# If the player is jumping we can clear the bridges bend
	if velocity.y < 0 and bridge != null:
		bridge.clear_bend()
		bridge = null
		
	# If player is still sliding on the bridge update the bend position
	if bridge != null:
		bridge.bend(global_position)
			
	if not is_jumping:
		velocity = move_and_slide_with_snap(velocity, Vector2.DOWN * 10, Vector2.UP, true)
	else:
		velocity = move_and_slide(velocity, Vector2.UP, true)
