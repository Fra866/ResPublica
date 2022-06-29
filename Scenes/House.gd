extends StaticBody2D

onready var door = $Door
onready var player = get_node(NodePath('/root/SceneManager/CurrentScene/Level1/YSort/Player'))
onready var scenemanager = get_node(NodePath('/root/SceneManager'))
export(String, FILE) var next_scene_path

signal entered_door


func _ready():
	player.connect("enter_door", self, "entering")


func entering(player_pos, _door):
	emit_signal("entered_door")
	scenemanager.start_transition(next_scene_path)
