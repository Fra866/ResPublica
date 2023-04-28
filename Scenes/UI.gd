extends CanvasLayer

onready var shop = get_node(NodePath("../ShopBox"))
onready var liracoin = $Liracoin/RichTextLabel
onready var votes = $Votes/RichTextLabel
onready var hp = $HP/RichTextLabel
onready var lvl: int = 1
onready var screentransition = get_node(NodePath('/root/SceneManager'))
onready var menu = get_node(NodePath('/root/SceneManager/Menu'))
onready var lvlUp: bool = false

onready var lvl_table = {
	1: 200,
	2: 700,
	3: 1000,
}

func _ready():
	liracoin.text = str(screentransition.save_file.money)


func add_money(m: int):
	var liracoin = $Liracoin/RichTextLabel
	liracoin.text = str(int(liracoin.text) + m)


func add_votes(v: int):
	lvlUp = lvl_table[lvl] > menu.party.votes
	if lvlUp:
		lvl += 1
	loadVotes(menu.party.votes)


func loadLira(val):
	liracoin.text = val


func loadVotes(val:int):
	print(val)
	votes.text = str(val)


func get_money():
	return int(liracoin.text)


func visibility(v: bool):
	$Liracoin.visible = v
	$Votes.visible = v
	$HP.visible = v

func get_votes():
	return int(votes.text)
