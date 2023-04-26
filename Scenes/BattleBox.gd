extends Node2D

onready var player_pointer = $Walls/PlayerPointer
onready var p_raycast = player_pointer.get_child(2)
onready var attack_container = $Walls/AttackContainer

onready var attack_id: int # IDEA: Using IDs to decide what attack shold be started. This will depend on the npc
var attack: Array # Containes the current attack Node
var attack_types: Array = ["fascio", "bullet"]

signal player_hit

func _ready():
	pass


func reset_pointer():
	player_pointer.position = Vector2(88, 80)


func move_pointer(input_direction: Vector2):
	p_raycast.cast_to = Vector2(input_direction.x, input_direction.y)
	p_raycast.force_raycast_update()
	
	if !p_raycast.is_colliding():
		player_pointer.position += input_direction * 2.0


func _process(_delta):
	if player_pointer.check_collisions():
		emit_signal("player_hit", attack[0].damage)


func generate(attacks_list):
	# Select random attack from the available ones
	attack_id = attacks_list[randi() % len(attacks_list)]
	
	attack = call(attack_types[attack_id])
		
	start_attack(attack[0], attack[1])
	yield(get_tree().create_timer(3), "timeout")


func start_attack(att, time_of_action: float):
	attack_container.add_child(att)
	player_pointer.set_battle_raycast(att.raycast)
	yield(get_tree().create_timer(time_of_action), "timeout")


func bullet():
	var bullet = load("res://BattleAttacks/Bullet.tscn").instance()
	bullet.position = Vector2(randi() % 90, -42)
	bullet.scale = Vector2(1, 1)

#	start_attack(bullet, 2)
	return [bullet, 2]


func fascio():
	var fascio = load("res://BattleAttacks/Fascio.tscn").instance()
	fascio.position = Vector2(205, 123)
	fascio.scale = Vector2(3, 3)
	
#	start_attack(fascio, 3)
	return [fascio, 3]
