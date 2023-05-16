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
	
	yield(scene.get_tree().create_timer(1), "timeout")
	virgilio.animplayer.play('IdleDown')
	
	virgilio.input_direction = Vector2(0, 0)
	
	barscene.list_npc.append(virgilio)
	yield(scene.start_cutscene_dialog(virgilio, true), "completed")
	
	var object = load("res://Items/Objects/Key Objects/mail.tres")
	scene.menu.new_object(object)
	
	scene.dialog_box.has_obtained(object)
	
