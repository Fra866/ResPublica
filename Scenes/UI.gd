extends CanvasLayer

onready var shop = get_node(NodePath("../ShopBox"))
onready var liracoin = $Control/RichTextLabel
onready var screentransition = get_node(NodePath('/root/SceneManager'))


func _ready():
	liracoin.text = str(screentransition.save_file.money)


func add_money(m: int):
	var liracoin = $Control/RichTextLabel
	liracoin.text = str(int(liracoin.text) + m)
	print(liracoin.text)


func loadLira(val):
	print(val)
	liracoin.text = val

func get_money():
	return int(liracoin.text)
