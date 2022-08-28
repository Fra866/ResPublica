extends Area2D

onready var raycast = $RayCast2D
onready var collision_shape = $CollisionShape2D

func _ready():
	raycast.enabled = true
	raycast.cast_to = Vector2(0, 0)


func _process(delta):
	print(raycast.cast_to)


func check_collisions():
	return raycast.is_colliding()


func hit():
	print("OUCH")
