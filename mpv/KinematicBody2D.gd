extends KinematicBody2D

var from : Vector2 = Vector2()
var to : Vector2 = Vector2()

func _physics_process(delta):
	if Input.is_action_pressed("ui_left"):
		rotate(deg2rad(1))
	if Input.is_action_pressed("ui_accept"):
		position = get_global_mouse_position()
		var space : Physics2DDirectSpaceState = get_world_2d().get_direct_space_state()
		var q : Physics2DShapeQueryParameters = Physics2DShapeQueryParameters.new()
		q.transform = transform
		q.set_shape($CollisionShape2D.shape)
		q.collide_with_bodies = true
		q.exclude = [self]
		var res = space.collide_shape(q, 1)
		if res.size() > 0:
			from = res[0]
			to = res[1]
			print(from, to)
			update()
			
func _draw():
	draw_line(to_local(from), to_local(to), Color.red, 2.0)
		
