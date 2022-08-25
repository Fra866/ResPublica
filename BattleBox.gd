extends Node2D

#onready var enemy = get_parent().npc, or .enemy_weapons, or whatever
onready var hpBar = get_node(NodePath("../LifeBars/PlayerBar"))
const PATH = "res://Items/Bullets/Bullet.tscn"
#var weapon_path = "res://Bullet.tscn" #enemy.weapon
var attacking: bool


func _ready():
	$Walls/PlayerPointer.connect("hit", self, "set_damage")
	randomize()


#func _process(delta):
#	if attacking:
#		attacking = false
#		generate(weapon_path)


func generate(weapon_res: BulletObject, shots: int):
#	Placeholder range, to be replaced with enemy's max_weapons
	for _i in range(shots):
		var weapon  = load(PATH).instance()
		weapon.bullet_resource = weapon_res
		$Walls/Bullets.add_child(weapon)
		weapon.position = Vector2(rand_range(3, 114), rand_range(3, 10))
		yield(get_tree().create_timer(0.9), "timeout")


func remove(node: Node):
	node.queue_free()

# Placeholder
func set_damage(amount: int):
	hpBar.value -= amount
	hpBar.get_child(0).text = str(hpBar.value)
#	get_parent().damage(amount)
