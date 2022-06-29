extends Node2D

export(Resource) var slogan_res
onready var sprite = $Sprite
onready var slogan = $Slogan

#export(int) var prize
#export(String) var path_texture

func _ready():
	slogan.slogan_resource = slogan_res
#	WHEN THE SPRITES WILL BE READY:
	sprite.texture = slogan_res.texture
#	sprite.texture = load('res://Images/Slogans/' + path_texture)

func get_political_pos():
	return slogan_res.political_pos
