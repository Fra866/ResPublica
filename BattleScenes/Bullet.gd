extends StaticBody2D

onready var raycast = $RayCast2D
#onready var player = get_parent().get_parent().find_node("PlayerPointer")
onready var gravity = 0.5
var damage: int = 8


func _ready():
	$AnimationPlayer.play("Travel")
	raycast.enabled = true


func _process(_delta):
	position.y += gravity
	gravity += 0.08
	
	if raycast.is_colliding():
		gravity = 0
		$AnimationPlayer.play("Hit")
		yield($AnimationPlayer, "animation_finished")
		queue_free()
			
	if position.y > 154:
		queue_free()
