extends Sprite

export(String) var npc_name
export(String) var npc_desc = ""
export(String, "Uomo", "Donna") var sex
# In order to register the party (in real life elections), 
# you need a list with at least 40% of candidates to have 
# the same sex/gender.
export(Vector2) var political_pos
export(int) var lvl
export(int) var votes
export(int) var max_hp
export(float, -100, 100, 10) var popularity #Extra votes at the elections when appointing the voter as a candidate
export(float, -100, 100, 10) var mafia_points # How capturing the enemy will influence the Mafiometer
export(float, 0, 100, 10) var mafia_target


func _ready():
	pass

func init(enemy, battle:= false):
	if battle:
		npc_name = enemy.name
		npc_desc = enemy.description
		texture = load(enemy.battle_sprite_path)
	else:
		npc_name = enemy.npc_name
	sex = enemy.sex
	political_pos = enemy.political_pos
	lvl = enemy.lvl
	votes = enemy.votes
	max_hp = enemy.max_hp
	popularity = enemy.popularity
	mafia_points = enemy.mafia_points
	mafia_target = enemy.mafia_target


func set_mafia_target(val: int):
	if mafia_target > 0:
		mafia_target -= val
