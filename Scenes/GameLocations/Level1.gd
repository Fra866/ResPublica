extends Node2D

onready var list_npc = [
	$YSort/Andreotti,
	$YSort/Sempronio,
	$YSort/DummyCommie,
	$YSort/Enea,
	$YSort/DummyCommie2
]

# Replaced Machiavelli with Enea
# I mean, it makes kind of sense

onready var enea = list_npc[3]

onready var cutscene_activator = $YSort/CutsceneActivator
onready var scenemanager = get_node(NodePath('/root/SceneManager'))
onready var menu = get_node(NodePath('/root/SceneManager/Menu'))

var enea_pos: Vector2 = Vector2(16, -288)

func _ready():
	print("READY level 1")
	# I'm actually starting to appreciate signals.
	menu.connect("added_battleslog", self, "change_tutorial_dialog")
	
	if menu.party == null:
		enea.dialog_list = [
			"Vai a parlare con Andrea dell'Otti, o come si chiama",
			"Palazzo dei Conservatori, la prima a destra. Qualunque cosa sia"
		]
	elif len(menu.battleslogs[0]) == 0:
		enea.dialog_list = [
			"Non puoi andare a far l'oratore senza le giuste precauzioni",
			"Poco più a sud troverai un negozio di slogans"
		]
	else:
		enea.dialog_list = [
			"Finalmente ti vedo preparato al dibattito",
			"Prima di lasciarti andare mi par giusto farti da tutore"
		]
	
	if cutscene_activator.path in scenemanager.ended_cutscenes:
		if enea.cutscene_src.resource_path != "res://NPC/Cutscenes/post_tutorial.gd":
			# If tutorial has not been completed yet, he blocks the passage
			enea.position = enea_pos
		
		if not enea in menu.voter_list:
			enea.attack_ids = [1]
	
	# Now I love yields
	# What learning GoDot can do to a MF (Mount Fuji)
	yield(scenemanager, "new_main_scene")
	
	if enea.battle_result == 2 and enea.cutscene_src.resource_path != "res://NPC/Cutscenes/post_tutorial.gd": # Victroy
		# If you won the tutorial then Enea lets you go
		enea.cutscene_src = load("res://NPC/Cutscenes/post_tutorial.gd")
		scenemanager.ended_cutscenes.erase(cutscene_activator.path)


func change_tutorial_dialog(battleslog, period):
	if period == 0:
		enea.dialog_list = [
			"Finalmente ti vedo preparato al dibattito",
			"Prima di lasciarti andare mi par giusto farti da tutore"
		]
