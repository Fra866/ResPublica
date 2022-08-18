#extends ObjectResource
extends Node

export(String) var content = """
Mussolini Delenda Est
"""
var wrapper = load("res://Test.tscn").instance()

var list_of_mail_contents = [
	"""
	Nel mezzo delle elezioni di nostra vita,
	Ci ritrovammo nella SELVA OSCURA,
	Che la ritta legislatura era smarrita...
	""",
	
	"""
	Si lavora e si produce per la patria e per il boss finale
	""",
]

func _ready():
	print(content)


# A special thanks to we-know-who for the function's name
func foo(id):
	content = list_of_mail_contents[id]
	wrapper.split(content)
	wrapper.display()


# func set_mail_content(id):
#	content = list_of_mail_contents[id]


func get_mail_content():
	return content
