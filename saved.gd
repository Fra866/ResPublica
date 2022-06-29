extends Resource
class_name Saved

export(Array, Resource) var array = []
export(Resource) var current_scene = load("res://Scenes/Level1.tscn")
export(Vector2) var player_pos
export(int) var money = 1000


func initialize():
	array = []
	current_scene = load("res://Scenes/Level1.tscn")
	money = 1000
