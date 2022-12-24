extends CanvasLayer

onready var dialouge_box = self

onready var characters = $MarginContainer/Panel/Label.visible_characters
onready var text_label = $MarginContainer/Panel/Label
onready var current_npc
onready var shop_box = get_node(NodePath('/root/SceneManager/ShopBox'))
onready var scenemanager = get_node(NodePath('/root/SceneManager'))
onready var menu = get_node(NodePath('/root/SceneManager/Menu'))
onready var current_scene = scenemanager.get_child(0).get_child(0)

onready var initiator
onready var player

onready var npc_name

var d_list: Array = []
var att_ids_list: Array = []
var finished_dialouge: bool = true
var n_lines: int
var i = 0
var open_shop: bool = false
var has_won_battle: bool

var start_dialouge: bool = false

var battle_scene_path = 'res://Scenes/BattleScene.tscn'

signal priority_to_player
signal send_npc(npc)
signal npc_attacks(attack_ids_list)
signal next_scene(scene, p_pos)

#signal next_player_pos(player_pos)


func _ready():
	$MarginContainer.visible = false


#func activate_dialouge():
#	return true

var npc_global_id: int


func display_dialouge(npc_id):
	npc_global_id = npc_id
	print("SceneManager: ", scenemanager.get_child(0).get_child(0))
	current_npc = scenemanager.get_child(0).get_child(0).list_npc[npc_id]
	print("Display Dial: ", current_npc)
	npc_name = current_npc.name
	
	d_list = current_npc.dialouge_list
	att_ids_list = current_npc.attack_ids
	open_shop = current_npc.is_seller
	
	has_won_battle = current_npc.start_battle
	
#	print(menu.voter_list)


func end_dialouge_box():
	i = 0
	$MarginContainer.visible = false
	d_list = []


func has_obtained(object):
	d_list = ['Hai ottenuto ' + object.name]
#	s_list = []
	att_ids_list = []
	i = 0
	
	start_dialouge = true
	yield(get_tree().create_timer(1), "timeout")
	end_dialouge_box()
	
	emit_signal("priority_to_player")


func _process(_delta):
#	print(has_won_battle)
	player = get_parent().get_child(0).get_child(0).find_node('Player')
	current_scene = scenemanager.get_child(0).get_child(0)
	
	if player:
		if (Input.is_action_just_pressed("ui_accept") && player.NPCraycast.is_colliding()) or start_dialouge:
			start_dialouge = false
			if i < len(d_list):
				display_text_line(d_list[i])
				i += 1
			else:
				end_dialouge_box()
				if open_shop:
					open_shop = false
					shop_box.priority_to_menu()
				elif len(att_ids_list):
					if !len(menu.slogan_list):
						# yield(display_text_line("Non hai slogan per combattere."), "completed")
						$MarginContainer.visible = false
						emit_signal("priority_to_player")
					else:
						print(has_won_battle)
						if !has_won_battle:
							var b: bool
							for sprite in menu.voter_list:
								if npc_name == sprite.npc_name:
									b = true
							if !b and menu.party:
								current_npc = scenemanager.get_child(0).get_child(0).list_npc[npc_global_id]
								print("CURRENT_NPC DisplayBox process: ", current_npc)
								scenemanager.start_transition(battle_scene_path, Vector2(0,0))
								emit_signal("send_npc", current_npc)
								emit_signal("npc_attacks", att_ids_list)
								emit_signal("next_scene", current_scene.name, player.position)
							else:
								emit_signal("priority_to_player")
				else:
					emit_signal("priority_to_player")


func display_text_line(line):
	$MarginContainer.visible = true
	text_label.set_text(line)
	text_label.percent_visible = 0.0
	for counter in len(line)+1:
		text_label.percent_visible += 1.0/len(line)
		yield(get_tree().create_timer(0.01), "timeout")
	yield(get_tree().create_timer(0.5), "timeout")
