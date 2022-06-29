extends Node2D

var next_scene = null

onready var player = get_node(NodePath('/root/SceneManager/CurrentScene/Level1/YSort/Player'))
onready var current_scene = get_child(0).get_child(0)
onready var dialouge_box = get_node(NodePath('/root/SceneManager/DialougeBox'))
onready var menu = $Menu
onready var ui = $UI/Control/RichTextLabel
onready var transition_animation = $ScreenTransition/AnimationPlayer
onready var scene_container = $CurrentScene

onready var save_file # Saved data File
onready var slot: int # Id of file_saved slot (can be 1 or 2)
onready var loading_count: int = 1

signal new_main_scene

func _ready():
	scene_container.get_child(0).queue_free()
	for i in scene_container.get_children():
		i.queue_free()
	
	scene_container.add_child(save_file.current_scene.instance())
	
	current_scene = get_child(0).get_child(0)
	
	transition_animation.play("FadeToTransparent")


func start_transition(scene: String, player_pos):
	loading_count += 1
	next_scene = scene
	transition_animation.play("FadeToBlack")
	
	scene_container.get_child(0).queue_free()
	for i in scene_container.get_children():
		i.queue_free()

	end_transition(player_pos)


func end_transition(player_pos):
	scene_container.add_child(load(next_scene).instance())
	transition_animation.play("FadeToTransparent")
	var p = scene_container.get_children().back().find_node("Player")
	if p:
		p.position = player_pos
	emit_signal("new_main_scene")

#func loadAll():
#	var loaded = ResourceLoader.load(path)
#	start_transition(loaded.current_scene, loaded.player_pos)
#	ui.set("text", str(loaded.money))
#	menu.slogan_list = loaded.array
