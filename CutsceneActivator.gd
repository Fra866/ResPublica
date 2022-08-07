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

# Called when the node enters the scene tree for the first time.

func _ready():
	player = scenemanager.get_child(0).get_children().back().find_node("Player")


func virgilio_cutscene():
	cutscene = true
	var virgilio = currentscene.get_child(1).get_child(3)
	
	player.animstate.travel("Idle")
	player.animplayer.play('IdleUp')
	
	virgilio.animplayer.play('RunDown')
	virgilio.input_direction = Vector2(0, 1)
	
	yield(get_tree().create_timer(1), "timeout")
	
	virgilio.animplayer.play('IdleDown')
	
	dialouge_box.display_dialouge(virgilio)
	
	for j in range(len(virgilio.dialouge_list) + 1):
		yield(get_tree().create_timer(1.5), "timeout")
		dialouge_box.start_dialouge = true
	
	dialouge_box.has_obtained(virgilio.get_child(5))
	
	cutscene = false
	
	var object = virgilio.get_child(5).get_child(0).game_object_resource
	menu.new_object(object)
	load(object.use_script.get_path()).new().content = """
	Nel mezzo delle elezioni di nostra vita,
	Ci ritrovammo in un fascismo oscuro,
	Che la ritta legislatura era smarrita...
	"""
	virgilio.input_direction = Vector2(0, 0)


func start_cutscene():
	# enabled = false
	# player.stop_game()
	
	match cutscene_code:
		1:
			virgilio_cutscene()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player and enabled:
		if player.position == self.position and i == 0:
			currentscene = scenecontainer.get_child(0)
			start_cutscene()
			i += 1
			# queue_free()
