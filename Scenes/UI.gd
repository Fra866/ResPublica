extends CanvasLayer

onready var shop = get_node(NodePath("../ShopBox"))
onready var liracoin = $Control/RichTextLabel

func _ready():
	liracoin.text = "1000"

func lost_money(diff: int):
	liracoin.text = str(int(liracoin.text) - diff)

func loadLira(val):
	print(val)
	liracoin.text = val

func get_money():
	return int(liracoin.text)
