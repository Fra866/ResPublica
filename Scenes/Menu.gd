extends Node2D
export(Resource) var party

onready var menulayers = $MenuLayers
onready var main_menu = $MenuLayers/MainMenu
onready var slogan_menu = $MenuLayers/Slogans
onready var battle_menu = $MenuLayers/Slogans/BattleSlogans
onready var object_menu = $MenuLayers/Objects
onready var party_menu = $MenuLayers/Party
onready var mafia_menu = $MenuLayers/Mafia

onready var mafiometer = $MenuLayers/Mafia/Mafiometer
onready var m_line = $MenuLayers/Mafia/Mafiometer/Line2D

onready var no_slog_text = $MenuLayers/Slogans/NoSloganText
onready var no_obj_text = $MenuLayers/Objects/NoObjectText
onready var no_party_text = $MenuLayers/Party/NoPartyText
onready var political_compass_party = $MenuLayers/Party/PoliticalCompass

onready var mafia_displayer = $MenuLayers/Mafia/DescriptionDisplayer

onready var ui = get_node("/root/SceneManager/UI")

onready var player = get_node(NodePath('..')).find_node('Player')
onready var screentransition = get_node(NodePath('/root/SceneManager'))
onready var currentscene = get_node(NodePath('/root/SceneManager/CurrentScene'))

onready var party_compass = $MenuLayers/Party/PoliticalCompass

onready var voter_info = $MenuLayers/Party/VoterInfo

onready var voter_info_buttons = [
	$MenuLayers/Party/VoterInfo/Expell,
	$MenuLayers/Party/VoterInfo/Promote
]

onready var voter_name = $MenuLayers/Party/VoterInfo/Node2D/RichTextLabel
onready var voter_sprite = $MenuLayers/Party/VoterInfo/Node2D/Sprite

onready var current_menu = main_menu
var menu_main: bool = false

#var battleslog_last_checked: int = 0
#var slog_last_checked: int = 0

var objects_open = false

onready var battleslogs: Array = [
	[],
	[],
	[],
	[],
	[],
]

onready var slogan_list: Array = []
onready var object_list: Array = []

onready var voter_list: Dictionary = {}

onready var voter_index: int = 0

var to_remove_bs: Node

onready var use_script_obj
onready var obj_type
onready var obj_node
onready var open_obj_id: int = -1

onready var i=0
onready var buttons = [
	$MenuLayers/MainMenu/Control/SlogBtn,
	$MenuLayers/MainMenu/Control/ObjBtn,
	$MenuLayers/MainMenu/Control/PartyBtn,
	$MenuLayers/MainMenu/Control/MafiaBtn
]

onready var name_text = $MenuLayers/MainMenu/Control/Name

signal just_bought(slogan)


func _ready():
	screentransition.connect("new_main_scene", self, "new_p")
	no_slog_text.visible = false
	
	var save_file = screentransition.save_file
	name_text.text = save_file.name
	
	party = save_file.player_party
	
	for slogan_res in save_file.slogans:
		new_slogan(slogan_res)
	
	print(save_file.battleslogs)
	
	var i=0
	for bs_list in save_file.battleslogs:
		for slogan in bs_list:
		
			battleslogs[i].append(slogan)
			battle_menu.new_battleslog(
				slogan, 
				slogan_menu.battle_menu.containers[i].size + 1,
				i
			)
		i += 1
	
	for object_res in save_file.objects:
		new_object(object_res)
	for voter in save_file.voters:
		new_voter(save_file.voters[voter])
	

	slogan_menu.ms_yes.connect("pressed", self, "_on_Yes_pressed")
	slogan_menu.ms_no.connect("pressed", self, "_on_No_pressed")
	

func _process(_delta):
	if menu_main:
		buttons[i].grab_focus()
		
		if Input.is_action_just_pressed("ui_down"):
			if i != 3:
				i += 1
		if Input.is_action_just_pressed("ui_up"):
			if i != 0:
				i -= 1
		
	else:
		if Input.is_action_just_pressed("ui_end"):
			if voter_info.visible:
				voter_info.visible = false
			elif current_menu != main_menu and open_obj_id == -1:
				to_menu(current_menu, main_menu)
	
		if current_menu == slogan_menu:
			if len(slogan_list):
				if Input.is_action_just_pressed("ui_left"):
					slogan_menu.handle_input(0)
				if Input.is_action_just_pressed("ui_right"):
					slogan_menu.handle_input(1)
					
				if Input.is_action_just_pressed("ui_up"):
					slogan_menu.toggle_battleslog(false)
				if Input.is_action_just_pressed("ui_down"):
					slogan_menu.toggle_battleslog(true)
				
				if Input.is_action_just_pressed("ui_accept"):
					slogan_menu.prompt_manage_slogs()
		
		if current_menu == mafia_menu:
			if len(battleslogs) and len(voter_list):
				mafia_menu.handle_input()
		
				if Input.is_action_just_pressed("ui_accept"):
					mafia_menu.container.current_el.set_mafia_target(-10)
		
		if current_menu == object_menu:
			if len(object_list):
				obj_node = object_menu.container.current_el.res
				if Input.is_action_just_pressed("ui_left"):
					object_menu.handle_input(0)
				if Input.is_action_just_pressed("ui_right"):
					object_menu.handle_input(1)
				
				if Input.is_action_just_pressed("ui_accept"):
					if (open_obj_id != obj_node.id):
						use_script_obj = obj_node.use_script
						obj_type = load(use_script_obj.get_path()).new()
						obj_type._ready()
						add_child(obj_type.wrapper)
						obj_type.foo(obj_node.id)
						open_obj_id = obj_node.id
					else:
						remove_child(get_child(1))
						open_obj_id = -1
		
		if current_menu == party_menu:
			if len(voter_list):
				if Input.is_action_just_pressed("ui_left"):
					party_menu.handle_input(0)
				if Input.is_action_just_pressed("ui_right"):
					party_menu.handle_input(1)
				
				var voter = party_menu.container.current_el
				
				voter_name.text = voter.npc_name
				voter_sprite.texture = voter.texture
				
				party_compass.enemy_pointer_visible(true)
				party_compass.set_enemy_pointer(voter.political_pos.x, -voter.political_pos.y)
				
				if Input.is_action_just_pressed("ui_accept"):
					if !voter_info.visible:
						to_voter_info()


func to_menu(src: Node, dest: Node):
	src.visible = false
	dest.visible = true
	current_menu = dest
	menu_main = dest == main_menu


func to_voter_info():
	voter_info.visible = true
	
	voter_info_buttons[0].grab_focus()


func priority_to_menu():
	visible = true
	menu_main = true
	menulayers.position = player.position


func priority_to_player():
	if current_menu == main_menu:
		visible = false
		menu_main = false
		return true
	return false


func new_p():
	player = currentscene.get_children().back().find_node("Player")


func slide_mafia_line(mafia_points: float):
	mafia_points /= 2
	m_line.points[0][0] += mafia_points
	m_line.points[1][0] += mafia_points


func new_slogan(slogan: SloganResource):
	if slogan in slogan_list:
		emit_signal("just_bought", slogan)
		return
	
	slogan_list.append(slogan)
	ui.add_money(-slogan.prize)
	
	var pos = Vector2(
		32 * (slogan_menu.slog_cont.size % 6) + 15,
		40 * int(slogan_menu.slog_cont.size / 6)+ 20
	)
	var new_slog_instance = slogan_menu.slog_cont.new_item(pos, slogan)
	slogan_menu.slog_cont.add(new_slog_instance)


func has_battleslogs():
	for period in battleslogs:
		if len(period):
			return true
	return false


func remove_battleslog(element, index: int):
	slogan_menu.battle_cont.remove(element)
	battleslogs.remove(index)
	reload_battleslogs_pos()


func new_object(object):
	if not object in object_list:
		object_list.append(object)
		ui.add_money(-object.prize)
		
		var pos = Vector2(
			32 * (object_menu.container.size % 6) + 15,
			40*(int(object_menu.container.size / 6)) + 20
		)
		var new_obj_instance = object_menu.container.new_item(pos)
		new_obj_instance.res = object
		object_menu.container.add(new_obj_instance)


func reload_voters_menu(i: int = -1):
	for v in party_menu.container.get_items():
		if (i >= 0):
			print(v.npc_name, " -> ", v.position)
			v.position = Vector2(32 * (i % 4) + 5, 40 * (i / 4) + 18)
		i += 1


func reload_battleslogs_pos(i: int = 0):
	for battleslog in slogan_menu.battle_cont.get_items():
		battleslog.position = Vector2(30 * (i % 2) + 35, 40*(i / 2) + 15)
		i += 1


func new_voter(voter):
	if not voter_list.has(voter.npc_name):
		var pos = Vector2(
			32 * (party_menu.container.size % 4) + 5,
			40 * (party_menu.container.size / 4) + 18
		)
		
		voter.position = pos
		voter.scale = Vector2(0.53, 0.52)
		
		party_menu.container.new_item(pos)
		var new_voter = voter.duplicate()
		voter_list[voter.npc_name] = new_voter
		add_voter_to_menu(new_voter)


func add_voter_to_menu(voter):
	party_menu.container.add(voter)
	mafia_menu.container.add(voter.duplicate())


func _on_SlogBtn_pressed(node):
	to_menu(main_menu, get_node(node))
	no_slog_text.visible = !slogan_menu.slog_cont.size
	slogan_menu.slog_cont.shows(len(slogan_list))


func _on_ObjBtn_pressed(node):
	to_menu(main_menu, get_node(node))
	no_obj_text.visible = !object_menu.container.size
	object_menu.container.shows(len(object_list))


func _on_PartyBtn_pressed(node):
	to_menu(main_menu, get_node(node))
	no_party_text.visible = !party
	party_menu.container.shows(len(voter_list))
	political_compass_party.visibility(party!=null)
	if party:
		political_compass_party.set_main_pointer(party.political_pos.x, -party.political_pos.y)
		political_compass_party.show_damage_area(false)


func _on_MafiaBtn_pressed(node):
	to_menu(main_menu, get_node(node))

	mafia_displayer.visible = mafia_menu.container.size
	mafiometer.visible = mafia_menu.container.size
	mafia_menu.container.shows(mafia_menu.container.size)


func voter_left_party(voterToRemove):
	party.removeVoter(voterToRemove.political_pos, party_menu.container.size, voterToRemove.votes)
	party_menu.container.remove(voterToRemove)
	
	party_compass.set_main_pointer(party.political_pos.x, -party.political_pos.y)
	print("Voter after remove ",  party_menu.container.get_items())
	
	party_menu.reload_voters_menu()


func _on_Expell_pressed():
	voter_left_party(party_menu.container.current_el)
	voter_info.visible = false


func _on_Promote_pressed():
	pass


func _on_Yes_pressed():
	# Leave this to BattleMenu's functions.
	if !slogan_menu.state:
		var slog_period = slogan_menu.slog_cont.current_el.get_ideology(0).period1
		
#		if slog_period == 0:
#			slog_period = slogan_menu.battle_menu.state
		
		if (!(slogan_menu.slog_cont.current_el in battleslogs[slog_period])):
			var current_slog = slogan_menu.slog_cont.current_el
			battleslogs[slog_period].append(current_slog)
			battle_menu.new_battleslog(current_slog, len(battleslogs[slog_period]), slog_period)
	else:
		slogan_menu.battle_cont.remove(slogan_menu.battle_cont.current_el)
		battleslogs[slogan_menu.battle_menu.state].remove(slogan_menu.battle_cont.index)
		reload_battleslogs_pos()
	
	slogan_menu.manage_slogs.visible = false


func _on_No_pressed():
	slogan_menu.manage_slogs.visible = false
