extends Node2D

onready var list_npc = [
	$YSort/Seller,
]

onready var player = $YSort/Player

func _ready():
	list_npc[0].is_seller = player.menu.party != null
	
	if list_npc[0].is_seller:
		list_npc[0].dialog_list = [
			"Saluti",
			"Come possiamo assisterla in questa campagna elettorale?"
		]
	else:
		list_npc[0].dialog_list = [
			"Benvenuto al negozio di slogan, dove ti proponiamo la migliore propaganda in circolazione",
			"Aspetti un attimo, lei non ha ancora un partito.",
			"Mi dispiace, ma non siamo autorizzati a dare opportunità alla plebe, o peggio ancora...",
			"... gli indipendenti"
		]
