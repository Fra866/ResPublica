extends Node2D


onready var machiavelli = $YSort/Machiavelli
onready var cutscene_activator = $YSort/CutsceneActivator
onready var scenemanager = get_node(NodePath('/root/SceneManager'))

var machiavelli_pos: Vector2 = Vector2(64, 80)

func _ready():
	if cutscene_activator.cutscene_code in scenemanager.ended_cutscenes:
		machiavelli.position = machiavelli_pos
