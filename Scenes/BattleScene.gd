extends Node2D

onready var scenemanager = get_node(NodePath('/root/SceneManager/'))
onready var menu = get_node(NodePath('/root/SceneManager/Menu'))
onready var slogan_menu = get_node(NodePath('/root/SceneManager/Menu/MenuLayers/Slogans'))
onready var ui = get_node(NodePath('/root/SceneManager/UI'))

onready var whattodo = $BattleMenu/WhatToDo/
onready var whattodo_container = $BattleMenu/WhatToDo/Panel/Container
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
onready var current_menu = whattodo

onready var enemy_sprite = $EnemySprite
onready var battlebox = $BattleBox

onready var n_of_slogans = 0
onready var n_of_objects = 0

onready var max_slogans = 4
onready var max_objects = 4

onready var enemy_area: Array

onready var priority = true
onready var attacks_list: Array
var id = 1
var next_scene = ""
var next_pos: Vector2
var player_pos = Vector2(0, 0)


onready var first_attack_player = true
onready var first_attack_enemy = true

enum TURN {PLAYER, ENEMY, ATTACKING}
enum BATTLE_UI {SLOGANS, OBJECTS, EXIT, MENU}

onready var turn = TURN.PLAYER
onready var battle_ui = BATTLE_UI.MENU


func _ready():
	randomize()
	
#	dialogue_box.connect("npc_attacks", self, "set_attacks")
#	dialogue_box.connect("next_scene", self, "set_next_scene")
#	dialogue_box.connect("send_npc", self, "set_npc")
	
	# By calling slogan_setup() here, it sets up the slogans
	# BEFORE obtaining the histPeriod of the enemy_sprite
	# it now sets up the slogs at the end of set_npc() [209]
	
	object_setup()
	
	sloganlist.visible = false
	objectlist.visible = false
	
	ui.visibility(false)
	enemy_sprite.texture = load("res://UI/andreotti/battle.png")
	
	pBar.value = int(ui.hp.text)
	
	pBar.get_child(0).text = str(pBar.value)
	
	slogButton.grab_focus()
	


func slogan_setup():
	for slogan_res in menu.battleslogs[enemy_sprite.period - 1]:
		n_of_slogans += 1
		
		var new_slog_instance = load("res://Scenes/UI_Objects/SloganNode.tscn").instance()
		
		new_slog_instance.res = slogan_res.res
		for ideology in new_slog_instance.res.ideologies:
			ideology.assign_params(Archive.new())
		new_slog_instance.visible = true
		
		instance_pos(new_slog_instance, n_of_slogans, max_slogans)
		sloganlist.add_child(new_slog_instance)


func object_setup():
	for object_res in menu.object_list:
		n_of_objects += int(object_res.display_on_battle)
		if object_res.display_on_battle:
			var new_obj_instance = load("res://Scenes/UI_Objects/ObjectNode.tscn").instance()
			
			new_obj_instance.res = object_res
			
			n_of_objects += 1
			
			instance_pos(new_obj_instance, n_of_objects, max_objects)
			objectlist.add_child(new_obj_instance)


func instance_pos(instance: Node, size, max_s):
	var x = 12 + 32 * (size % max_s)
	if x == 12:
		x += 32
	var y = 106 + 40 * int(size / (max_s + 1))
	
	instance.position = Vector2(x, y)
	instance.scale = Vector2(1.3, 1.3)


func change_menu(from: Node, to: Node):
	from.visible = false
	to.visible = true
	selector.visible = to != whattodo
	current_menu = to

func open_menu():
	battlebox.visible = false
	battlemenu.visible = true
	battle_ui = BATTLE_UI.MENU


func close_menu(to: Node):
	# to = BattleBox
	battlemenu.visible = false
	change_menu(current_menu, whattodo)
	to.visible = true


func _process(_delta):
	if turn == TURN.ATTACKING:
		battlebox.move_pointer(Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down"))
	
	else:
		if battle_ui == BATTLE_UI.MENU:
			if Input.is_action_just_pressed("ui_accept"):
				if !captureButton.has_focus():
					var id = whattodo_container.get_focus_owner().get_index()
					for k in BATTLE_UI.keys():
						if BATTLE_UI[k] == id:
							battle_ui = BATTLE_UI[k]
				
		elif battle_ui == BATTLE_UI.SLOGANS:
			if turn == TURN.PLAYER:
				current_menu = slogan_menu
				var slog = menu.battleslogs[enemy_sprite.period - 1][id - 1]
				selector.visible = true
				id = handle_input(id, n_of_slogans, selector)
				
				action_log.text = slog.res.name
				
				if Input.is_action_just_pressed("ui_accept"):
					battlemenu.visible = false
					change_menu(current_menu, whattodo)
					playerAttack(slog.res)
		
		elif battle_ui == BATTLE_UI.OBJECTS:
			if bool(n_of_objects):
				id = handle_input(id, n_of_objects, selector)
				if Input.is_action_just_pressed("ui_accept"):
					pass
	
		elif battle_ui == BATTLE_UI.EXIT:
			battle_ends(false)
	
		if Input.is_action_just_pressed("ui_end"):
			battle_ui = BATTLE_UI.MENU
			change_menu(current_menu, whattodo)
			margincontainer.visible = false
			id = 1
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


func set_attacks(attack_ids_list):
	attacks_list = attack_ids_list


func set_next_scene(scene: String, p_pos: Vector2):
	next_scene = scene
	next_pos = p_pos


func set_npc(current_npc):
	enemy_sprite.init(current_npc, true)
	
	npcBar.value = enemy_sprite.max_hp
	npcBar.max_value = enemy_sprite.max_hp
	
	slogan_setup()


func playerAttack(slogan):
	if slogan.xp > 0:
		slogan.xp -= 1
	
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
	battlebox.reset_pointer()
	turn = TURN.ATTACKING
	battlebox.visible = true
	yield(battlebox.generate(attacks_list), "completed")
	
	# turn = TURN.ATTACKING
	
	yield(get_tree(), "idle_frame")
	open_menu()
	slogButton.grab_focus()
	change_menu(sloganlist, whattodo)
	turn = TURN.PLAYER


func calc():
	var slogan = menu.battleslogs[enemy_sprite.period - 1][id - 1].res
	var level=1 # TODO: add as an UI parameter.
	# Power = the move's level.
	# STAM = same-type attack move
	var stam = 1
	# Define move effectiveness
	var extra_damage = 1
	
	# id1.calc_extra_damage(slogan.ideologies, enemy_sprite.ideologies)
	
	for id1 in slogan.ideologies:
		for id2 in enemy_sprite.ideologies:
			stam += int(id1 == id2)
			var xOr = id2.xOr
			var yOr = id2.xOr
			# TODO: pass the result of calc_extra_damage() to a complex type (such as Player, NPC, BS, ecc.)
			
			# This is horrible, I know it, and I could not care less.
			# I hate yield()
			# I'd rather have anti-yielders shot - Friedrich Nietzsche
			var extraX: float
			var extraY: float
			
			extraX = int(id1.xOr == id2.xOr && id1.xOr != 2 && id2.xOr != 2)
			extraY = int(id1.yOr == id2.yOr && id1.yOr != 2 && id2.yOr != 2)
			
			if (extraX == 0):
				if (id1.xOr + id2.xOr) == 1:
					extraX = 0.25
				else:
					extraX = 0.5
			
			if (extraY == 0):
				if (id1.yOr + id2.yOr) == 1:
					extraY = 0.25
				else:
					extraY = 0.5
			
			extra_damage += xOr + yOr
	
	if (enemy_sprite.def == 0):
		enemy_sprite.def = 1
	return slogan.att/enemy_sprite.def * (4*level/5 + 2) * slogan.power / 2 * stam * extra_damage


func damage(slogan):
	var dam: int = 0;
	dam = calc()
	npcBar.value -= dam;


func capture_enemy():
	if npcBar.value <= 15:
		action_log.text = enemy_sprite.npc_name + " è entrato nel tuo partito."
		yield(get_tree().create_timer(1), "timeout")
		
		action_log.text = "Hai ottenuto " + str(enemy_sprite.votes) + " voti."
		ui.add_votes(enemy_sprite.votes) # Assigns value to ui var "lvlUp"
		yield(get_tree().create_timer(1), "timeout")
		
		if ui.lvlUp:
			action_log.text = "Sei salito di livello!"
			ui.lvlUp = false
			yield(get_tree().create_timer(1), "timeout")
		
		menu.new_voter(enemy_sprite)
		menu.party.votes += enemy_sprite.votes
		ui.loadVotes(menu.party.votes)
		menu.party.political_pos = (menu.party.political_pos + enemy_sprite.political_pos)/2
		menu.slide_mafia_line(enemy_sprite.mafia_points)
		
		battle_ends(true)
	else:
		action_log.text = enemy_sprite.npc_name + " non è entrato nel tuo partito."
		
		var timer = Timer.new()
		add_child(timer)
		timer.start(1)
		yield(timer, "timeout")
		
		margincontainer.visible = false
#		battlemenu.visible = true
		
		slogButton.grab_focus()
		
		turn = TURN.PLAYER
		open_menu()


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


func end(scene):
	scenemanager.start_transition("res://Scenes/GameLocations/" + scene + ".tscn", next_pos)


func _on_Slogans_pressed():
	change_menu(whattodo, sloganlist)
	margincontainer.visible = true


func _on_Objects_pressed():
	change_menu(whattodo, objectlist)


func _on_Capture_pressed():
	close_menu(margincontainer)
	capture_enemy()
