extends Node2D

onready var scenemanager = get_node(NodePath('/root/SceneManager'))
onready var dialouge_box = get_node(NodePath('/root/SceneManager/DialougeBox'))
onready var player
onready var menu = get_node(NodePath('/root/SceneManager/Menu'))
onready var collisionshape = $Area2D/CollisionShape2D
onready var scenecontainer = scenemanager.get_child(0)
onready var enabled: bool = true
onready var currentscene
onready var cutscene: bool = false

var i: int = 0

export(int) var cutscene_code


func _ready():
	player = scenemanager.get_child(0).get_children().back().find_node("Player")


func start_cutscene_dialouge(npc):
	dialouge_box.display_dialouge(npc)
	
	for _j in range(len(npc.dialouge_list) + 1):
		yield(get_tree().create_timer(1.5), "timeout")
		dialouge_box.start_dialouge = true


func virgilio_cutscene():
	var virgilio = currentscene.get_child(1).get_child(3)
	
	player.animstate.travel("Idle")
	player.animplayer.play('IdleUp')
	
	virgilio.animplayer.play('RunDown')
	virgilio.input_direction = Vector2(0, 1)
	yield(get_tree().create_timer(1), "timeout")
	virgilio.animplayer.play('IdleDown')
	
	yield(start_cutscene_dialouge(virgilio), "completed")
	
	dialouge_box.has_obtained(virgilio.get_child(5))
	
	cutscene = false
	scenemanager.cutscene_over(cutscene_code)
	
	var object = virgilio.get_child(5).get_child(0).game_object_resource
#	print(virgilio.get_child(5))
	
	menu.new_object(object)
	virgilio.input_direction = Vector2(0, 0)


func machiavelli_cutscene():
	var machiavelli = currentscene.get_child(0).get_child(3)
	player.animstate.travel("Idle")
	
	machiavelli.animplayer.play('RunRight')
	machiavelli.input_direction = Vector2(1, 0)
	yield(get_tree().create_timer(1.07), "timeout")
	machiavelli.input_direction = Vector2(0, 0)
	machiavelli.animplayer.play('IdleRight')
	
	menu.party = PoliticalParty.new()
	
#	dialouge_box.display_dialouge(machiavelli)
	
	start_cutscene_dialouge(machiavelli)
	cutscene = false
	scenemanager.cutscene_over(cutscene_code)
	
	machiavelli.dialouge_list = [
		"Nel mondo tornano i medesimi uomini",
		"come tornano i medesimi casi...",
		"Non passeranno mai cento anni",
		"che noi non ci troveremmo a fare le medesime cose."
	]
	machiavelli.attack_ids = [1]
	
#	print(machiavelli.position)


func bar_start_scene():
	print("Bar Starting Scene")
	cutscene = false


func start_cutscene():
	cutscene = not cutscene_code in scenemanager.ended_cutscenes
	if cutscene:
		match cutscene_code:
			0:
				machiavelli_cutscene()
			1:
				virgilio_cutscene()
			2:
				bar_start_scene()
	
		scenemanager.ended_cutscenes.append(cutscene_code)
#	print(scenemanager.ended_cutscenes)


func _process(_delta):
	if player and enabled:
		if player.position == self.position and i == 0:
			currentscene = scenecontainer.get_child(0)
			start_cutscene()
			i += 1
			# queue_free()
