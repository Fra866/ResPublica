extends StaticBody2D

onready var raycast = $RayCast2D

func _ready():
	rotation_degrees = 0
	yield(get_tree().create_timer(1), "timeout")
	
	while position.x >= 100:
		collision()
		position.x -= 3
		yield(get_tree().create_timer(0.01), "timeout")
	
	while rotation_degrees != -90:
		collision()
		rotation_degrees -= 3
		yield(get_tree().create_timer(0.0001), "timeout")
	
	self.queue_free()


func collision():
	if raycast.is_colliding():
		print('Sei stato FASCIATO')

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
