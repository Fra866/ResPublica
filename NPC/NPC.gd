extends StaticBody2D

#onready var player = get_node(NodePath('/root/SceneManager/CurrentScene/Level1/YSort/Player'))
onready var animplayer = $AnimationPlayer
onready var animtree = $AnimationTree
onready var dialouge_box = get_node(NodePath('/root/SceneManager/DialougeBox'))

export(Array, String) var dialouge_list
export(bool) var is_seller
export(Array, Resource) var slogans_for_battle
export(Vector2) var political_pos


func _ready():
	animplayer.play("IdleRight")

func interaction(player):
	animtree.set("parameters/blend_position", (player.position - position) / 16)
	dialouge_box.display_dialouge(dialouge_list, is_seller, slogans_for_battle)
	
	if len(slogans_for_battle):
		var tmp = Temp.new()
		tmp.slogans_for_battle = slogans_for_battle
		tmp.political_pos = political_pos
		ResourceSaver.save("res://NPC/tmp.tres", tmp)
