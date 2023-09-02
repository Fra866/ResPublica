extends Node


func start(character: StaticBody2D, scene: Node2D):
	var menu = scene.player.menu
	var pdc = scene.get_parent().get_parent()
	var andreotti = pdc.list_npc[0]
	
	andreotti.dialog_list = [
		"Battaglia di insegnamento"
	]
	
	#scene.start_cutscene_dialog(pdc.list_npc[2], true) # Machiavelli
	#yield(scene, "cd_over")
	
	#scene.start_cutscene_dialog(pdc.list_npc[1], true) # Cesare
	#yield(scene, "cd_over")
	
	var scenemanager = pdc.scenemanager
#	var cs2 = pdc.cutscene_activator2
#	scenemanager.ended_cutscenes.erase(cs2.path)
	
#	if !menu.party and !menu.has_battleslogs(andreotti.historical.period)
	scene.start_cutscene_dialog(andreotti, true)
	yield(scene, "cd_over")
	
