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
