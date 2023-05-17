extends Resource
class_name SloganResource

export(int) var xp = 30
export(int) var power = 1
export(int) var att = 10
export(int) var def = 10
export(String) var name
export(Array, Resource) var ideologies
export(Texture) var texture = load("res://Images/Slogans/costituzione2.png")
export(int) var id = 0
export(int) var prize = 50

export(Vector2) var political_pos

func get_text():
	return texture
