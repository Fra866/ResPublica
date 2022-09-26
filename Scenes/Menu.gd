extends Node2D

export(int) var state = 1
export(Resource) var party

onready var menulayers = $MenuLayers
onready var sprite = $MenuLayers/MainMenu/Sprite
onready var control = $MenuLayers/MainMenu/Control

onready var menus = [$MenuLayers/Party, $MenuLayers/Mafia, $MenuLayers/Slogans, $MenuLayers/Objects]

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

onready var current_slog
onready var current_object

enum MENU_STATE {PARTY, MAFIA, SLOGANS, OBJECTS}
var menu_state: int = 4

var menu_main: bool = false

var slogan_index: int = 0
var object_index: int = 0
var voter_index: int = 0
var mafia_index: int = 0

onready var slogan_list: Array = []
onready var object_list: Array = []
onready var voter_list: Array = []


func _ready():
	screentransition.connect("new_main_scene", self, "new_p")
	no_slog_text.visible = false
	
	var save_file = screentransition.save_file
	party = save_file.player_party
	
	for slogan_res in save_file.slogans:
		new_slogan(slogan_res)
	for object_res in save_file.objects:
		new_object(object_res)
	for voter in save_file.voters:
		new_voter(voter)


func _process(_delta):
	n_of_slogans = slogan_container.get_child_count() - 1
	n_of_objects = objects_container.get_child_count() - 1
	n_of_voters = voters_container.get_child_count() - 1
	
	player = get_node(NodePath('..')).get_child(0).get_children().back().find_node("Player")
	currentscene = get_node(NodePath('/root/SceneManager/CurrentScene')).get_child(0)
	
	
	if player:
		control.visible = menu_main
		sprite.visible = menu_main
		menulayers.position = player.position

	if menu_state == MENU_STATE.SLOGANS:
		if n_of_slogans == 0:
			no_slog_text.visible = true
			slogan_selector.visible = false
		else:
			no_slog_text.visible = false
			slogan_selector.visible = true
			current_slog = slogan_list[slogan_index]
			
			political_compass_slog.set_main_pointer(current_slog.political_pos.x, -current_slog.political_pos.y)
			political_compass_slog.set_damage_area(current_slog.damage_area)
			slogan_index = handle_input(slogan_index, n_of_slogans, slogan_selector)
			
			if Input.is_action_just_pressed("ui_accept"):
				print(current_slog.name, current_slog.political_pos)

			current_slogan_desc.text = current_slog.name

	
	if menu_state == MENU_STATE.MAFIA:
		mafia_displayer.visible = n_of_voters
		mafiometer.visible = n_of_voters
		mafia_selector.visible = mafia_displayer.visible
		
		if n_of_voters:
			var current_mv = mafia_container.get_child(mafia_index + 1)
			mafia_index = handle_input(mafia_index, n_of_voters, mafia_selector)
			current_voter_mafia_desc.text = current_mv.npc_name + "\n" + str(current_mv.mafia_target)
# Test-only function
			if Input.is_action_just_pressed("ui_accept"):
				current_mv.set_mafia_target(-10)
			
	
	if menu_state == MENU_STATE.OBJECTS:
		if n_of_objects == 0:
			no_slog_text.visible = true
			objects_selector.visible = false
		else:
			no_obj_text.visible = false
			objects_selector.visible = true
			current_object = object_list[object_index]
			current_object_desc.text = current_object.description
			object_index = handle_input(object_index, n_of_objects, objects_selector)
			
			if Input.is_action_just_pressed("ui_accept"):
				objects_container.get_child(object_index+1).foo(current_object.id) # Temporary Solution
	
	
	if menu_state == MENU_STATE.PARTY:
		voter_index = handle_input(voter_index, n_of_voters, voters_selector)
	
	
	if menu_main:
		visible = true
		if Input.is_action_just_pressed("ui_down"):
			if sprite.frame != 3:
				sprite.frame += 1
		if Input.is_action_just_pressed("ui_up"):
			if sprite.frame != 0:
				sprite.frame -= 1
		if Input.is_action_just_pressed("ui_accept"):
			to_menu(menus[sprite.frame])
			match sprite.frame:
				0:
					priority_to_party_options()
				1:
					priority_to_mafia()
				2:
					priority_to_slogans()
				3:
					priority_to_objects()


	if Input.is_action_just_pressed("ui_end") and menu_state < len(menus):
		to_main(menus[menu_state])


func to_menu(dest: Node):
	menu_main = false
	dest.visible = true
	menu_state = sprite.frame


func to_main(src: Node):
	menu_main = true
	src.visible = false
	menu_state = 4


func priority_to_party_options():
	no_party_text.visible = !party
	political_compass_party.visibility(party!=null)
	if party:
		political_compass_party.set_main_pointer(party.political_pos.x, -party.political_pos.y)
		political_compass_party.show_damage_area(false)

func priority_to_objects():
	political_compass_slog.visibility(false)


func priority_to_slogans():
	political_compass_slog.visibility(n_of_slogans)


func priority_to_mafia():
	political_compass_slog.visibility(false)


func priority_to_menu():
	menu_main = true
	state = 0


func priority_to_player():
	if menu_main:
		menu_main = false
		state = 1


func new_p():
	currentscene = get_node(NodePath('/root/SceneManager/CurrentScene'))


func slide_mafia_line(mafia_points: float):
	mafia_points /= 2
	m_line.points[0][0] += mafia_points
	m_line.points[1][0] += mafia_points


func handle_input(index: int, maxv: int, selector):
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
	return index


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
		new_voter_instance.init(voter)
#		new_voter_instance.texture = voter.texture
#		new_voter_instance.npc_name = voter.npc_name
#		new_voter_instance.npc_desc = voter.npc_desc
#		new_voter_instance.lvl = voter.lvl
#		new_voter_instance.political_pos = voter.political_pos
#		new_voter_instance.votes = voter.votes
#		new_voter_instance.popularity = voter.popularity
#		new_voter_instance.mafia_points = voter.mafia_points
		voter_list.append(new_voter_instance)
		new_voter_instance.position = Vector2(32 * (n_of_voters % 4) + 5, 40 * (n_of_voters / 4) + 18)
		n_of_voters += 1
		voters_container.add_child(new_voter_instance)
		mafia_container.add_child(new_voter_instance.duplicate())
