extends Node2D

onready var player_pointer = $Walls/PlayerPointer
onready var p_raycast = player_pointer.get_child(2)
onready var attack_container = $Walls/AttackContainer

var attack

func _ready():
	pass
#	$Walls/AttackContainer.connect()


func move_pointer(input_direction: Vector2):
	p_raycast.cast_to = Vector2(input_direction.x * 10, input_direction.y * 10)
	p_raycast.force_raycast_update()
	
	if !p_raycast.is_colliding():
		player_pointer.position += input_direction

func _process(delta):
	if attack_container.get_children():
		print(player_pointer.check_collisions())

func generate():
	attack = fascio()
	
	$Walls/AttackContainer.add_child(attack)
	yield(get_tree().create_timer(3), "timeout")


func bullet():
	var bullet = load("res://Bullet.tscn").instance()
	bullet.position = Vector2(randi() % 90, -42)
	bullet.scale = Vector2(1, 1)

	return bullet


func fascio():
	var fascio = load("res://BattleAttacks/Fascio.tscn").instance()
	fascio.position = Vector2(205, 123)
	fascio.scale = Vector2(3, 3)
	
	return fascio
