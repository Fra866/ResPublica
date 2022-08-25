extends StaticBody2D
const SPEED = 100.0

onready var battle_box = get_parent().get_parent().get_parent()
#To use when implemented in BattleSceneS
#onready var battle_box = get_node("/root/SceneManager/CurrentScene").get_child(0).get_child(6)
onready var player = get_parent().get_parent().find_node("Player")
var target = Vector2(60, 117)


func _ready():
	pass


func _process(delta):
	position = position.move_toward(target, delta * SPEED)
	if position == target:
		battle_box.remove(self)
