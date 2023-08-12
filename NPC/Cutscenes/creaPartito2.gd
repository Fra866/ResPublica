extends Node


func start(character: StaticBody2D, scene: Node2D):
	var player = scene.get_parent().get_child(3)
	var pdc = scene.get_parent().get_parent()
	
	pdc.list_npc[0].dialog_list = [
		"Alto là, pezzente",
		"Hai dimenticato di fondare il partito"
	]
	
	pdc.list_npc[0].attack_ids = []
	
	scene.start_cutscene_dialog(pdc.list_npc[0], false)
	
	scene.menu.party = PoliticalParty.new()
	
	
	# player.cutscene is set to false by the DialogBox
	# If the cutscene does not contain dialogs, it must be
	# set manually (this is awful but it should work for now) 
