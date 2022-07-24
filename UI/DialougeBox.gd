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

var d_list: Array = []
var s_list: Array = []
var finished_dialouge: bool = true
var n_lines: int
var i = 0
var open_shop: bool = false
var has_won_battle: bool


var battle_scene_path = 'res://Scenes/BattleScene.tscn'

signal priority_to_player
signal send_npc(npc)
signal npc_slogans(slogan_list)
signal next_scene(scene, p_pos)
#signal next_player_pos(player_pos)


func _ready():
	$MarginContainer.visible = false


func display_dialouge(npc):
	print('DialougeBox NPC: ', npc.name)
	current_npc = npc.name
	
	d_list = npc.dialouge_list
	s_list = npc.slogans_for_battle
	open_shop = npc.is_seller
	has_won_battle = npc.battle_won
	
	print(npc.battle_won)


func _process(_delta):
	player = get_parent().get_child(0).get_child(0).find_node('Player')
	current_scene = scenemanager.get_child(0).get_child(0)

	if player:
		if Input.is_action_just_pressed("ui_accept") && player.NPCraycast.is_colliding():
			if i < len(d_list):
				display_text_line(d_list[i])
				i += 1
			else:
				i = 0
				$MarginContainer.visible = false
				d_list = []
				if open_shop:
					open_shop = false
					shop_box.priority_to_menu()
				elif len(s_list) > 0:
					print(scenemanager.list_npc)
					if !len(menu.slogan_list):
						yield(display_text_line("Non hai slogan per combattere."), "completed")
						$MarginContainer.visible = false
						emit_signal("priority_to_player")
					else:
						if !has_won_battle:
							if not current_npc in scenemanager.list_npc:
								scenemanager.list_npc.append(current_npc)
							
								scenemanager.start_transition(battle_scene_path, Vector2(0,0))
								emit_signal("send_npc", current_npc)
								emit_signal("npc_slogans", s_list)
								emit_signal("next_scene", current_scene.name, player.position)
								
								print(scenemanager.list_npc)
							else:
								emit_signal("priority_to_player")
						else:
							pass
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
