extends CanvasLayer

onready var text_label = $MarginContainer/Panel/RichTextLabel
onready var current_npc
onready var shop_box = get_node(NodePath('/root/SceneManager/ShopBox'))
onready var scenemanager = get_node(NodePath('/root/SceneManager'))
onready var menu = get_node(NodePath('/root/SceneManager/Menu'))
onready var current_scene

onready var initiator
onready var player

onready var npc_name

var d_list: Array = []
var att_ids_list: Array = []
var finished_dialouge: bool = true
var n_lines: int
var i = 0
var open_shop: bool = false
var start_battle: bool

var start_dialog: bool = false
var open: bool = true

var battle_scene_path = 'res://Scenes/BattleScene.tscn'

signal priority_to_player
signal send_npc(npc)
signal npc_attacks(attack_ids_list)
signal next_scene(scene, p_pos)


func _ready():
	$MarginContainer.visible = false
	$TextureRect.visible = false


var npc_global_id: int
var continue_cutscene: bool = false


func display_dialog(npc_id, continue_cutscene):
	current_npc = scenemanager.get_child(0).get_child(0).list_npc[npc_id]
	d_list = current_npc.dialog_list
	
	npc_global_id = npc_id
	current_npc = scenemanager.get_child(0).get_child(0).list_npc[npc_id]
	npc_name = current_npc.name
	
	d_list = current_npc.dialog_list
	att_ids_list = current_npc.attack_ids
	open_shop = current_npc.is_seller
	
	start_battle = current_npc.start_battle
	
	self.continue_cutscene = continue_cutscene
	start_dialog = true


func visibility(vis: bool):
	$MarginContainer.visible = vis
	$TextureRect.visible = vis
	open = vis


func end_dialog_box():
	i = 0
	visibility(false)
	d_list = []


func has_obtained(object):
	d_list = ['Hai ottenuto ' + object.name]
	att_ids_list = []
	i = 0
	
	start_dialog = true
	yield(get_tree().create_timer(1), "timeout")
	end_dialog_box()
	
	emit_signal("priority_to_player")


func check_battle() -> void:
	if !len(menu.slogan_list):
		visibility(false)
		emit_signal("priority_to_player")
		return
	if start_battle:
		if menu.party and not menu.voter_list.has(npc_name):
			current_npc = current_scene.list_npc[npc_global_id]
			scenemanager.start_transition(battle_scene_path, Vector2(0,0))
			emit_signal("send_npc", current_npc)
			emit_signal("npc_attacks", att_ids_list)
			emit_signal("next_scene", current_scene.name, player.position)
			return
	emit_signal("priority_to_player")


func _process(_delta):
	player = get_parent().get_child(0).get_child(0).find_node('Player')
	current_scene = scenemanager.get_child(0).get_child(0)
	
	if player:
		if (Input.is_action_just_pressed("ui_accept") && player.NPCraycast.is_colliding()) or start_dialog:
			print("Dialogo")
			start_dialog = false
			if i < len(d_list):
				display_text_line(d_list[i])
				i += 1
			elif open:
				end_dialog_box()
				if open_shop:
					open_shop = false
					shop_box.priority_to_menu()
				elif len(att_ids_list):
					check_battle()
				elif !shop_box.open:
					if !continue_cutscene:
						emit_signal("priority_to_player")
					continue_cutscene = false


func display_text_line(line):
	visibility(true)
	text_label.set_text(line)
	text_label.percent_visible = 0.0
	for counter in len(line)+1:
		text_label.percent_visible += 1.0/len(line)
		yield(get_tree().create_timer(0.01), "timeout")
	yield(get_tree().create_timer(0.5), "timeout")
