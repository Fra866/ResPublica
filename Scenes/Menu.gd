extends Node2D
export(Resource) var party

onready var menulayers = $MenuLayers
onready var sprite = $MenuLayers/MainMenu/Sprite
onready var control = $MenuLayers/MainMenu/Control

onready var menus = [$MenuLayers/Slogans, $MenuLayers/Objects, $MenuLayers/Party,  $MenuLayers/Mafia]

onready var slogan_container = $MenuLayers/Slogans/MainContainer
onready var objects_container = $MenuLayers/Objects/MainContainer
onready var mafia_container = $MenuLayers/Mafia/MainContainer
onready var voters_container = $MenuLayers/Party/MainContainer

onready var slogan_selector = $MenuLayers/Slogans/MainContainer/Selector
onready var objects_selector = $MenuLayers/Objects/MainContainer/Selector
onready var mafia_selector = $MenuLayers/Mafia/MainContainer/Selector
onready var voters_selector = $MenuLayers/Party/MainContainer/Selector

onready var mafiometer = $MenuLayers/Mafia/Mafiometer
onready var m_line = $MenuLayers/Mafia/Mafiometer/Line2D

onready var no_slog_text = $MenuLayers/Slogans/NoSloganText
onready var no_obj_text = $MenuLayers/Objects/NoObjectText
onready var no_party_text = $MenuLayers/Party/NoPartyText

onready var battleslogs_menu = $MenuLayers/Slogans/BattleSlogans/ColorRect/Slogans

onready var political_compass_party = $MenuLayers/Party/PoliticalCompass

onready var slogans_desc_displayer = $MenuLayers/Slogans/DescriptionDisplayer
onready var objects_desc_displayer = $MenuLayers/Objects/DescriptionDisplayer
onready var mafia_displayer = $MenuLayers/Mafia/DescriptionDisplayer

onready var current_slogan_desc = $MenuLayers/Slogans/DescriptionDisplayer/Background/InnerBackground/Text
onready var current_object_desc = $MenuLayers/Objects/DescriptionDisplayer/Background/InnerBackground/Text
onready var current_voter_mafia_desc = $MenuLayers/Mafia/DescriptionDisplayer/Background/InnerBackground/Text

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

onready var n_of_slogans: int
onready var n_of_objects: int
onready var n_of_voters: int

onready var current_el = null

enum MENU_STATE {SLOGANS, OBJECTS, PARTY, MAFIA}
var menu_state: int = 4

var menu_main: bool = false
var index: int = 0

var objects_open = false

onready var battleslogs: Array = []
onready var slogan_list: Array = []
onready var object_list: Array = []
onready var voter_list: Dictionary = {}

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
#	menu_main = true;
	
	screentransition.connect("new_main_scene", self, "new_p")
	no_slog_text.visible = false
	
	var save_file = screentransition.save_file
	name_text.text = save_file.name
	
	party = save_file.player_party
	
	for slogan_res in save_file.slogans:
		new_slogan(slogan_res)
	for object_res in save_file.objects:
		new_object(object_res)
	for voter in save_file.voters:
		new_voter(voter)


func _process(_delta):
	n_of_slogans = len(slogan_list)
	n_of_objects = len(object_list)
	n_of_voters = voter_list.size()

	if menu_main:
		buttons[i].grab_focus()
		
		for m in menus:
			m.visible=false
		
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
			elif menu_state < 4 and open_obj_id == -1:
				to_main(menus[menu_state])
	
		if menu_state == MENU_STATE.SLOGANS:
			if n_of_slogans:
				current_el = slogan_list[index]
				current_slogan_desc.text = current_el.name
				handle_input(n_of_slogans, slogan_selector)
				
				if Input.is_action_just_pressed("ui_accept"):
					if not current_el in battleslogs && len(battleslogs) < 4:
						battleslogs.append(current_el)
						
						var new_slog_instance = load(
							"res://Scenes/UI_Objects/SloganNode.tscn"
						).instance()
						new_slog_instance.slogan_res = current_el
						new_slog_instance.position = Vector2(30 * ((len(battleslogs) -1) % 2) + 35, 40*(int((len(battleslogs) -1) / 2)) + 15)
						battleslogs_menu.add_child(new_slog_instance)
					else:
						print("Is already battleSlog")
		
		
		if menu_state == MENU_STATE.MAFIA:
			if n_of_voters:
				current_el = mafia_container.get_child(index + 1)
				handle_input(n_of_voters, mafia_selector)
				current_voter_mafia_desc.text = current_el.npc_name + "\n" + str(current_el.mafia_target)
		
				if Input.is_action_just_pressed("ui_accept"):
					current_el.set_mafia_target(-10)
		
		
		if menu_state == MENU_STATE.OBJECTS:
			if n_of_objects:
				obj_node = object_list[index]
				current_object_desc.text = obj_node.description
				handle_input(n_of_objects, objects_selector)
				
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
		
		
		if menu_state == MENU_STATE.PARTY:
			n_of_voters = len(voters_container.get_children()) - 1
			if n_of_voters > 0:
				handle_input(n_of_voters, voters_selector)
				
				var voter = voters_container.get_child(index+1)
				
				voter_name.text = voter.npc_name
				voter_sprite.texture = voter.texture
				
				party_compass.enemy_pointer_visible(true)
				party_compass.set_enemy_pointer(voter.political_pos.x, -voter.political_pos.y)
				
				if Input.is_action_just_pressed("ui_accept"):
					if !voter_info.visible:
						to_voter_info()
	
	control.visible = menu_main
	sprite.visible = menu_main


func to_menu(dest: Node):
	menu_main = false
	dest.visible = true
	menu_state = i
	index = 0


func to_main(src: Node):
	menu_main = true
	src.visible = false
	menu_state = 4


func to_voter_info():
	voter_info.visible = true
	
	voter_info_buttons[0].grab_focus()


func priority_to_menu():
	menu_main = true
	visible = true
	menulayers.position = player.position


func priority_to_player():
	if menu_main:
		menu_main = false
		visible = false
		return true
	return false


func new_p():
#	currentscene = get_node(NodePath('/root/SceneManager/CurrentScene')).get_children().back()
	player = currentscene.get_children().back().find_node("Player")


func slide_mafia_line(mafia_points: float):
	mafia_points /= 2
	m_line.points[0][0] += mafia_points
	m_line.points[1][0] += mafia_points


func handle_input(maxv: int, selector):
	if Input.is_action_just_pressed("ui_right"):
		if index < maxv - 1:
			index += 1
	if Input.is_action_just_pressed("ui_left"):
		if index > 0:
			index -= 1
	if selector == slogan_selector or selector == objects_selector:
		selector.rect_position = Vector2(32 * (index % 6) + 3, 40 * (index / 6) + 9)
	else:
		selector.rect_position = Vector2(32 * (index % 4) + 3, 40 * (index / 4) + 16)
#	return index


func new_slogan(slogan):
	if slogan in slogan_list:
#		print("Già comprato: ", slogan_list)
		emit_signal("just_bought", slogan)
		return
	
	slogan_list.append(slogan)
	ui.add_money(-slogan.prize)
	
	var new_slog_instance = load("res://Scenes/UI_Objects/SloganNode.tscn").instance()
	new_slog_instance.slogan_res = slogan
	new_slog_instance.position = Vector2(32 * (n_of_slogans % 6) + 15, 40*(int(n_of_slogans / 6))+ 20)
	n_of_slogans += 1
	slogan_container.add_child(new_slog_instance)


func new_object(object):
	if not object in object_list:
		object_list.append(object)
		ui.add_money(-object.prize)
		
		var new_obj_instance = load("res://Scenes/UI_Objects/ObjectNode.tscn").instance()
		new_obj_instance.object_res = object
		new_obj_instance.position = Vector2(32 * (n_of_objects % 6) + 15, 40*(int(n_of_objects / 6)) + 20)
		n_of_objects += 1
		objects_container.add_child(new_obj_instance)


func reload_menu(i: int = -1):
	for v in voters_container.get_children():
		if (i >= 0):
			print(v.npc_name, " -> ", v.position)
			v.position = Vector2(32 * (i % 4) + 5, 40 * (i / 4) + 18)
		i += 1


func new_voter(voter):
	if not voter_list.has(voter.npc_name):
		
		var new_voter_instance = load("res://Scenes/EnemySprite.tscn").instance()
		new_voter_instance = voter.duplicate()
		voter_list[voter.npc_name] = new_voter_instance
		new_voter_instance.position = Vector2(32 * (n_of_voters % 4) + 5, 40 * (n_of_voters / 4) + 18)
		# n_of_voters += 1
		add_voter_to_menu(new_voter_instance)


func add_voter_to_menu(voter):
	voters_container.add_child(voter)
	mafia_container.add_child(voter.duplicate())


# These 4 calls are to be further generalized.
func _on_SlogBtn_pressed(node):
	to_menu(get_node(node))
#	political_compass_slog.visibility(n_of_slogans)
	no_slog_text.visible = !n_of_slogans
	slogan_selector.visible = n_of_slogans


func _on_ObjBtn_pressed(node):
	to_menu(get_node(node))
	#political_compass_slog.visibility(false)
	no_obj_text.visible = !n_of_objects
	objects_selector.visible = n_of_objects


func _on_PartyBtn_pressed(node):
	to_menu(get_node(node))
	no_party_text.visible = !party
	political_compass_party.visibility(party!=null)
	if party:
		political_compass_party.set_main_pointer(party.political_pos.x, -party.political_pos.y)
		political_compass_party.show_damage_area(false)


func _on_MafiaBtn_pressed(node):
	to_menu(get_node(node))

	mafia_displayer.visible = n_of_voters
	mafiometer.visible = n_of_voters
	mafia_selector.visible = mafia_displayer.visible


func voter_left_party(voterToRemove):
	n_of_voters -= 1
	
	# print("Voter before remove ",  voters_container.get_children())
	
	# var voterToRemove = voters_container.get_child(index+1)
	
	# reload_menu()
	
	party.removeVoter(voterToRemove.political_pos, n_of_voters, voterToRemove.votes)
	voters_container.remove_child(voterToRemove)
	
	party_compass.set_main_pointer(party.political_pos.x, -party.political_pos.y)
	print("Voter after remove ",  voters_container.get_children())
	
	reload_menu()


func _on_Expell_pressed():
	voter_left_party(voters_container.get_child(index+1))
	index = 0
	voter_info.visible = false


func _on_Promote_pressed():
	pass # Replace with function body.
