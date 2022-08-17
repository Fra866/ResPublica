extends Resource
class_name Saved

export(Array, Resource) var slogans = []
export(Array, Resource) var objects = []
export(Array, Resource) var ended_cutscenes
export(Resource) var current_scene = load("res://Scenes/Level1.tscn")
export(Vector2) var player_pos
export(int) var money = 1000


func initialize():
	objects = []
	slogans = []
	ended_cutscenes = []
	current_scene = load("res://Scenes/Level1.tscn")
	player_pos = Vector2(80, 16)
	money = 1000
