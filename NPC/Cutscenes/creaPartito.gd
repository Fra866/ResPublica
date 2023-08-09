extends Node


func start(character: StaticBody2D, scene: Node2D):
	var player = scene.player
	var pdc = scene.get_parent().get_parent()
	
	#scene.start_cutscene_dialog(pdc.list_npc[2], true) # Machiavelli
	#yield(scene, "cd_over")
	
	#scene.start_cutscene_dialog(pdc.list_npc[1], true) # Cesare
	#yield(scene, "cd_over")
	
	var scenemanager = scene.get_parent().get_parent().scenemanager
	var cs2 = scenemanager.current_scene.cutscene_activator2
	scenemanager.ended_cutscenes.erase(cs2.path)
	
	scene.start_cutscene_dialog(pdc.list_npc[0], true) # Andreotti
	yield(scene, "cd_over")
