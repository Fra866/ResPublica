extends Node2D

export(Resource) var slogan_res
onready var sprite = $Sprite
onready var slogan = $Slogan
onready var xpbar = $XPbar

# export(int) var prize
# export(String) var path_texture


func _ready():
	for id in slogan_res.ideologies:
		id.assign_params(Archive.new())
	slogan.slogan_resource = slogan_res
#	WHEN THE SPRITES WILL BE READY:
	sprite.texture = slogan_res.get_text()
#	sprite.texture = load('res://Images/Slogans/' + path_texture)


func _process(_delta):
	xpbar.value = slogan.slogan_resource.xp


func get_political_pos():
	return slogan_res.political_pos
