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
onready var battlebox = $BattleBox

onready var n_of_slogans = 0
onready var n_of_objects = 0

onready var max_slogans = 8
onready var max_objects = 8

onready var enemy_political_pos: Vector2
onready var enemy_area: Array
onready var votes: int

onready var priority = true
onready var attacks_list: Array
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
	
	battlebox.visible = true
	
	dialogue_box.connect("npc_attacks", self, "set_attacks")
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
	# political_compass.visibility(!battlebox.visible)
	
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
		
		if Input.is_action_just_pressed("ui_accept"):
			pass
	
	else:
		if battle_ui == BATTLE_UI.MENU:
			
			battlebox.visible = false
			selector.visible = false
			sloganlist.visible = false
			objectlist.visible = false
			whattodo.visible = true
			
			if Input.is_action_just_pressed("ui_accept"):
				if slogButton.has_focus():
					switch_visibility(true)
					political_compass.visibility(true)
					battle_ui = BATTLE_UI.SLOGANS
				elif objButton.has_focus():
					switch_visibility(false)
					battle_ui = BATTLE_UI.OBJECTS
				elif quitButton.has_focus():
					battle_ui = BATTLE_UI.EXIT
					
		elif battle_ui == BATTLE_UI.SLOGANS:
			political_compass.visible = true
			battlebox.visible = false
			
			if turn == TURN.PLAYER:
				var slog = menu.slogan_list[id]
				id = handle_input(id, n_of_slogans, selector)
				political_compass.set_line(political_compass.get_main_pointer() ,slog.political_pos.x, -slog.political_pos.y)
				political_compass.set_damage_area(slog.damage_area)
				
				if Input.is_action_just_pressed("ui_accept"):
					playerAttack(menu.slogan_list[id])
				
		elif battle_ui == BATTLE_UI.OBJECTS:
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


func handle_input(index, maxv, selector):
	if Input.is_action_just_pressed("ui_left") and index:
		index -= 1
	if Input.is_action_just_pressed("ui_right") and index < maxv - 1:
		index += 1
	if Input.is_action_just_pressed("ui_down") and index + 7 < maxv:
		index += 7
	if Input.is_action_just_pressed("ui_up") and index > 6:
		index -= 7
	
	selector.rect_position = Vector2(32 * (index % maxv), 40*(index / maxv))
	return index


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


func set_attacks(attack_ids_list):
	attacks_list = attack_ids_list


func set_next_scene(scene: String, p_pos: Vector2):
	next_scene = scene
	player_pos = p_pos


func set_npc(current_npc):
	votes = current_npc.votes
	enemy_sprite.texture = load(current_npc.battle_sprite_path)
	enemy_political_pos = current_npc.political_pos


func playerAttack(slogan):
	attacking = true
	political_compass.visible = false
	political_compass.set_main_pointer(slogan.political_pos.x, -slogan.political_pos.y)
	political_compass.set_enemy_pointer(enemy_political_pos.x, -enemy_political_pos.y)
	political_compass.hide_line()
	
	turn = TURN.ATTACKING
	action_log.text = "Hai usato " + slogan.name
	p_attack = slogan.political_pos
	margincontainer.visible = true
	yield(get_tree().create_timer(1), "timeout")
	
#	if damageable(p_attack):
	damage(p_attack)
	
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


func damageable(slogan: Vector2):
#	If area will instead be a circle -- [[x0, y0], radius]
#	var center = Vector2(enemy_area[0][0], enemy_area[0][1])
#	return abs(slogan - center) < enemy_area[1]
	var check_x: bool
	var check_y: bool
	
	if slogan.x <= enemy_area[0][1] and slogan.x >= enemy_area[0][0]:
		check_x = true
	if slogan.y <= enemy_area[1][1] and slogan.y >= enemy_area[1][0]:
		check_y = true

	return check_x and check_y


func extra_damage():
	# If player is also in damage area
	# Returns extra damage
	return int(Geometry.is_point_in_polygon(player_pos, political_compass.damage_area.polygon)) * 10


func damage(p_pos: Vector2):
	
	if Geometry.is_point_in_polygon(enemy_political_pos, political_compass.damage_area.polygon):
		var d = 20 - sqrt(float(pow((enemy_political_pos.x - p_pos.x), 2) + pow((enemy_political_pos.y - p_pos.y), 2)))
		d += extra_damage()
		
		npcBar.value -= d
	
	print("Enemy PolPos: ", enemy_political_pos)
	print("Damage Area: ",political_compass.damage_area.polygon)
	# print("Damagable: ", damageable(enemy_political_pos))


func battle_ends(victory):
	action_log.text = "Battaglia finita."
	margincontainer.visible = true
	battlemenu.visible = false
	
	var timer = Timer.new()
	add_child(timer)
	timer.start(2)
	yield(timer, "timeout")
	
	if victory:
		menu.party.total_votes += votes
		menu.party.political_pos = (menu.party.political_pos + enemy_political_pos)/2
		
		action_log.text = "Hai ottenuto " + str(votes) + " voti."
		yield(get_tree().create_timer(1.5), "timeout")
		ui.loadVotes(votes)
	
	end(next_scene)
	
	# scenemanager.start_transition("scene_path", Vector2(0,0))


func end(scene):
	scenemanager.start_transition("res://Scenes/" + scene + ".tscn", player_pos)
	# current_enemy.battle_won = true
