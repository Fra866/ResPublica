extends Area2D


onready var player = get_parent().get_parent().find_node('Player')
onready var scenemanager = get_node(NodePath('/root/SceneManager'))

export(String, FILE) var next_scene_path
export(Vector2) var next_player_pos

signal entered_door

func _ready():
	if player.doors == null:
		player.doors = []
	
	print("Doors: ", player.doors)
	player.doors.append(self)
	player.connect("enter_door", self, "entering")


func entering(_player_pos, _door):
	if _door == self:
		print('Entered on door: ', next_scene_path)
		emit_signal("entered_door")
		print(next_scene_path)
		scenemanager.start_transition(next_scene_path, next_player_pos)
