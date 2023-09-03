extends Node


func start(character: StaticBody2D, scene: Node2D):
	var player = scene.player
	var barscene = player.get_parent().get_parent()
	
	var virgilio = load("res://NPC/NPC.tscn").instance()
	
	virgilio.position = Vector2(144, 66)
	virgilio.dialog_list = [
		"Io sono Virgilio"
	]
	virgilio.id = 4
	
	barscene.get_child(1).add_child(virgilio)
	
	virgilio.animplayer.play('RunDown')
	virgilio.input_direction = Vector2(0, 1)
	
	yield(scene.get_tree().create_timer(1.5), "timeout")
	virgilio.animplayer.play('IdleDown')
	
	virgilio.input_direction = Vector2(0, 0)
	
	barscene.list_npc.append(virgilio)
	scene.start_cutscene_dialog(virgilio, true)
	yield(virgilio, "dialog_over")
	
	var object = load("res://Items/Objects/Key Objects/mail.tres")
	scene.menu.new_object(object, true)
	
	# By calling 'has_obtained' on the npc the evolution of the functions
	# starts when the DialogBox is already about to eliminate itself
	# because of the previous call.
	# So, to avoid conflicts, I just made the UI generate a separate DialogBox
	# as its child every time a new object is added to the menu by the
	# previous function
	
	# print(virgilio.get_children())
	# virgilio.get_child(5).has_obtained(object, false)
