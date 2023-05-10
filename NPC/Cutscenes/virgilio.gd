extends Node


func start(character: StaticBody2D, scene: Node2D):
	var player = scene.player
	player.animstate.travel("Idle")
	player.animplayer.play('IdleUp')

	character.animplayer.play('RunDown')
	character.input_direction = Vector2(0, 1)
	yield(scene.get_tree().create_timer(1), "timeout")
	character.animplayer.play('IdleDown')

	yield(scene.start_cutscene_dialog(character), "completed")
	scene.dialog_box.has_obtained(character.get_child(5))

	var object = character.get_children().back().object_res
	scene.menu.new_object(object)
	character.input_direction = Vector2(0, 0)
