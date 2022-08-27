extends StaticBody2D

onready var raycast = $RayCast2D
onready var player = get_parent().get_parent().find_node("PlayerPointer")
onready var gravity = 0.5

signal hit


func _ready():
	$AnimationPlayer.play("Travel")
	raycast.enabled = true


func _process(_delta):
	position.y += gravity
	gravity += 0.08
	if raycast.is_colliding(): # We'll work on it...
		gravity = 0
		$AnimationPlayer.play("Hit")
		self.queue_free()
#		emit_signal("hit")
		player.hit()
