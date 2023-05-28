extends Node2D

export(Resource) var res
onready var sprite = $Sprite
onready var slogan = $Slogan
onready var xpbar = $XPbar

# export(int) var prize
# export(String) var path_texture


func _ready():
	for id in res.ideologies:
		id.assign_params(Archive.new())
	slogan.slogan_resource = res
#	WHEN THE SPRITES WILL BE READY:
	sprite.texture = res.texture
#	sprite.texture = load('res://Images/Slogans/' + path_texture)


func _process(_delta):
	xpbar.value = slogan.slogan_resource.xp


func get_political_pos():
	return res.political_pos


func get_slog_name():
	return res.name
