extends Node


func start(character: StaticBody2D, scene: Node2D):
	# It starts
	var player = scene.get_parent().get_child(3)
	
	player.get_priority()
	
	# player.cutscene is set to false by the DialogBox
	# If the cutscene does not contain dialogs, it must be
	# set manually (this is awful but it should work for now) 
