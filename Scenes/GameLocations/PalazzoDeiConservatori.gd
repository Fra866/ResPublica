extends Node2D

onready var list_npc = [
	$YSort/Andreotti,
	$YSort/Cesare,
	$YSort/Machiavelli,
]

onready var cutscene_activator = $YSort/CutsceneActivator
onready var cutscene_activator2 = $YSort/CutsceneActivator2
onready var scenemanager = get_node(NodePath('/root/SceneManager'))

func _ready():
	if not cutscene_activator2.path in scenemanager.ended_cutscenes:
		if not cutscene_activator.path in scenemanager.ended_cutscenes:
			scenemanager.ended_cutscenes.append(cutscene_activator2.path)
		else:
			scenemanager.ended_cutscenes.erase(cutscene_activator2.path)

# func postcutscene():
# 	pass
