extends Node2D

onready var scenemanager = get_node(NodePath('/root/SceneManager'))
onready var dialog_box = get_node(NodePath('/root/SceneManager/DialogBox'))
onready var player
onready var menu = get_node(NodePath('/root/SceneManager/Menu'))
onready var collisionshape = $Area2D/CollisionShape2D
onready var scenecontainer = scenemanager.get_child(0)
onready var enabled: bool = true
onready var currentscene
onready var cutscene: bool = false
onready var path: NodePath

var i: int = 0

export(String) var activator


func _ready():
	path = self.get_path()
	player = scenemanager.get_child(0).get_children().back().find_node("Player")


func start_cutscene_dialog(npc, continue_cutscene):
	dialog_box.display_dialog(npc.id, continue_cutscene)
	
	for _j in range(len(npc.dialog_list) + 1):
		yield(get_tree().create_timer(1.5), "timeout")
		dialog_box.start_dialog = true


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