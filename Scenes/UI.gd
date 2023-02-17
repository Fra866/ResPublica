extends CanvasLayer

onready var shop = get_node(NodePath("../ShopBox"))
onready var liracoin = $Liracoin/RichTextLabel
onready var votes = $Votes/RichTextLabel
onready var hp = $HP/RichTextLabel
onready var screentransition = get_node(NodePath('/root/SceneManager'))
onready var menu = get_node(NodePath('/root/SceneManager/Menu'))


func _ready():
#	print(typeof(liracoin.text))
	liracoin.text = str(screentransition.save_file.money)
#	votes.text = str(screentransition.save_file.votes)


func add_money(m: int):
	var liracoin = $Liracoin/RichTextLabel
	liracoin.text = str(int(liracoin.text) + m)


func add_votes(v: int):
	# print(menu.party.total_votes)
	# menu.party.total_votes += v
	loadVotes(menu.party.votes)


func loadLira(val):
	liracoin.text = val


func loadVotes(val:int):
	votes.text = str(val)


func get_money():
	return int(liracoin.text)

func visibility(v: bool):
	$Liracoin.visible = v
	$Votes.visible = v
	$HP.visible = v

func get_votes():
	return int(votes.text)
