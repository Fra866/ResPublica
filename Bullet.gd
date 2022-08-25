extends StaticBody2D

onready var raycast = $RayCast2D
onready var player = get_parent().get_parent().find_node("Pointer")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var gravity = 0.5

signal hit

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	position.y += gravity
	gravity += 0.08
	if raycast.is_colliding(): # We'll work on it...
		print("OUCH!")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
