extends Resource
class_name SloganResource

export(int) var xp = 30
export(Vector2) var political_pos # Y = Auth-Liberal axis, X = Left-Right Axis
export(Array, Vector2) var damage_area
export(String) var name
export(Texture) var texture = load("res://Images/Slogans/costituzione2.png")
export(int) var id = 0
export(int) var prize = 50


# casa_loro
# 0, -12 | 34, -12 | 34, 24 | 0, 24

# cose_buone
# 4, -12 | 34, -12 | 34, 8 | 4, 8

# humani
# 0, -18 | 43, -18 | 43, 16 | 0, 16

# impero
# 4, -50 | 84, -50 | 84, -34 | 4, -34

# riforma
# 4, -50 | 84, -50 | 84, -34 | 4, -34

# stalin
# 3, -50 | 32, -50 | 32, -32 | 3, -32
