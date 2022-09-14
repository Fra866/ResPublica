extends Area2D

onready var raycast = $RayCast2D
onready var battle_rc = $RayCast2D2
onready var collision_shape = $CollisionShape2D
onready var battlebox = get_parent().get_parent()
onready var hp = $"../../../LifeBars/PlayerBar"


func _ready():
	battlebox.connect("player_hit", self, "hit")
	raycast.enabled = true
	raycast.cast_to = Vector2(0, 0)
	battle_rc.add_exception(get_parent())


func check_collisions():
	return battle_rc.is_colliding() and battle_rc.enabled


func set_battle_raycast(rc: RayCast2D):
	battle_rc.cast_to = -rc.cast_to
	battle_rc.force_raycast_update()


func hit(damage):
# Dummy damage computation
	hp.value -= damage
	hp.get_child(0).text = str(hp.value)
	
	battle_rc.enabled = false
	yield(get_tree().create_timer(1), "timeout")
	battle_rc.enabled = true
