extends Node2D

export(Resource) var object_res
onready var sprite = $Sprite
onready var object = $GameObject

# export(int) var prize
# export(String) var path_texture

func _ready():
	object.game_object_resource = object_res
#	WHEN THE SPRITES WILL BE READY:
	sprite.texture = object_res.texture
#	sprite.texture = load('res://Images/Objects/' + path_texture)


func foo(id: int):
	print("Foo (object_node)")
	# print(get_child(0).game_object_resource.use_script.open)
	var script = load(object_res.use_script.get_path()).new()
	
#	if script.wrapper:
#		get_node(script.path).add_child(script.wrapper)
#	script.foo(id, true)
