extends Node

export(String) var content = "Mussolini Delenda Est"

onready var open: bool = true

onready var wrapper = load("res://Test.tscn").instance()
onready var path: NodePath = "/root/SceneManager/Menu/MenuLayers/Objects/"

onready var list_of_mail_contents = [
"""Nel mezzo delle elezioni di nostra vita,

Ci ritrovammo nella SELVA OSCURA,

Che la ritta legislatura era smarrita...
""",
"""
Si lavora e si produce per la patria e per il boss finale
""",
]

onready var text_content: String

func _ready():
	pass

# A special thanks to we-know-who for the function's name

func foo(id):
	
	content = list_of_mail_contents[id]
	wrapper.split(content)
	wrapper.display(content)
	
	return wrapper
#	func set_mail_content(id):
#	content = list_of_mail_contents[id]


func test():
	text_content = "Il vero è il soggetto, l'utile è lo scopo, l'interessante è il mezzo"
	
	wrapper.split(text_content)
	wrapper.display(text_content)


func get_mail_content():
	return content
