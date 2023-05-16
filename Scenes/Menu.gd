extends Node2D
export(Resource) var party

onready var menulayers = $MenuLayers
onready var main_menu = $MenuLayers/MainMenu
onready var slogan_menu = $MenuLayers/Slogans
onready var objects_menu = $MenuLayers/Objects
onready var party_menu = $MenuLayers/Party
onready var mafia_menu = $MenuLayers/Mafia

onready var slogans_container = $MenuLayers/Slogans/MainContainer
onready var battleslogs_container = $MenuLayers/Slogans/BattleSlogans/MainContainer
onready var objects_container = $MenuLayers/Objects/MainContainer
onready var mafia_container = $MenuLayers/Mafia/MainContainer
onready var voters_container = $MenuLayers/Party/MainContainer

onready var mafiometer = $MenuLayers/Mafia/Mafiometer
onready var m_line = $MenuLayers/Mafia/Mafiometer/Line2D

onready var no_slog_text = $MenuLayers/Slogans/NoSloganText
onready var no_obj_text = $MenuLayers/Objects/NoObjectText
onready var no_party_text = $MenuLayers/Party/NoPartyText
onready var political_compass_party = $MenuLayers/Party/PoliticalCompass

onready var slogans_desc_displayer = $MenuLayers/Slogans/DescriptionDisplayer
onready var objects_desc_displayer = $MenuLayers/Objects/DescriptionDisplayer
onready var mafia_displayer = $MenuLayers/Mafia/DescriptionDisplayer

onready var manage_slogans = $MenuLayers/Slogans/ManageSlogans
onready var manage_slogans_text = manage_slogans.get_child(0).get_child(0)
onready var manage_yes_btn = manage_slogans.get_child(0).get_child(1).get_child(0)
onready var manage_no_btn = manage_slogans.get_child(0).get_child(1).get_child(1)

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

enum SLOGAN_STATE {ALL, BATTLESLOGS}
var slogan_state: int = SLOGAN_STATE.ALL

onready var current_el = null

onready var current_menu = main_menu
var menu_main: bool = false

var battleslog_last_checked: int = 0
var slog_last_checked: int = 0

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
	screentransition.connect("new_main_scene", self, "new_p")
	no_slog_text.visible = false
	
	var save_file = screentransition.save_file
	name_text.text = save_file.name
	
	party = save_file.player_party
	
	for slogan_res in save_file.slogans:
		new_slogan(slogan_res)
	for slogan_res in save_file.battleslogs:
		new_battleslog(slogan_res)
	to_battleslog()
	
	for object_res in save_file.objects:
		new_object(object_res)
	for voter in save_file.voters:
		new_voter(voter)


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
			battleslogs_container.shows(slogan_state == SLOGAN_STATE.BATTLESLOGS)
			slogans_container.shows(slogan_state == SLOGAN_STATE.ALL)
			
			if slogans_container.size and slogan_state == SLOGAN_STATE.ALL:
				current_el = slogans_container.current_el.res
				
				if !manage_slogans.visible:
					handle_input(slogans_container)
					
					if Input.is_action_just_pressed("ui_down"):
						to_battleslog()
				
					if Input.is_action_just_pressed("ui_accept"):
						if not current_el in battleslogs && len(battleslogs) < 4:
							prompt_manage_slogs("Sia '" + current_el.name + "' slogan di battaglia?")
				
			
			elif slogan_state == SLOGAN_STATE.BATTLESLOGS:
				if len(battleslogs) > 0:
					current_el = battleslogs_container.current_el.res
				else:
					slogan_state = SLOGAN_STATE.ALL
				
				if !manage_slogans.visible:
					handle_input(battleslogs_container)
						
					if Input.is_action_just_pressed("ui_up"):
						battleslog_last_checked = battleslogs_container.index
						slogan_state = SLOGAN_STATE.ALL
						battleslogs_container.index = slog_last_checked
					
					if Input.is_action_just_pressed("ui_accept"):
						prompt_manage_slogs("Rimuovere '" + current_el.name + "' ?")
						if (battleslogs_container.index != 0):
							battleslogs_container.index -= 1
			
			slogans_desc_displayer.set_text(current_el.name)
		
		if current_menu == mafia_menu:
			if battleslogs_container.size and mafia_container.size:
				current_el = mafia_container.current_el
				handle_input(mafia_container)
				mafia_displayer.set_text(current_el.npc_name + "\n" + str(current_el.mafia_target))
		
				if Input.is_action_just_pressed("ui_accept"):
					current_el.set_mafia_target(-10)
		
		
		if current_menu == objects_menu:
			if objects_container.size:
				obj_node = objects_container.current_el.res
				objects_desc_displayer.set_text(obj_node.description)
				handle_input(objects_container)
				
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
			if voters_container.size > 0:
				handle_input(voters_container)
				
				var voter = voters_container.current_el
				
				voter_name.text = voter.npc_name
				voter_sprite.texture = voter.texture
				
				party_compass.enemy_pointer_visible(true)
				party_compass.set_enemy_pointer(voter.political_pos.x, -voter.political_pos.y)
				
				if Input.is_action_just_pressed("ui_accept"):
					if !voter_info.visible:
						to_voter_info()


func prompt_manage_slogs(prompt: String):
	manage_slogans_text.text = prompt
	manage_slogans.visible = true
	manage_yes_btn.grab_focus()


func to_battleslog():
	if len(battleslogs):
		slog_last_checked = slogans_container.index
		slogan_state = SLOGAN_STATE.BATTLESLOGS
		battleslogs_container.index = battleslog_last_checked


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


func handle_input(container):
	var pos: Vector2
	var index = container.index
	if container == slogans_container or container == objects_container:
		pos = Vector2(32 * (index % 6) + 3, 40 * (index / 6) + 9)
	elif container == battleslogs_container:
		pos = Vector2(32 * (index % 2) + 23, 40 * (index / 2) + 3)
	else:
		pos = Vector2(32 * (index % 4) + 3, 40 * (index / 4) + 16)
	container.move(pos)


func new_slogan(slogan: SloganResource):
	if slogan in slogan_list:
		emit_signal("just_bought", slogan)
		return
	
	slogan_list.append(slogan)
	ui.add_money(-slogan.prize)
	
	var pos = Vector2(
		32 * (slogans_container.size % 6) + 15,
		40*int(slogans_container.size / 6)+ 20
	)
	var new_slog_instance = slogans_container.new_item(pos, slogan)
	slogans_container.add(new_slog_instance)


func new_battleslog(element: Node):
	battleslogs.append(element)
	var pos = Vector2(
		30 * ((len(battleslogs) - 1) % 2) + 35,
		40*((len(battleslogs) - 1) / 2) + 15
	)
	var new_slog_instance = battleslogs_container.new_item(pos, element.res)
	battleslogs_container.add(new_slog_instance)


func remove_battleslog(element, index: int):
	battleslogs_container.remove(element)
	battleslogs.remove(index)
	reload_battleslogs_menu()


func new_object(object):
	if not object in object_list:
		object_list.append(object)
		ui.add_money(-object.prize)
		
		var pos = Vector2(
			32 * (objects_container.size % 6) + 15,
			40*(int(objects_container.size / 6)) + 20
		)
		var new_obj_instance = objects_container.new_item(pos, object)
		objects_container.add(new_obj_instance)


func reload_voters_menu(i: int = -1):
	for v in voters_container.get_items():
		if (i >= 0):
			print(v.npc_name, " -> ", v.position)
			v.position = Vector2(32 * (i % 4) + 5, 40 * (i / 4) + 18)
		i += 1


func reload_battleslogs_menu(i: int = 0):
	for battleslog in battleslogs_container.get_items():
		battleslog.position = Vector2(30 * (i % 2) + 35, 40*(i / 2) + 15)
		i += 1


func new_voter(voter):
	if not voter_list.has(voter.npc_name):
		var pos = Vector2(
			32 * (voters_container.size % 4) + 5,
			40 * (voters_container.size / 4) + 18
		)
		var new_voter = voters_container.new_item(pos)
		new_voter = voter.duplicate()
		voter_list[voter.npc_name] = new_voter
		add_voter_to_menu(new_voter)


func add_voter_to_menu(voter):
	voters_container.add(voter)
	mafia_container.add(voter.duplicate())


# These 4 calls are to be further generalized.
func _on_SlogBtn_pressed(node):
	to_menu(main_menu, get_node(node))
	no_slog_text.visible = !slogans_container.size
	slogans_container.shows(slogans_container.size)


func _on_ObjBtn_pressed(node):
	to_menu(main_menu, get_node(node))
	no_obj_text.visible = !objects_container.size
	objects_container.shows(objects_container.size)


func _on_PartyBtn_pressed(node):
	to_menu(main_menu, get_node(node))
	no_party_text.visible = !party
	political_compass_party.visibility(party!=null)
	if party:
		political_compass_party.set_main_pointer(party.political_pos.x, -party.political_pos.y)
		political_compass_party.show_damage_area(false)


func _on_MafiaBtn_pressed(node):
	to_menu(main_menu, get_node(node))

	mafia_displayer.visible = mafia_container.size
	mafiometer.visible = mafia_container.size
	mafia_container.shows(mafia_container.size)


func voter_left_party(voterToRemove):
	party.removeVoter(voterToRemove.political_pos, voters_container.size, voterToRemove.votes)
	voters_container.remove(voterToRemove)
	
	party_compass.set_main_pointer(party.political_pos.x, -party.political_pos.y)
	print("Voter after remove ",  voters_container.get_items())
	
	reload_voters_menu()


func _on_Expell_pressed():
	voter_left_party(voters_container.current_el)
	voter_info.visible = false


func _on_Promote_pressed():
	pass


func _on_Yes_pressed(index):
	if slogan_state == SLOGAN_STATE.ALL:
		new_battleslog(slogans_container.current_el)
	else:
		battleslogs.remove(slogans_container.index)
		battleslogs_container.remove(battleslogs_container.current_el)
		reload_battleslogs_menu()
	
	manage_slogans.visible = false


func _on_No_pressed():
	manage_slogans.visible = false
