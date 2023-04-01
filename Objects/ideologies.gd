extends Resource
class_name Ideology

export(int) var id

enum xOrientation {
	NO_ORIENTATION = -1,
	LEFT = 0,
	RIGHT = 1,
}

enum yOrientation {
	NO_ORIENTATION = -1,
	LIB = 0,
	AUTH = 1,
}

onready var xOr
onready var yOr

onready var name: String

# An ideology may cover up to 2 peridos.
onready var period1
onready var period2


func _ready():
	name = Archive.ideologies[id]["name"]
	xOr = Archive.ideologies[id]["x"]
	yOr = Archive.ideologies[id]["y"]
	period1 = Archive.ideologies[id]["period1"]
	period2 = Archive.ideologies[id]["period2"]
