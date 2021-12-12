extends KinematicBody2D
const SPEED = 300
var velocity : Vector2 = Vector2()

# can only bend 1 bridge at a time
var affected_bridge = null

func _physics_process(delta):
	if Input.is_action_pressed("ui_right"):
		velocity.x = SPEED
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -SPEED
	else:
		velocity.x = 0
	velocity += Vector2.DOWN * 45
	
	var is_jumping = false
	if Input.is_action_just_pressed("ui_up"):
		is_jumping = true
		velocity += Vector2.UP * 1000
	
	
	# Find a bridge which could collide with the body in up to two frames
	var collision = move_and_collide(velocity * delta, true, true, true)
	if not collision:
		collision = move_and_collide(velocity * delta * 2, true, true, true)
	if not collision:
		collision = move_and_collide(velocity * delta * 4, true, true, true)
	if not collision:
		collision = move_and_collide(velocity * delta * 6, true, true, true)
	if collision:
		if affected_bridge != collision.collider:
			if affected_bridge != null:
				affected_bridge.clear_bend()
				print("cleared due to different collision")
			affected_bridge = collision.collider
	else:
		if affected_bridge != null:
			affected_bridge.clear_bend()
			affected_bridge = null
			print(["cleared due to no collision", velocity])
		
	if affected_bridge != null:
		affected_bridge.bend(global_position)
			
			
	velocity = move_and_slide(velocity, Vector2.UP, true)
