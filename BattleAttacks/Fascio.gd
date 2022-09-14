extends StaticBody2D

onready var raycast = $RayCast2D
var damage: int = 10

func _ready():
	rotation_degrees = 0
	yield(get_tree().create_timer(1), "timeout")
	
	while position.x >= 100:
#		collision()
		position.x -= 3
		yield(get_tree().create_timer(0.01), "timeout")
	
	while rotation_degrees != -90:
#		collision()
		rotation_degrees -= 3
		yield(get_tree().create_timer(0.0001), "timeout")
	
	self.queue_free()

# Test-only function, since collision is now handled by battlebox
#func collision():
#	if raycast.is_colliding():
#		print('Sei stato FASCIATO')
#		raycast.enabled = false

