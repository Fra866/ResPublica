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

onready var political_compass_slog = $MenuLayers/Slogans/PoliticalCompass
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

onready var n_of_slogans: int
onready var n_of_objects: int
onready var n_of_voters: int

onready var current_el = null

enum MENU_STATE {SLOGANS, OBJECTS, PARTY, MAFIA}
var menu_state: int = 4

var menu_main: bool = false
var index: int = 0

var objects_open = false

onready var slogan_list: Array = []
onready var object_list: Array = []
onready var voter_list: Array = []

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


func _ready():
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
	n_of_voters = len(voter_list)

	if menu_main:
		buttons[i].grab_focus()
#		visible = true
		
		if Input.is_action_just_pressed("ui_down"):
			if i != 3:
				i += 1
		if Input.is_action_just_pressed("ui_up"):
			if i != 0:
				i -= 1
		if Input.is_action_just_pressed("ui_accept"):
			to_menu(menus[i])
			
	else:
		if Input.is_action_just_pressed("ui_end"):
			if menu_state < 4 and open_obj_id == -1:
				to_main(menus[menu_state])
	
		if menu_state == MENU_STATE.SLOGANS:
			if n_of_slogans:
				current_el = slogan_list[index]
				current_slogan_desc.text = current_el.name
				political_compass_slog.set_main_pointer(current_el.political_pos.x, -current_el.political_pos.y)
				political_compass_slog.set_damage_area(current_el.damage_range)
				handle_input(n_of_slogans, slogan_selector)
				
				if Input.is_action_just_pressed("ui_accept"):
					print(current_el.name, current_el.political_pos)

#Remove any object effect still visible while closing the menu
#		if (get_child(1)):
#			remove_child(get_child(1))

		if menu_state == MENU_STATE.MAFIA:
			if n_of_voters:
				current_el = mafia_container.get_child(index + 1)
				handle_input(n_of_voters, mafia_selector)
				current_voter_mafia_desc.text = current_el.npc_name + "\n" + str(current_el.mafia_target)
		# Test-only function
				if Input.is_action_just_pressed("ui_accept"):
					current_el.set_mafia_target(-10)


		if menu_state == MENU_STATE.OBJECTS:
			if n_of_objects:
#				Reading from list so to directly get object's script (line 153)
				obj_node = object_list[index]
				current_object_desc.text = obj_node.description
				handle_input(n_of_objects, objects_selector)
				
				if Input.is_action_just_pressed("ui_accept"):
					if (open_obj_id != obj_node.id):
#						use_script_obj = obj_node.object.game_object_resource.use_script
						use_script_obj = obj_node.use_script
						obj_type = load(use_script_obj.get_path()).new()
						obj_type._ready()
					
					# Standard object's function foo() returns an effect (here, mail wrapper)
					# May also be null for battle objects or stuff like that
					# The effect becomes part of the tree node
#						add_child(obj_type.foo(obj_node.id))
#Fails since script calls wrapper's 'fore returning it, hence:
						add_child(obj_type.wrapper)
						obj_type.foo(obj_node.id)
						open_obj_id = obj_node.id
					else:
						remove_child(get_child(1))
						open_obj_id = -1


		if menu_state == MENU_STATE.PARTY:
			handle_input(n_of_voters, voters_selector)

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
		print("Già comprato: ", slogan_list)
	else:
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


func new_voter(voter):
	if not voter in voter_list:
		
		var new_voter_instance = load("res://Scenes/EnemySprite.tscn").instance()
#		new_voter_instance.init(voter)
#		new_voter_instance.texture = voter.texture
#		new_voter_instance.npc_name = voter.npc_name
#		new_voter_instance.npc_desc = voter.npc_desc
#		new_voter_instance.lvl = voter.lvl
#		new_voter_instance.political_pos = voter.political_pos
#		new_voter_instance.votes = voter.votes
#		new_voter_instance.popularity = voter.popularity
#		new_voter_instance.mafia_points = voter.mafia_points
		new_voter_instance = voter.duplicate()
		voter_list.append(new_voter_instance)
		new_voter_instance.position = Vector2(32 * (n_of_voters % 4) + 5, 40 * (n_of_voters / 4) + 18)
		n_of_voters += 1
		voters_container.add_child(new_voter_instance)
		mafia_container.add_child(new_voter_instance.duplicate())


func _on_SlogBtn_pressed():
	political_compass_slog.visibility(n_of_slogans)
	no_slog_text.visible = !n_of_slogans
	slogan_selector.visible = n_of_slogans


func _on_ObjBtn_pressed():
	political_compass_slog.visibility(false)
	no_slog_text.visible = !n_of_objects
	objects_selector.visible = n_of_objects


func _on_PartyBtn_pressed():
	no_party_text.visible = !party
	political_compass_party.visibility(party!=null)
	if party:
		political_compass_party.set_main_pointer(party.political_pos.x, -party.political_pos.y)
		political_compass_party.show_damage_area(false)


func _on_MafiaBtn_pressed():
	political_compass_slog.visibility(false)
	mafia_displayer.visible = n_of_voters
	mafiometer.visible = n_of_voters
	mafia_selector.visible = mafia_displayer.visible
