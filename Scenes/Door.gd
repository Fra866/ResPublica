extends Area2D


onready var player = get_parent().get_parent().find_node('Player')
onready var scenemanager = get_node(NodePath('/root/SceneManager'))

export(String, FILE) var next_scene_path
export(Vector2) var next_player_pos

#signal entered_door

func _ready():
#	if player.doors == null:
#		player.doors = []
#	print("Doors: ", player.doors)
#	player.doors.append(self)
	player.connect("enter_door", self, "entering")
#Or: Player could just call collider's entering method from his script. No more signals needed

func entering(door: Area2D):
#	emit_signal("entered_door")
	if door == self:
		scenemanager.start_transition(next_scene_path, next_player_pos)
