extends Control
export(int) var state = 1
export(Resource) var game_save_obj

var paths = ["res://save01.tres", "res://save02.tres"]

onready var yes = $Panel/Container/Yes
onready var no = $Panel/Container/No
onready var ui = get_node(NodePath("/root/SceneManager/UI"))
onready var menu = get_node(NodePath("/root/SceneManager/Menu"))
onready var shop = get_node(NodePath('/root/SceneManager/ShopBox'))
onready var scene_manager = get_node(NodePath("/root/SceneManager"))

func _ready():
	self.visible = false
#	print(scene_manager.save_file.get_path())


func priority_to_menu():
	var player = get_node(NodePath("../CurrentScene")).get_children().back().find_node("Player")
	self.visible = true
	yes.grab_focus()
	self.rect_position.x = player.position.x
	self.rect_position.y = player.position.y


func priority_to_player():
	self.visible = false
	state = 1


func _process(_delta):
	var player = get_node(NodePath("../CurrentScene")).get_children().back().find_node("Player")
	if self.visible:
		if Input.is_action_just_pressed("ui_accept"):
			if yes.has_focus():
				save_all()
			if no.has_focus():
				get_tree().quit()
			player.close_menu(self)


func save_all():
	var player = get_node(NodePath("../CurrentScene")).get_children().back().find_node("Player")
	var current_scene = scene_manager.get_child(0).get_child(0)
	var file_save = game_save_obj.new()
	
	file_save.player_pos = player.position
	file_save.slogans = menu.slogan_list
	file_save.objects = menu.object_list
	file_save.ended_cutscenes = scene_manager.list_ended_cutscenes
#	print(file_save.ended_cutscenes)
	file_save.money = ui.get_money()
	file_save.current_scene = load("res://Scenes/" + current_scene.name + ".tscn")
	
	ResourceSaver.save(scene_manager.save_file.get_path(), file_save)
