extends Resource
class_name Saved

export(Array, Resource) var slogans = []
export(Array, Resource) var objects = []
export(Resource) var current_scene = load("res://Scenes/Level1.tscn")
export(Vector2) var player_pos
export(int) var money = 1000


func initialize():
	objects = []
	slogans = []
	current_scene = load("res://Scenes/Level1.tscn")
	money = 1000
