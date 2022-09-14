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


func _ready():
	pass

func init(enemy: Sprite):
	npc_name = enemy.npc_name
	npc_desc = enemy.npc_desc
	sex = enemy.sex
	political_pos = enemy.political_pos
	lvl = enemy.lvl
	votes = enemy.votes
	max_hp = enemy.max_hp
	popularity = enemy.popularity
	mafia_points = enemy.mafia_points
