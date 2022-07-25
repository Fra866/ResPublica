extends Node2D

onready var scenemanager = get_node(NodePath('/root/SceneManager'))
onready var dialouge_box = get_node(NodePath('/root/SceneManager/DialougeBox'))
onready var player
onready var collisionshape = $Area2D/CollisionShape2D
onready var scenecontainer = scenemanager.get_child(0)
onready var enabled: bool = true
onready var currentscene
onready var cutscene

export(int) var cutscene_code

# Called when the node enters the scene tree for the first time.

func _ready():
	player = scenemanager.get_child(0).get_children().back().find_node("Player")


func virgilio_cutscene():
	cutscene = true
	var virgilio = currentscene.get_child(1).get_child(3)
	
	player.stop_game()
	player.animstate.travel("Idle")
	player.animplayer.play('IdleUp')
	
	# virgilio.initial_position = virgilio.position
	virgilio.animplayer.play('RunDown')
	virgilio.input_direction = Vector2(0, 1)
	
	yield(get_tree().create_timer(1), "timeout")
	virgilio.animplayer.play('IdleDown')
	
	dialouge_box.activate_dialouge()


func start_cutscene():
	# enabled = false
	player.stop_game()
	
	match cutscene_code:
		1:
			virgilio_cutscene()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	player.stop_game()
	
	if player and enabled:
		if player.position == self.position:
			currentscene = scenecontainer.get_child(0)
			start_cutscene()
			# queue_free()
