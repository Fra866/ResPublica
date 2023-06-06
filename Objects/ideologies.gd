extends Resource
class_name Ideology

export(int) var id

enum xOrientation {
	NO_ORIENTATION = 2,
	LEFT = 0,
	RIGHT = 1,
}

enum yOrientation {
	NO_ORIENTATION = 2,
	LIB = 0,
	AUTH = 1,
}

onready var xOr
onready var yOr

onready var name: String


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


func calc_extra_damage(xOr: float, yOr: float, bs):
	# id = ideology
	var extraX: float
	var extraY: float
	
	extraX = int(xOr == self.xOr && xOr != 2 && self.xOr != 2)
	extraY = int(yOr == self.yOr && yOr != 2 && self.yOr != 2)
	
	if (extraX == 0):
		if (xOr + self.xOr) == 1:
			extraX = 0.25
		else:
			extraX = 0.5
	
	if (extraY == 0):
		if (yOr + self.yOr) == 1:
			extraY = 0.25
		else:
			extraY = 0.5
