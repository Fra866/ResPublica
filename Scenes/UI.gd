extends CanvasLayer


onready var shop = get_node(NodePath("../ShopBox"))
onready var liracoin = $Node2D/MoneyCount/RichTextLabel
onready var votes = $Node2D/VotesCount/RichTextLabel
onready var screentransition = get_node(NodePath('/root/SceneManager'))


func _ready():
	liracoin.text = str(screentransition.save_file.money)


func visible(vis: bool):
	$Node2D.visible = vis


func add_money(m: int):
	var liracoin =  $Node2D/MoneyCount/RichTextLabel
	liracoin.text = str(int(liracoin.text) + m)
	
func add_votes(v: int):
	var votes =  $Node2D/VotesCount/RichTextLabel
	votes.text = str(int(votes.text) + v)


func loadLira(val):
#	print(val)
	liracoin.text = val


func get_money():
	return int(liracoin.text)
