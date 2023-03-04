extends Node2D

onready var list_npc = [
	$YSort/Andreotti,
	$YSort/Sempronio,
	$YSort/DummyCommie,
	$YSort/Machiavelli
]

onready var machiavelli = list_npc[3]

onready var cutscene_activator = $YSort/CutsceneActivator
onready var scenemanager = get_node(NodePath('/root/SceneManager'))
onready var menu = get_node(NodePath('/root/SceneManager/Menu'))

var machiavelli_pos: Vector2 = Vector2(64, 80)

func _ready():
	if cutscene_activator.path in scenemanager.ended_cutscenes:
		machiavelli.position = machiavelli_pos
		
		machiavelli.dialog_list = [
		"Nel mondo tornano i medesimi uomini",
		"come tornano i medesimi casi...",
		"Non passeranno mai cento anni",
		"che noi non ci troveremmo a fare le medesime cose."
		]
		if not machiavelli in menu.voter_list:
			machiavelli.attack_ids = [1]
