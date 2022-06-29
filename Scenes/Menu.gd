extends Node2D
export(int) var state = 1

onready var sprite = $MenuLayers/MainMenu/Sprite
onready var control = $MenuLayers/MainMenu/Control
onready var slogans = $MenuLayers/Slogans
onready var container = $MenuLayers/Slogans/ItemList
onready var slogan_selector = $MenuLayers/Slogans/ItemList/ColorRect
onready var menulayers = $MenuLayers

onready var player = get_node(NodePath('..')).find_node('Player')
onready var screentransition = get_node(NodePath('/root/SceneManager'))
onready var currentscene = get_node(NodePath('/root/SceneManager/CurrentScene'))
onready var n_of_slogans: int

var menu_main: bool = false
var menu_slogans: bool = false
var slogan_index: int = 0
onready var slogan_list: Array = []

func _ready():
	menulayers = $MenuLayers
	sprite.visible = menu_main
	slogans.visible = menu_slogans
	screentransition.connect("new_main_scene", self, "new_p")
	
	var save_file = screentransition.save_file
	
	for slogan_res in save_file.array:
		new_slogan(slogan_res)

func _process(_delta):
	n_of_slogans = container.get_item_count()
	player = get_node(NodePath('..')).get_child(0).get_children().back().find_node("Player")
	currentscene = get_node(NodePath('/root/SceneManager/CurrentScene')).get_child(0)
	
	if player:
		control.visible = menu_main
		sprite.visible = menu_main
		slogans.visible = menu_slogans
		menulayers.position = player.position

	if menu_slogans:
		menu_main = false
		if Input.is_action_just_pressed("ui_end"):
			menu_slogans = false
			menu_main = true
			slogan_index = 0
		if Input.is_action_just_pressed("ui_right"):
			if slogan_index < (n_of_slogans - 1):
				slogan_index += 1
		if Input.is_action_just_pressed("ui_left"):
			if slogan_index > 0:
				slogan_index -= 1

		slogan_selector.rect_position.x = slogan_index * 36
	else:
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


func priority_to_slogans():
	menu_slogans = true

func priority_to_menu():
	menu_main = true

func priority_to_player():
	menu_slogans = false
	menu_main = false

func new_p():
	currentscene = get_node(NodePath('/root/SceneManager/CurrentScene'))

func new_slogan(slogan):
	var new_slog_instance = load("res://Scenes/UI_Objects/SloganNode.tscn").instance()
	new_slog_instance.slogan_res = slogan
	n_of_slogans += 1
	container.add_icon_item(slogan.texture, true)
	slogan_list.append(slogan)

#func loadSlogans(data):
#	var file = File.new()
#	file.open("user://gabibbo.txt", File.READ)
#	while file.get_position() < file.get_len():
#		var data = file.get_line()
#	new_slogan(load(data))
