extends Node2D

onready var list_npc = [
	$YSort/BarMan,
	$YSort/Parini,
	$YSort/Caio,
	$YSort/Sempronio,
	$YSort/Virgilio
]

signal completed

func start(character: StaticBody2D, scene: Node2D):
	var caio = scene.get_parent().find_node("Caio")
	var parini = scene.get_parent().find_node("Parini")
	
	scene.start_cutscene_dialog(character, true)
	yield(scene.get_tree().create_timer(3), "timeout")
	scene.start_cutscene_dialog(caio, true)
	
