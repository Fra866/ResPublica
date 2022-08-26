extends KinematicBody2D
const SPEED = 180.0

onready var battle_box = get_parent().get_parent()
onready var raycast_top = $RayCast2D
onready var raycast = [$RayCast2D2, $RayCast2D3, $RayCast2D4]
var velocity = Vector2(0, 0)

enum TURN {WAIT, FIGHT}
var turn

signal hit


func _ready():
	turn = TURN.WAIT
	for rc in raycast:
		rc.enabled = true


func _process(delta):
	if battle_box.attacking:
		turn = TURN.FIGHT
	else:
		turn = TURN.WAIT
		
	if turn == TURN.FIGHT:
#		for rc in raycast:
		if raycast_top.is_colliding():
			var col = raycast_top.get_collider()
			if "Bullet" in col.name:
				emit_signal("hit", col.bullet_resource.damage)
				battle_box.remove(col)
#					print("Hit")
					
		if Input.is_action_pressed("ui_down") and !raycast_top.is_colliding():
			position.y += SPEED * delta
		if Input.is_action_pressed("ui_left") and !raycast[0].is_colliding():
			position.x -= SPEED * delta
		if Input.is_action_pressed("ui_up") and !raycast[1].is_colliding():
			position.y -= SPEED * delta
		if Input.is_action_pressed("ui_right") and !raycast[2].is_colliding():
			position.x += SPEED * delta
