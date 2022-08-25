extends Node2D

#onready var enemy = get_parent().npc, or .enemy_weapons, or whatever
var weapon_path = "res://Bullet.tscn" #enemy.weapon
var attacking: bool


func _ready():
	$Walls/Player.connect("hit", self, "set_damage")
	randomize()
	attacking = true


func _process(delta):
	if attacking:
		attacking = false
		generate(weapon_path)


func generate(path):
#	Placeholder range, to be replaced with enemy's max_weapons
	for _i in range(40):
		var weapon  = load(path).instance()
		$Walls/Bullets.add_child(weapon)
		weapon.position = Vector2(rand_range(3, 114), rand_range(3, 10))
		yield(get_tree().create_timer(2), "timeout")


func remove(node: Node):
	node.queue_free()

# Placeholder
func set_damage(amount: int):
	get_parent().damage(amount)
