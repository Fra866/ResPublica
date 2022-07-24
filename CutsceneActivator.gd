extends Node2D

onready var scenemanager = get_node(NodePath('/root/SceneManager'))
onready var player
onready var scenecontainer = scenemanager.get_child(0)
onready var enabled: bool = true
onready var currentscene

export(int) var cutscene_code

# Called when the node enters the scene tree for the first time.

func _ready():
	player = scenemanager.get_child(0).get_children().back().find_node("Player")


func virgilio_cutscene():
	var virgilio = currentscene.get_child(1).get_child(3)
	player.animstate.travel("Idle")
	player.animplayer.play('IdleUp')
	virgilio.animplayer.play('RunDown')


func start_cutscene():
	enabled = false
	player.cutscene = true
	
	match cutscene_code:
		1:
			virgilio_cutscene()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player and enabled:
		if player.position == self.position:
			currentscene = scenecontainer.get_child(0)
			start_cutscene()
