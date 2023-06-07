extends Resource
class_name Saved

export(String) var name
export(Array, Resource) var slogans = []
export(Array, Resource) var battleslogs = []
export(Array, Resource) var objects = []
export(Dictionary) var voters = {}
export(Array, Resource) var ended_cutscenes
export(Resource) var current_scene = null
export(Resource) var player_party
export(Vector2) var player_pos
export(int) var money = 1000
export(int) var votes = 0


func initialize():
	name = "???"
	objects = []
	slogans = []
	battleslogs = []
	voters = {}
	ended_cutscenes = []
	current_scene = null
	player_party = null
	player_pos = Vector2(80, 16)
	money = 1000
	votes = 0
