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

var machiavelli_pos: Vector2 = Vector2(16, -288)


func _ready():
	# I'm actually starting to appreciate signals.
	menu.connect("added_battleslog", self, "change_tutorial_dialog")
	
	if menu.party == null:
		machiavelli.dialog_list = [
			"Vai a parlare con Andrea dell'Otti",
			"Palazzo dei Conservatori, la prima a destra."
		]
	elif len(menu.battleslogs[0]) == 0:
		machiavelli.dialog_list = [
			"Non puoi andare a far l'oratore senza le giuste precauzioni",
			"Poco più a sud troverai un negozio di slogans"
		]
	
	if cutscene_activator.path in scenemanager.ended_cutscenes:
		machiavelli.position = machiavelli_pos
		
		if not machiavelli in menu.voter_list:
			machiavelli.attack_ids = [1]


func change_tutorial_dialog(battleslog, period):
	if period == 0:
		machiavelli.dialog_list = [
			"Finalmente ti vedo preparato al dibattito",
			"Prima di lasciarti andare mi par giusto farti da tutore"
		]
