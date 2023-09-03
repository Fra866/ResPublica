extends Node2D

onready var scenemanager = get_node(NodePath('/root/SceneManager'))
# onready var dialog_box = get_node(NodePath('/root/SceneManager/DialogBox'))
onready var player
onready var menu = get_node(NodePath('/root/SceneManager/Menu'))
onready var collisionshape = $Area2D/CollisionShape2D
onready var scenecontainer = scenemanager.get_child(0)
onready var enabled: bool = true
onready var currentscene
onready var cutscene: bool = false
onready var path: NodePath

onready var npc_id: int
onready var continue_cutscene: bool

onready var npc
onready var dialog_box

var i: int = 0
var j: int = 0

export(String) var activator
signal cd_over

func _ready():
	path = self.get_path()
	player = scenemanager.get_child(0).get_children().back().find_node("Player")


func start_cutscene_dialog(local_npc, continue_cutscene):
	var dialog_box = load("res://UI/DialogBox.tscn").instance()
	local_npc.add_child(dialog_box)
	dialog_box.display_dialog(local_npc.id, continue_cutscene)
	dialog_box.start_dialog = true
	
	npc_id = local_npc.id
	self.continue_cutscene = continue_cutscene
	
	emit_signal("cd_over")


func start_cutscene():
	cutscene = not path in scenemanager.ended_cutscenes
	if cutscene:
		player.set("cutscene", true)
		currentscene.find_node(activator).start_cutscene(self)
		cutscene = false
		scenemanager.ended_cutscenes.append(path)


func _process(_delta):
	if player and enabled:
		if player.position == self.position and i == 0:
			currentscene = scenecontainer.get_child(0)
			start_cutscene()
			i += 1
#		if player.cutscene:
#			if j == 0:
#				npc = scenemanager.get_child(0).get_child(0).list_npc[npc_id]
#				dialog_box = load("res://UI/DialogBox.tscn").instance()
#				npc.add_child(dialog_box)
#				dialog_box.display_dialog(npc_id, continue_cutscene)
#				j += 1
#			if Input.is_action_just_pressed("ui_accept"):
#				dialog_box.start_dialog = true
#				dialog_box.continue_dialog()
