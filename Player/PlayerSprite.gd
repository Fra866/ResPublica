extends Area2D

onready var raycast = $RayCast2D
onready var collision_shape = $CollisionShape2D

func _ready():
	raycast.enabled = true
#	bullet


func _process(delta):
	pass


func check_collisions():
	return raycast.is_colliding()


func hit():
	print("OUCH")
