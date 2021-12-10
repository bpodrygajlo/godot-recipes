extends Camera


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var target: RigidBody = get_node("../RigidBody")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	look_at(target.transform.origin, Vector3.UP)
