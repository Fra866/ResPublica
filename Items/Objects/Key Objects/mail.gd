extends Node

export(String) var content = """
"""

# Called when the node enters the scene tree for the first time.
func _ready():
	print(content)


# A special thanks to we-know-who for the function's name
func foo():
	# I plan to work on the mail displayer later
	print(content)
