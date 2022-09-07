extends Node2D

export(int) var state = 1
export(Resource) var party

onready var sprite = $MenuLayers/MainMenu/Sprite
onready var control = $MenuLayers/MainMenu/Control
onready var slogans = $MenuLayers/Slogans
onready var slogan_container = $MenuLayers/Slogans/MainContainer
onready var slogan_selector = $MenuLayers/Slogans/MainContainer/Selector
onready var objects = $MenuLayers/Objects
onready var objects_container = $MenuLayers/Objects/MainContainer
onready var objects_selector = $MenuLayers/Objects/MainContainer/Selector
onready var menulayers = $MenuLayers
onready var no_slog_text = $MenuLayers/Slogans/NoSloganText
onready var no_obj_text = $MenuLayers/Objects/NoObjectText
onready var political_compass = $MenuLayers/Slogans/PoliticalCompass
onready var slogans_desc_displayer = $MenuLayers/Slogans/DescriptionDisplayer
onready var current_slogan_desc = $MenuLayers/Slogans/DescriptionDisplayer/Background/InnerBackground/Text
onready var objects_desc_displayer = $MenuLayers/Objects/DescriptionDisplayer
onready var current_object_desc = $MenuLayers/Objects/DescriptionDisplayer/Background/InnerBackground/Text
onready var ui = get_node("/root/SceneManager/UI")

onready var player = get_node(NodePath('..')).find_node('Player')
onready var screentransition = get_node(NodePath('/root/SceneManager'))
onready var currentscene = get_node(NodePath('/root/SceneManager/CurrentScene'))
onready var n_of_slogans: int
onready var n_of_objects: int

onready var current_slog
onready var current_object

var menu_main: bool = false
var menu_slogans: bool = false
var menu_objects: bool = false

var slogan_index: int = 0
var object_index: int = 0

onready var slogan_list: Array = []
onready var object_list: Array = []

func _ready():
	menulayers = $MenuLayers
	sprite.visible = menu_main
	slogans.visible = menu_slogans
	screentransition.connect("new_main_scene", self, "new_p")
	no_slog_text.visible = false
	
	var save_file = screentransition.save_file
#	party = save_file.player_party
	
	for slogan_res in save_file.slogans:
		new_slogan(slogan_res)
	for object_res in save_file.objects:
		new_object(object_res)


func _process(_delta):
	n_of_slogans = slogan_container.get_child_count() - 1
	n_of_objects = objects_container.get_child_count() - 1
	player = get_node(NodePath('..')).get_child(0).get_children().back().find_node("Player")
	currentscene = get_node(NodePath('/root/SceneManager/CurrentScene')).get_child(0)
	
	if player:
		control.visible = menu_main
		sprite.visible = menu_main
		slogans.visible = menu_slogans
		objects.visible = menu_objects
		
		menulayers.position = player.position
		objects_desc_displayer.visible = menu_objects

	if menu_slogans:
		menu_main = false
		if Input.is_action_just_pressed("ui_end"):
			menu_slogans = false
			menu_main = true
			slogan_index = 0
		if n_of_slogans == 0:
			no_slog_text.visible = true
			slogan_selector.visible = false
			political_compass.visibility(false)
		else:
			no_slog_text.visible = false
			slogan_selector.visible = true
			current_slog = slogan_list[slogan_index]
			
			political_compass.set_main_pointer(current_slog.political_pos.x, -current_slog.political_pos.y)
			political_compass.set_damage_area(current_slog.damage_area)
			slogan_index = handle_input(slogan_index, n_of_slogans, slogan_selector)
			
			if Input.is_action_just_pressed("ui_accept"):
				print(current_slog.name, current_slog.political_pos)

			current_slogan_desc.text = current_slog.name
	
	if menu_objects:
		objects_container.visible = true
		menu_main = false
		menu_slogans = false
		if Input.is_action_just_pressed("ui_end"):
			menu_objects = false
			menu_main = true
			object_index = 0
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
				objects_container.get_child(1).foo(current_object.id) # Temporary Solution
	
	
	
	if menu_main:
		if Input.is_action_just_pressed("ui_down"):
			if sprite.frame != 3:
				sprite.frame += 1
		if Input.is_action_just_pressed("ui_up"):
			if sprite.frame != 0:
				sprite.frame -= 1
		if Input.is_action_just_pressed("ui_accept"):
			match sprite.frame:
				2:
					priority_to_slogans()
				3:
					priority_to_objects()



func priority_to_objects():
	menu_objects = true
	political_compass.visibility(false)


func priority_to_slogans():
	menu_slogans = true
	political_compass.visibility(true)


func priority_to_menu():
	menu_main = true
	political_compass.visibility(false)


func priority_to_player():
	menu_slogans = false
	menu_main = false
	menu_objects = false
	political_compass.visibility(false)


func new_p():
	currentscene = get_node(NodePath('/root/SceneManager/CurrentScene'))


func handle_input(index: int, maxv: int, selector):
	if Input.is_action_just_pressed("ui_right"):
		if index < maxv - 1:
			index += 1
	if Input.is_action_just_pressed("ui_left"):
		if index > 0:
			index -= 1
	selector.rect_position = Vector2(32 * (index % 6) + 3, 40 * (index / 6) + 9)
	return index


func new_slogan(slogan):
	if slogan in slogan_list:
		print("Già comprato: ", slogan_list)
	else:
		slogan_list.append(slogan)
#		print(ui.get_child(0).get_child(0).text)
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
