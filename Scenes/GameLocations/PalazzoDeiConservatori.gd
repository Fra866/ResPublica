extends Node2D

onready var list_npc = [
	$YSort/Andreotti,
	$YSort/Cesare,
	$YSort/Machiavelli,
]

onready var cutscene_activator = $YSort/CutsceneActivator
onready var cutscene_activator2 = $YSort/CutsceneActivator2
onready var scenemanager = get_node(NodePath('/root/SceneManager'))
onready var player = $YSort/Player

func _ready():
	if !cutscene_activator2.path in scenemanager.ended_cutscenes:
		if !player.menu.has_battleslogs(list_npc[0].historical_period):
			cutscene_activator2.i = 0
		else:
			scenemanager.ended_cutscenes.append(cutscene_activator2.path)

# func postcutscene():
# 	pass
