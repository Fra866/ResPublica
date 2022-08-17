extends Node2D


onready var cutscene_id

onready var virgilio = $YSort/Virgilio
onready var cutscene_activator = $CutsceneActivator
onready var scenemanager = get_node(NodePath('/root/SceneManager'))


func _ready():
	cutscene_id = cutscene_activator.cutscene_code
	if cutscene_id in scenemanager.save_file.ended_cutscenes:
		virgilio.position = Vector2(144, 128)
		cutscene_activator.enabled = false


#func cutscene_over(id):
#	if not cutscene_id in scenemanager.list_ended_cutscenes:
#		scenemanager.list_ended_cutscenes.append(id)
