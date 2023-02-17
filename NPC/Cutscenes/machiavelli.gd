extends Node

export(int) var code := 0

func start(character: StaticBody2D, scene: Node2D):
	var player = scene.player
	
	player.animstate.travel("Idle")
#	character.animplayer.play('RunRight')
	character.input_direction = Vector2(1, 0)
	yield(scene.get_tree().create_timer(1.07), "timeout")
	character.input_direction = Vector2(0, 0)
	character.animplayer.play('IdleRight')
	
	scene.menu.party = PoliticalParty.new()
	
#	dialog_box.display_dialog(character)
	
	scene.start_cutscene_dialouge(character)
	scene.cutscene = false
	scene.scenemanager.cutscene_over(code)
	
	character.dialouge_list = [
		"Nel mondo tornano i medesimi uomini",
		"come tornano i medesimi casi...",
		"Non passeranno mai cento anni",
		"che noi non ci troveremmo a fare le medesime cose."
	]
	character.attack_ids = [1]
