extends Node


func start(character: StaticBody2D, scene: Node2D):
	var player = scene.player
	
	player.animstate.travel("Idle")
	character.input_direction = Vector2(-1, 0)
	yield(scene.get_tree().create_timer(1.07), "timeout")
	character.input_direction = Vector2(0, 0)
	character.animplayer.play('IdleRight')
	
	# scene.menu.party = PoliticalParty.new()
	
	scene.start_cutscene_dialog(character, false)
	
	character.attack_ids = [1]
	
