extends Node2D

onready var menu = get_node(NodePath('/root/SceneManager/Menu'))
onready var dialouge_box = get_node(NodePath('/root/SceneManager/DialougeBox'))
onready var pBar = $LifeBars/PlayerBar
onready var npcBar = $LifeBars/NPCBar
onready var sloganlist = $BattleMenu/Slogans
onready var battlemenu = $BattleMenu
onready var selector = $BattleMenu/Node2D/ColorRect
onready var margincontainer = $ActionLog/MarginContainer
onready var action_log = $ActionLog/MarginContainer/Panel/Label

onready var n_of_slogans = 0
onready var max_slogans = 8
onready var priority = true
onready var enemy_slogans: Array
var id = 0

onready var attacking = false

enum TURN {PLAYER, ENEMY, ATTACKING}
onready var turn = TURN.PLAYER

func _ready():
	dialouge_box.connect("npc_slogans", self, "set_npc_slogans")
	for slogan_res in menu.slogan_list:
		var new_slog_instance = load("res://Scenes/UI_Objects/SloganNode.tscn").instance()
		
		new_slog_instance.slogan_res = slogan_res
		
		n_of_slogans += 1
		
		var x = 12 + 32 * (n_of_slogans % max_slogans)
		if x == 12:
			x += 32 # + (32 * n_of_slogans/max_slogans)
		var y = 112 + 40*(int(n_of_slogans / (max_slogans+1)))

		new_slog_instance.position = Vector2(x, y)
		new_slog_instance.scale = Vector2(1.3, 1.3)
		sloganlist.add_child(new_slog_instance)


func _process(_delta):
#	Temporary solution. Visual cue, or selector, to be soon implemented.
	if turn == TURN.PLAYER:
		if Input.is_action_just_pressed("ui_right") and id < 10:
			id += 1
		if Input.is_action_just_pressed("ui_down") and id < 4:
			id += 7
		if Input.is_action_just_pressed("ui_up") and id > 6:
			id -= 7
		if Input.is_action_just_pressed("ui_left") and id > 0:
			id -= 1

	selector.rect_position = Vector2(32 * (id % (max_slogans - 1)), 40*(int(id / (max_slogans - 1))))

	if Input.is_action_just_pressed("ui_accept"):
		attacking = true
		playerAttack(menu.slogan_list[id])
#		print(menu.slogan_list[id].name)
#
#		action_log.text = "Hai usato " + used_slog.name
#		margincontainer.visible = true
#		yield(get_tree().create_timer(1), "timeout")
#		battlemenu.visible = false
	

func get_rand():
	var tmp = ResourceLoader.load("res://NPC/tmp.tres")
	var dim = len(tmp.slogans_for_battle)
	var n = randi() % dim
	return tmp.slogans_for_battle[n]


func set_npc_slogans(slogan_list):
	var tmp = ResourceLoader.load("res://NPC/tmp.tres")
	print(tmp.slogans_for_battle)
	enemy_slogans = tmp.slogans_for_battle
	#for slog in slogan_list:
	#	print(slog.name)
	#enemy_slogans = slogan_list


func playerAttack(slogan):
	turn = TURN.ATTACKING
	action_log.text = "Hai usato " + slogan.name
	margincontainer.visible = true
	yield(get_tree().create_timer(1), "timeout")
	battlemenu.visible = false
	
	npcAttack(enemy_slogans[randi() % len(enemy_slogans) - 1])


func npcAttack(attack_slog):
	turn = TURN.ENEMY
	action_log.text = "Il nemico ha usato " + attack_slog.name
	yield(get_tree().create_timer(1), "timeout")
	margincontainer.visible = false
	battlemenu.visible = true
	
	yield(get_tree().create_timer(1), "timeout")
	
	turn = TURN.PLAYER
	
#	print(slogan.name)
#	pBar.value -= slogan.xp
#	attacking = true
#	if !pBar.value:
#		end()


func end():
	get_parent().get_parent().start_transition("res://Scenes/Level1.tscn", Vector2(0, 0))
