extends Node2D

onready var list_npc = [
	$YSort/Seller,
	$YSort/Virgilio
]

onready var virgilio = list_npc[1]
onready var cutscene_activator = $CutsceneActivator
onready var scenemanager = get_node(NodePath('/root/SceneManager'))

var virgilio_pos: Vector2 = Vector2(144, 128)

func _ready():
#	if cutscene_activator.cutscene_code in scenemanager.ended_cutscenes:
	if cutscene_activator.path in scenemanager.ended_cutscenes:
		virgilio.position = virgilio_pos
