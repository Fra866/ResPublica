extends Node2D


onready var virgilio = $YSort/Virgilio
onready var cutscene_activator = $CutsceneActivator
onready var scenemanager = get_node(NodePath('/root/SceneManager'))

var virgilio_pos: Vector2 = Vector2(144, 128)

func _ready():
	if cutscene_activator.cutscene_code in scenemanager.ended_cutscenes:
		virgilio.position = virgilio_pos
