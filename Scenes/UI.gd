extends CanvasLayer

onready var shop = get_node(NodePath("../ShopBox"))
onready var liracoin = $Liracoin/RichTextLabel
onready var votes = $Votes/RichTextLabel
onready var screentransition = get_node(NodePath('/root/SceneManager'))


func _ready():
	liracoin.text = str(screentransition.save_file.money)


func add_money(m: int):
	var liracoin = $Liracoin/RichTextLabel
	liracoin.text = str(int(liracoin.text) + m)


func add_votes(v: int):
	var votes = $Votes/RichTextLabel
	votes.text = str(int(votes.text) + v)


func loadLira(val):
	liracoin.text = val


func loadVotes(val):
	votes.text = val


func get_money():
	return int(liracoin.text)


func get_votes():
	return int(votes.text)
