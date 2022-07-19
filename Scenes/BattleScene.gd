extends Node2D


onready var scenemanager = get_node(NodePath('/root/SceneManager/'))
onready var menu = get_node(NodePath('/root/SceneManager/Menu'))
onready var dialouge_box = get_node(NodePath('/root/SceneManager/DialougeBox'))
onready var pBar = $LifeBars/PlayerBar
onready var npcBar = $LifeBars/NPCBar
onready var sloganlist = $BattleMenu/Slogans
onready var battlemenu = $BattleMenu
onready var selector = $BattleMenu/Node2D/ColorRect
onready var margincontainer = $ActionLog/MarginContainer
onready var action_log = $ActionLog/MarginContainer/Panel/Label
onready var political_compass = $PoliticalCompass

onready var n_of_slogans = 0
onready var max_slogans = 8
onready var priority = true
onready var enemy_slogans: Array
var id = 0

onready var p_attack: Vector2
onready var e_attack: Vector2

onready var attacking = false

onready var first_attack_player = true
onready var first_attack_enemy = true

onready var path: String
onready var next_player_pos: Vector2

enum TURN {PLAYER, ENEMY, ATTACKING}
onready var turn = TURN.PLAYER

func _ready():
	political_compass.visibility(true)
	
	dialouge_box.connect("npc_slogans", self, "set_npc_slogans")
	dialouge_box.connect("next_scene", self, "set_next_scene")
	dialouge_box.connect("next_player_pos", self, "set_next_player_pos")
	
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
		var slog = menu.slogan_list[id]
		
		if Input.is_action_just_pressed("ui_right") and id < 10:
			id += 1
		if Input.is_action_just_pressed("ui_down") and id < 4:
			id += 7
		if Input.is_action_just_pressed("ui_up") and id > 6:
			id -= 7
		if Input.is_action_just_pressed("ui_left") and id > 0:
			id -= 1
		
		political_compass.set_line(political_compass.get_main_pointer() ,slog.political_pos.x, -slog.political_pos.y)

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


func set_next_scene(next_scene):
	var original_name: String
	if next_scene.name[0] == '@':
		for i in range(1, len(next_scene.name)):
			if next_scene.name[i] == '@':
				break
			original_name += next_scene.name[i]
	else:
		original_name = next_scene.name
	
	path = "res://Scenes/" + original_name + ".tscn"
	# scenemanager.start_transition(path, Vector2(0,0))


func set_next_player_pos(player_pos):
	next_player_pos = player_pos
	print(player_pos)


func battle_ends(battle_won: bool):
	action_log.text = "Battaglia finita"
	margincontainer.visible = true
	battlemenu.visible = false
	
	yield(get_tree().create_timer(1), "timeout")
	
	scenemanager.start_transition(path, Vector2(0,0))


func playerAttack(slogan):
	political_compass.set_main_pointer(slogan.political_pos.x, -slogan.political_pos.y)
	political_compass.hide_line()
	
	turn = TURN.ATTACKING
	action_log.text = "Hai usato " + slogan.name
	p_attack = slogan.political_pos
	margincontainer.visible = true
	yield(get_tree().create_timer(1), "timeout")
	battlemenu.visible = false
	
	npcAttack(enemy_slogans[randi() % len(enemy_slogans) - 1])


func damage(p_pos: Vector2, n_pos: Vector2):
	var d = (5 - abs(p_pos.x - n_pos.x) + 5 - abs(p_pos.y - n_pos.y)) / 2
	if d < 0:
		pBar.value -= 8 * abs(d)
	else:
		npcBar.value -= 8*d


func npcAttack(attack_slog):
	turn = TURN.ENEMY
	action_log.text = "Il nemico ha usato " + attack_slog.name
	e_attack = attack_slog.political_pos
	political_compass.set_enemy_pointer(e_attack.x, -e_attack.y)
	yield(get_tree().create_timer(1), "timeout")
	margincontainer.visible = false
	battlemenu.visible = true
	
	yield(get_tree().create_timer(0.1), "timeout")
	
	# print(p_attack, e_attack)
	
	damage(p_attack, e_attack)
	print('Turn Ends')
	
	if npcBar.value == 0:
		battle_ends(true)
	if pBar.value == 0:
		battle_ends(false)
	
	turn = TURN.PLAYER
	
#	print(slogan.name)
#	pBar.value -= slogan.xp
#	attacking = true
#	if !pBar.value:
#		end()


func end():
	get_parent().get_parent().start_transition("res://Scenes/Level1.tscn", Vector2(0, 0))
