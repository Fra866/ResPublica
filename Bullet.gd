extends StaticBody2D

onready var raycast = $RayCast2D
onready var player = get_parent().get_parent().find_node("Player")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal hit

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if raycast.is_colliding():
		player.hit()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
