extends Node2D


onready var scenemanager = get_node(NodePath('/root/SceneManager/'))
onready var menu = get_node(NodePath('/root/SceneManager/Menu'))
onready var dialogue_box = get_node(NodePath('/root/SceneManager/DialougeBox'))
onready var ui = get_node(NodePath('/root/SceneManager/UI'))

onready var whattodo = $BattleMenu/WhatToDo/
onready var slogButton = $BattleMenu/WhatToDo/Panel/Container/Slogans
onready var objButton = $BattleMenu/WhatToDo/Panel/Container/Objects
onready var quitButton = $BattleMenu/WhatToDo/Panel/Container/Quit
onready var pBar = $LifeBars/PlayerBar
onready var npcBar = $LifeBars/NPCBar
onready var sloganlist = $BattleMenu/Slogans
onready var objectlist = $BattleMenu/Objects
onready var battlemenu = $BattleMenu
onready var selector = $BattleMenu/Selector/SelectorBackground
onready var margincontainer = $ActionLog/MarginContainer
onready var action_log = $ActionLog/MarginContainer/Panel/Label
onready var political_compass = $PoliticalCompass
onready var enemy_sprite = $EnemySprite

onready var n_of_slogans = 0
onready var n_of_objects = 0

onready var max_slogans = 8
onready var max_objects = 8

onready var votes: int

onready var priority = true
onready var enemy_slogans: Array
var id = 0
var next_scene = ""
var player_pos = Vector2(0, 0)

onready var p_attack: Vector2
onready var e_attack: Vector2

onready var attacking = false

onready var first_attack_player = true
onready var first_attack_enemy = true

enum TURN {PLAYER, ENEMY, ATTACKING}
enum BATTLE_UI {SLOGANS, OBJECTS, EXIT, MENU}

onready var turn = TURN.PLAYER
onready var battle_ui = BATTLE_UI.MENU


func _ready():
	randomize()
	enemy_sprite.texture = load("res://UI/andreotti/battle.png")
	political_compass.visibility(true)
	
	dialogue_box.connect("npc_slogans", self, "set_npc_slogans")
	dialogue_box.connect("next_scene", self, "set_next_scene")
	dialogue_box.connect("send_npc", self, "set_npc")
	
	sloganlist.visible = false
	objectlist.visible = false
	
	slogButton.grab_focus()
	
	slogan_setup()
	object_setup()


func slogan_setup():
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


func object_setup():
	for object_res in menu.object_list:
		if object_res.display_on_battle:
			var new_obj_instance = load("res://Scenes/UI_Objects/ObjectNode.tscn").instance()
			
			new_obj_instance.object_res = object_res
			
			n_of_objects += 1
			
			var x = 12 + 32 * (n_of_objects % max_objects)
			if x == 12:
				x += 32 # + (32 * n_of_slogans/max_slogans)
			var y = 112 + 40*(int(n_of_objects / (max_objects + 1)))

			new_obj_instance.position = Vector2(x, y)
			new_obj_instance.scale = Vector2(1.3, 1.3)
			objectlist.add_child(new_obj_instance)

func _process(_delta):
	if battle_ui == BATTLE_UI.MENU:
		selector.visible = false
		sloganlist.visible = false
		whattodo.visible = true
		
		if Input.is_action_just_pressed("ui_accept"):
			if slogButton.has_focus():
				battle_ui = BATTLE_UI.SLOGANS
	elif battle_ui == BATTLE_UI.SLOGANS:
		selector.visible = true
		sloganlist.visible = true
		whattodo.visible = false
		
		if turn == TURN.PLAYER:
			var slog = menu.slogan_list[id]
			
			if Input.is_action_just_pressed("ui_right") and id < n_of_slogans - 1:
				id += 1
			if Input.is_action_just_pressed("ui_down") and (id + 7) < n_of_slogans - 1:
				id += 7
			if Input.is_action_just_pressed("ui_up") and id > 6:
				id -= 7
			if Input.is_action_just_pressed("ui_left") and id > 0:
				id -= 1
			if Input.is_action_just_pressed("ui_end"):
				battle_ui = BATTLE_UI.MENU
				slogButton.grab_focus()
			
			political_compass.set_line(political_compass.get_main_pointer() ,slog.political_pos.x, -slog.political_pos.y)

		selector.rect_position = Vector2(32 * (id % (max_slogans - 1)), 40*(int(id / (max_slogans - 1))))
		
		
		if Input.is_action_just_pressed("ui_accept"):
			attacking = true
			playerAttack(menu.slogan_list[id])


func get_rand():
	var tmp = ResourceLoader.load("res://NPC/tmp.tres")
	var dim = len(tmp.slogans_for_battle)
	var n = randi() % dim
	return tmp.slogans_for_battle[n]


func set_npc_slogans(slogan_list):
	enemy_slogans = slogan_list


func set_next_scene(scene: String, p_pos: Vector2):
	next_scene = scene
	player_pos = p_pos


func set_npc(current_npc):
	votes = current_npc.votes
	enemy_sprite.texture = load(current_npc.battle_sprite_path)


func battle_ends(victory):
	action_log.text = "Battaglia finita."
	margincontainer.visible = true
	battlemenu.visible = false
	yield(get_tree().create_timer(2), "timeout")
	
	if victory:
		action_log.text = "Hai ottenuto " + str(votes) + " voti."
		yield(get_tree().create_timer(1.5), "timeout")
		ui.add_votes(votes)
	
	end(next_scene)
	
	# scenemanager.start_transition("scene_path", Vector2(0,0))


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


func npcAttack(attack_slog):
	turn = TURN.ENEMY
	action_log.text = "Il nemico ha usato " + attack_slog.name
	e_attack = attack_slog.political_pos
	political_compass.set_enemy_pointer(e_attack.x, -e_attack.y)
	battle_ui = BATTLE_UI.MENU
	yield(get_tree().create_timer(1), "timeout")
	margincontainer.visible = false
	battlemenu.visible = true
	yield(get_tree().create_timer(0.1), "timeout")
	
	damage(p_attack, e_attack)
	if npcBar.value == 0 or pBar.value == 0:
		battle_ends(pBar.value)
	
	battle_ui = BATTLE_UI.MENU
	slogButton.grab_focus()
	
	turn = TURN.PLAYER
	
#	print(slogan.name)
#	pBar.value -= slogan.xp
#	attacking = true
#	if !pBar.value:
#		end()


func damage(p_pos: Vector2, n_pos: Vector2):
#	The sum of distances on both axises must be greater than 10 to hurt the player,
#	otherwise it successfully hits the enemy.
	var d = (10 - abs(p_pos.x - n_pos.x) - abs(p_pos.y - n_pos.y)) / 2
	if d < 0:
		pBar.value -= 8 * abs(d)
	else:
		npcBar.value -= 8*d


func end(scene):
	scenemanager.start_transition("res://Scenes/" + scene + ".tscn", player_pos)
	# current_enemy.battle_won = true
