extends Node

var warning = [
	"Non hai slogan per affrontare la mia potenza",
	"Torna indietro e pijane qualcuno"
]


func start(character: StaticBody2D, scene: Node2D):
	var player = scene.get_parent().find_node("Player")
	var pdc = scene.get_parent().get_parent()
	var andreotti = pdc.list_npc[0]

#	Alfano-tier code.
	if !player.menu.party:
		for line in warning:
			andreotti.dialog_list.append(line)
		
		scene.start_cutscene_dialog(andreotti, true)
		player.menu.party = PoliticalParty.new()
		yield(scene, "cd_over")
		
		andreotti.dialog_list.remove(0)
		andreotti.dialog_list.remove(0)
	
	else:
		andreotti.dialog_list = warning
		scene.start_cutscene_dialog(andreotti, false)
		yield(scene, "cd_over")
	
	scene.scenemanager.ended_cutscenes.erase(scene.path)
	# player.cutscene is set to false by the DialogBox
	# If the cutscene does not contain dialogs, it must be
	# set manually (this is awful but it should work for now) 
