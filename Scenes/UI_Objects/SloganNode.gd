extends Node2D

export(Resource) var res
onready var sprite = $Sprite
onready var slogan = $Slogan
onready var xpbar = $XPbar


func _ready():
	for id in res.ideologies:
		id.assign_params(Archive.new())
	slogan.slogan_resource = res
	sprite.texture = res.texture


func _process(_delta):
	xpbar.value = slogan.slogan_resource.xp


func get_political_pos():
	return res.political_pos


func get_slog_name():
	return res.name
