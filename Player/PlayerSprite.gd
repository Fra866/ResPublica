extends KinematicBody2D
const SPEED = 100.0

onready var battle_box = get_parent().get_parent()
onready var raycast = [$RayCast2D, $RayCast2D2, $RayCast2D3, $RayCast2D4]
var velocity = Vector2(0, 0)

signal hit


func _ready():
	for rc in raycast:
		rc.enabled = true


func _process(delta):
	for rc in raycast:
		if rc.is_colliding():
			if "Bullet" in rc.get_collider().name:
				emit_signal("hit") #("hit", rc.get_collider().damage)
				battle_box.remove(rc.get_collider())
				print("Hit")
				
	if Input.is_action_pressed("ui_down") and !raycast[0].is_colliding():
		position.y += SPEED * delta
	if Input.is_action_pressed("ui_left") and !raycast[1].is_colliding():
		position.x -= SPEED * delta
	if Input.is_action_pressed("ui_up") and !raycast[2].is_colliding():
		position.y -= SPEED * delta
	if Input.is_action_pressed("ui_right") and !raycast[3].is_colliding():
		position.x += SPEED * delta
