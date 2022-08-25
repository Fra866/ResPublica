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
onready var pLabel = $LifeBars/PlayerBar/Label
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

onready var enemy_political_pos: Vector2
onready var votes: int

onready var priority = true
onready var enemy_weapon: BulletObject
onready var enemy_shots: int = 0
#onready var enemy_slogans: Array
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
	
#	dialogue_box.connect("npc_slogans", self, "set_npc_slogans")
	dialogue_box.connect("npc_weapons", self, "set_npc_weapons")
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
		var y = 142 + 40*(int(n_of_slogans / (max_slogans+1)))

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
			var y = 142 + 40*(int(n_of_objects / (max_objects + 1)))

			new_obj_instance.position = Vector2(x, y)
			new_obj_instance.scale = Vector2(1.3, 1.3)
			objectlist.add_child(new_obj_instance)

func _process(_delta):
	if battle_ui == BATTLE_UI.MENU:
		selector.visible = false
		sloganlist.visible = false
		objectlist.visible = false
		whattodo.visible = true
		
		if Input.is_action_just_pressed("ui_accept"):
			if slogButton.has_focus():
				switch_visibility(true)
				battle_ui = BATTLE_UI.SLOGANS
#				selector.visible = true
#				sloganlist.visible = true
#				objectlist.visible = false
#				whattodo.visible = false
			elif objButton.has_focus():
				switch_visibility(false)
				battle_ui = BATTLE_UI.OBJECTS
			else:
				battle_ui = BATTLE_UI.EXIT
				
	elif battle_ui == BATTLE_UI.SLOGANS:
#		whattodo.visible = false
#		selector.visible = true
#		sloganlist.visible = true
#		objectlist.visible = false
		
		if turn == TURN.PLAYER:
			var slog = menu.slogan_list[id]
#
#			if Input.is_action_just_pressed("ui_right") and id < n_of_slogans - 1:
#				id += 1
#			if Input.is_action_just_pressed("ui_down") and (id + 7) < n_of_slogans - 1:
#				id += 7
#			if Input.is_action_just_pressed("ui_up") and id > 6:
#				id -= 7
#			if Input.is_action_just_pressed("ui_left") and id > 0:
#				id -= 1
			id = handle_input(id, n_of_slogans, selector)
			political_compass.set_line(political_compass.get_main_pointer() ,slog.political_pos.x, -slog.political_pos.y)

#			if Input.is_action_just_pressed("ui_end"):
#				battle_ui = BATTLE_UI.MENU
#				id = 0
#				slogButton.grab_focus()
		
			if Input.is_action_just_pressed("ui_accept"):
				attacking = true
#				playerAttack(slog)
				playerAttack(menu.slogan_list[id])
			
	elif battle_ui == BATTLE_UI.OBJECTS:
#		whattodo.visible = false
#		sloganlist.visible = false
#		selector.visible = true
#		objectlist.visible = true
		if n_of_objects:
			id = handle_input(id, n_of_objects, selector)
			if Input.is_action_just_pressed("ui_accept"):
				pass
	
	elif battle_ui == BATTLE_UI.EXIT:
		battle_ends(0)
	
	if Input.is_action_just_pressed("ui_end"):
		battle_ui = BATTLE_UI.MENU
		id = 0
		slogButton.grab_focus()


func handle_input(id, maxv, selector):
	if Input.is_action_just_pressed("ui_left") and id:
		id -= 1
	if Input.is_action_just_pressed("ui_right") and id < maxv - 1:
		id += 1
	if Input.is_action_just_pressed("ui_down") and id + 7 < maxv:
		id += 7
	if Input.is_action_just_pressed("ui_up") and id > 6:
		id -= 7
	
	selector.rect_position = Vector2(32 * (id % maxv), 40*(id / maxv))
	return id


func switch_visibility(slogans: bool):
	whattodo.visible = !whattodo.visible
	selector.visible = !selector.visible
	sloganlist.visible = slogans
	objectlist.visible = !slogans


func get_rand():
	var tmp = ResourceLoader.load("res://NPC/tmp.tres")
	var dim = len(tmp.slogans_for_battle)
	var n = randi() % dim
	return tmp.slogans_for_battle[n]


#func set_npc_slogans(slogan_list):
#	enemy_slogans = slogan_list
func set_npc_weapons(weapon, shots):
	enemy_weapon = weapon
	enemy_shots = shots


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
		menu.party.total_votes += votes
		menu.party.political_pos = (menu.party.political_pos + enemy_political_pos)/2
		
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
	margincontainer.visible = false
	
	npcAttack(enemy_weapon, enemy_shots)
	
	damage(p_attack)
	
#	if npcBar.value:
#		margincontainer.visible = false
	
#		turn = TURN.PLAYER
#		battle_ui = BATTLE_UI.MENU
	
#		slogButton.grab_focus()
#	else:
#		battle_ends(!npcBar.value)
#	npcAttack(enemy_slogans[randi() % len(enemy_slogans) - 1])


func npcAttack(weapon, shots):
	turn = TURN.ENEMY
	$BattleBox.set("attacking", true)
	yield($BattleBox.generate(weapon, shots), "completed")
	$BattleBox.set("attacking", false)
	yield(get_tree().create_timer(1), "timeout")
#	damage(p_attack)

	if npcBar.value:
		turn = TURN.PLAYER
		battle_ui = BATTLE_UI.MENU
		slogButton.grab_focus()
	else:
		battle_ends(!npcBar.value)


func damage(p_pos: Vector2):
	var d = 10 - (enemy_political_pos.x - p_pos.x) + 10 - (enemy_political_pos.y - p_pos.y)
#	if d < 0:
#		pBar.value -= d
#		pLabel.text = pBar.value
#	else:
	npcBar.value -= d


func end(scene):
	scenemanager.start_transition("res://Scenes/" + scene + ".tscn", player_pos)
	# current_enemy.battle_won = true
