extends Control
#export(int) var state = 1
export(Resource) var game_save_obj

onready var yes = $Panel/Container/Yes
onready var no = $Panel/Container/No
onready var ui = get_node(NodePath("/root/SceneManager/UI"))
onready var menu = get_node(NodePath("/root/SceneManager/Menu"))
onready var shop = get_node(NodePath('/root/SceneManager/ShopBox'))
onready var scene_manager = get_node(NodePath("/root/SceneManager"))
onready var save_path: String

func _ready():
	self.visible = false
	save_path = scene_manager.save_file.get_path()


func priority_to_menu():
	var player = get_node(NodePath("../CurrentScene")).get_children().back().find_node("Player")
	self.visible = true
	yes.grab_focus()
	self.rect_position.x = player.position.x -60
	self.rect_position.y = player.position.y -20


func priority_to_player():
	self.visible = false
	return true


func _process(_delta):
	var player = get_node(NodePath("../CurrentScene")).get_children().back().find_node("Player")
	
	if self.visible:
		if Input.is_action_just_pressed("ui_accept"):
			if yes.has_focus():
				save_all()
				player.openClose(self)
			if no.has_focus():
				get_tree().quit()


func save_all():
	var player = get_node(NodePath("../CurrentScene")).get_children().back().find_node("Player")
	var current_scene = scene_manager.current_scene
	var file_save = game_save_obj.new()
	file_save.take_over_path(scene_manager.save_file.get_path())
	
	if player:
		file_save.name = player.p_name
		file_save.player_pos = player.position
		file_save.slogans = menu.slogan_list
		file_save.battleslogs = menu.battleslogs
		file_save.objects = menu.object_list
		file_save.voters = menu.voter_list
		file_save.ended_cutscenes = scene_manager.ended_cutscenes
		file_save.money = ui.get_money()
		file_save.votes = ui.get_votes()
		file_save.current_scene = load("res://Scenes/GameLocations/" + current_scene.name + ".tscn")
		file_save.player_party = menu.party
		
		ResourceSaver.save(scene_manager.save_file.get_path(), file_save)
