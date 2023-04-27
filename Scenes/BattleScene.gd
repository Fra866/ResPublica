extends Node2D

onready var scenemanager = get_node(NodePath('/root/SceneManager/'))
onready var menu = get_node(NodePath('/root/SceneManager/Menu'))
onready var dialogue_box = get_node(NodePath('/root/SceneManager/DialogBox'))
onready var ui = get_node(NodePath('/root/SceneManager/UI'))

onready var whattodo = $BattleMenu/WhatToDo/
onready var slogButton = $BattleMenu/WhatToDo/Panel/Container/Slogans
onready var objButton = $BattleMenu/WhatToDo/Panel/Container/Objects
onready var captureButton = $BattleMenu/WhatToDo/Panel/Container/Capture
onready var quitButton = $BattleMenu/WhatToDo/Panel/Container/Quit

onready var buttonlist = [slogButton, objButton, captureButton, quitButton]

onready var pBar = $LifeBars/PlayerBar
onready var npcBar = $LifeBars/NPCBar

onready var sloganlist = $BattleMenu/Slogans
onready var objectlist = $BattleMenu/Objects

onready var battlemenu = $BattleMenu
onready var selector = $BattleMenu/Selector/SelectorBackground
onready var margincontainer = $ActionLog/MarginContainer
onready var action_log = $ActionLog/MarginContainer/Panel/Label

onready var enemy_sprite = $EnemySprite
onready var battlebox = $BattleBox

onready var n_of_slogans = 0
onready var n_of_objects = 0

onready var max_slogans = 8
onready var max_objects = 8

onready var enemy_area: Array

onready var priority = true
onready var attacks_list: Array
var id = 0
var next_scene = ""
var next_pos: Vector2
var player_pos = Vector2(0, 0)

onready var attacking = false

onready var first_attack_player = true
onready var first_attack_enemy = true

enum TURN {PLAYER, ENEMY, ATTACKING}
enum BATTLE_UI {SLOGANS, OBJECTS, EXIT, MENU}

onready var turn = TURN.PLAYER
onready var battle_ui = BATTLE_UI.MENU


func _ready():
	randomize()
	ui.visibility(false)
	enemy_sprite.texture = load("res://UI/andreotti/battle.png")
	
	pBar.value = int(ui.hp.text)
	
	pBar.get_child(0).text = str(pBar.value)
	battlebox.visible = true
	
	dialogue_box.connect("npc_attacks", self, "set_attacks")
	dialogue_box.connect("next_scene", self, "set_next_scene")
	dialogue_box.connect("send_npc", self, "set_npc")
	
	sloganlist.visible = false
	objectlist.visible = false
	
	slogan_setup()
	object_setup()
	
	slogButton.grab_focus()
	
	print("READY - menu.battleslogans == ", menu.battleslogs)


func slogan_setup():
	for slogan_res in menu.battleslogs:
		var new_slog_instance = load("res://Scenes/UI_Objects/SloganNode.tscn").instance()
		
		new_slog_instance.slogan_res = slogan_res
		new_slog_instance.visible = true
		
		n_of_slogans += 1
		
		var x = 12 + 32 * (n_of_slogans % max_slogans)
		if x == 12:
			x += 32
		var y = 106 + 40*(int(n_of_slogans / (max_slogans+1)))

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
			var y = 106 + 40*(int(n_of_objects / (max_objects + 1)))

			new_obj_instance.position = Vector2(x, y)
			new_obj_instance.scale = Vector2(1.3, 1.3)
			objectlist.add_child(new_obj_instance)


func _process(_delta):
	if turn == TURN.ATTACKING:
		whattodo.visible = false
		selector.visible = false
		sloganlist.visible = false
		objectlist.visible = false
		
		if Input.is_action_pressed("ui_left"):
			battlebox.move_pointer(Vector2(-1, 0))
		if Input.is_action_pressed("ui_right"):
			battlebox.move_pointer(Vector2(1, 0))
		if Input.is_action_pressed("ui_down"):
			battlebox.move_pointer(Vector2(0, 1))
		if Input.is_action_pressed("ui_up"):
			battlebox.move_pointer(Vector2(0, -1))
	
	else:
		if battle_ui == BATTLE_UI.MENU:
			battlebox.visible = false
			selector.visible = false
			sloganlist.visible = false
			objectlist.visible = false
			whattodo.visible = true
			
			if Input.is_action_just_pressed("ui_accept"):
				print("ui_accept MENU")
				
				if !slogButton.has_focus() && !objButton.has_focus() && captureButton.has_focus() && quitButton.has_focus():
					slogButton.grab_focus()
				
				if slogButton.has_focus():
					battle_ui = BATTLE_UI.SLOGANS
					#switch_visibility(false)
				elif objButton.has_focus():
					battle_ui = BATTLE_UI.OBJECTS
				elif captureButton.has_focus():
					capture_enemy()
					#switch_visibility(false)
				elif quitButton.has_focus():
					battle_ui = BATTLE_UI.EXIT
					#switch_visibility(false)
				
				switch_visibility(false)
				
		elif battle_ui == BATTLE_UI.SLOGANS:
			battlebox.visible = false
			sloganlist.visible = true
			
			if turn == TURN.PLAYER:
				var slog = menu.slogan_list[id]
				id = handle_input(id, n_of_slogans, selector)
				
				margincontainer.visible = true
				action_log.text = slog.name
				
				if Input.is_action_just_pressed("ui_accept"):
					playerAttack(menu.slogan_list[id])
		
		elif battle_ui == BATTLE_UI.OBJECTS:
			if bool(n_of_objects):
				id = handle_input(id, n_of_objects, selector)
				if Input.is_action_just_pressed("ui_accept"):
					pass
	
		elif battle_ui == BATTLE_UI.EXIT:
			battle_ends(0)
	
		if Input.is_action_just_pressed("ui_end"):
			battle_ui = BATTLE_UI.MENU
			margincontainer.visible = false
			id = 0
			slogButton.grab_focus()


func handle_input(index, maxv, select):
	if Input.is_action_just_pressed("ui_left") and index:
		index -= 1
	if Input.is_action_just_pressed("ui_right") and index < maxv - 1:
		index += 1
	if Input.is_action_just_pressed("ui_down") and index + 7 < maxv:
		index += 7
	if Input.is_action_just_pressed("ui_up") and index > 6:
		index -= 7
	
	select.rect_position = Vector2(32 * (index % maxv), 40*(index / maxv))
	return index


func switch_visibility(slogans: bool):
	whattodo.visible = !whattodo.visible
	selector.visible = !selector.visible
	sloganlist.visible = slogans
	objectlist.visible = !slogans


#func get_rand():
#	var tmp = ResourceLoader.load("res://NPC/tmp.tres")
#	var dim = len(tmp.slogans_for_battle)
#	var n = randi() % dim
#	return tmp.slogans_for_battle[n]


func set_attacks(attack_ids_list):
	attacks_list = attack_ids_list


func set_next_scene(scene: String, p_pos: Vector2):
	next_scene = scene
	next_pos = p_pos


func set_npc(current_npc):
#	print(current_npc)
	enemy_sprite.init(current_npc, true)
	enemy_sprite.npc_name = current_npc.name
#	enemy_sprite.npc_desc = current_npc.description
	enemy_sprite.sex = current_npc.sex
	enemy_sprite.max_hp = current_npc.max_hp
	enemy_sprite.votes = current_npc.votes
	enemy_sprite.texture = load(current_npc.battle_sprite_path)
	enemy_sprite.political_pos = current_npc.political_pos
	enemy_sprite.mafia_points = current_npc.mafia_points
	enemy_sprite.mafia_target = current_npc.mafia_target
	
	npcBar.value = enemy_sprite.max_hp
	npcBar.max_value = enemy_sprite.max_hp


func playerAttack(slogan):
	if slogan.xp > 0:
		slogan.xp -= 1
	
		attacking = true
	
		turn = TURN.ATTACKING
		action_log.text = "Hai usato " + slogan.name
	
		margincontainer.visible = true
		yield(get_tree().create_timer(1), "timeout")
	
		damage(slogan)
	
		if npcBar.value:
			margincontainer.visible = false
			npcAttack()
		else:
			battle_ends(!npcBar.value)


func npcAttack():
	turn = TURN.ATTACKING
	battlebox.reset_pointer()
	battlebox.visible = true
	yield(battlebox.generate(attacks_list), "completed")

	yield(get_tree(), "idle_frame")
	battle_ui = BATTLE_UI.MENU
	slogButton.grab_focus()
	turn = TURN.PLAYER


func calc(ideologies1, ideologies2, slogan):
	var level=1; # To add as an UI parameter.
	# Power is the move's level basically.
	# Stab = same-type attack move
	var stab = int(ideologies1[0] == ideologies2[0]) + 1
	var id1 = ideologies1[0]
	var id2 = ideologies2[0]
	# Define move effectiveness
	# ToDo: calculate it for each ideology
	var extra_damage = 1
	
	if (id1.xOr == id2.xOr && id1.xOr != 2 && id2.xOr != 2):
		extra_damage += 0.4
	if (id1.yOr == id2.yOr && id1.yOr != 2 && id2.yOr != 2):
		extra_damage += 0.4
	
	if (id1.id == id2.id):
		extra_damage = 2;
	
	print("ED: ", extra_damage)
	
	return ((((2*level)/5+2)*slogan.power*(slogan.att/enemy_sprite.def))/2)*stab*extra_damage


func damage(slogan):
	var dam: int = 0;
	dam = calc(slogan.ideologies, enemy_sprite.ideologies, slogan)
	print("DAMAGE = ", dam)
	
	npcBar.value -= dam;


func capture_enemy():
	if npcBar.value <= 15:
		action_log.text = enemy_sprite.npc_name + " è entrato nel tuo partito."
		margincontainer.visible = true
		battlemenu.visible = false
		yield(get_tree().create_timer(1), "timeout")
		action_log.text = "Hai ottenuto " + str(enemy_sprite.votes) + " voti."
		yield(get_tree().create_timer(1), "timeout")
		
		menu.new_voter(enemy_sprite)
		menu.party.votes += enemy_sprite.votes
		ui.loadVotes(menu.party.votes)
		menu.party.political_pos = (menu.party.political_pos + enemy_sprite.political_pos)/2
		menu.slide_mafia_line(enemy_sprite.mafia_points)
		
		battle_ends(true)
	else:
		action_log.text = enemy_sprite.npc_name + " non è entrato nel tuo partito."
		margincontainer.visible = true
		battlemenu.visible = false
		
		var timer = Timer.new()
		add_child(timer)
		timer.start(1)
		yield(timer, "timeout")
		
		margincontainer.visible = false
		battlemenu.visible = true
		
		slogButton.grab_focus()
		
		turn = TURN.PLAYER
		battle_ui = BATTLE_UI.MENU


func battle_ends(_victory):
	ui.hp.text = str(pBar.value)
	action_log.text = "Battaglia finita."
	margincontainer.visible = true
	battlemenu.visible = false
	
	var timer = Timer.new()
	add_child(timer)
	timer.start(2)
	yield(timer, "timeout")
	
	ui.visibility(true)
	
	end(next_scene)
	
	
	# scenemanager.start_transition("scene_path", Vector2(0,0))


func end(scene):
	scenemanager.start_transition("res://Scenes/GameLocations/" + scene + ".tscn", next_pos)
	# current_enemy.battle_won = true
