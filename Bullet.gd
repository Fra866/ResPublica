extends StaticBody2D
const SPEED = 100.0

export(Resource) var bullet_resource
onready var battle_box = get_parent().get_parent().get_parent()
#To use when implemented in BattleSceneS
#onready var battle_box = get_node("/root/SceneManager/CurrentScene").get_child(0).get_child(6)
var target = Vector2(60, 117)


func _ready():
	bullet_resource = $Node.bullet_resource
	$Sprite.texture = bullet_resource.texture
#	Temporary
	$Sprite.scale = Vector2(0.08, 0.08)


func _process(delta):
	position = position.move_toward(target, delta * SPEED)
	if position == target:
		battle_box.remove(self)
