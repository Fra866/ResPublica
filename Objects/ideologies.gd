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
	assign_params(Archive.new())

func assign_params(arch: Archive):
	name = arch.ideologies[id]["name"]
	xOr = arch.ideologies[id]["x"]
	yOr = arch.ideologies[id]["y"]
	period1 = arch.ideologies[id]["period1"]
	period2 = arch.ideologies[id]["period2"]
