extends Node2D

#var next_scene = null


onready var current_scene# = get_child(0).get_child(0)
onready var dialouge_box = get_node(NodePath('/root/SceneManager/DialougeBox'))
onready var menu = $Menu
onready var ui = $UI
onready var transition_animation = $ScreenTransition/AnimationPlayer
onready var scene_container = $CurrentScene

#onready var list_npc: Array
onready var list_visited_scenes: Array
onready var ended_cutscenes: Array

onready var save_file # Saved data File
onready var slot: int # Id of file_saved slot (can be 1, 2 or 3)
onready var loading_count: int = 1

signal new_main_scene()
# signal config

var scene
var first_scene_path = "res://Scenes/InsideHouse.tscn"


func _ready():
	ended_cutscenes = save_file.ended_cutscenes
#	scene_container.get_child(0).queue_free()
	for i in scene_container.get_children():
		i.queue_free()
	
	scene = save_file.current_scene
	
	if !scene:
		starting_game()
	
	scene_container.add_child(scene.instance())
#	list_npc = save_file.list_npc
	ended_cutscenes = save_file.ended_cutscenes
	current_scene = get_child(0).get_child(0)
	transition_animation.play("FadeToTransparent")
	menu.new_p()


func cutscene_over(id):
	ended_cutscenes.append(id)



func start_transition(next_scene: String, player_pos):
	loading_count += 1
	scene = next_scene
	transition_animation.play("FadeToBlack")
	scene_container.get_child(0).queue_free()
	for i in scene_container.get_children():
		i.queue_free()

	end_transition(player_pos)


func end_transition(player_pos):
	scene_container.add_child(load(scene).instance())
	transition_animation.play("FadeToTransparent")
	var p = scene_container.get_children().back().find_node("Player")
	if p:
		p.position = player_pos
		p.new_scene()
	
	emit_signal("new_main_scene")


func starting_game():
	scene = load("res://Scenes/InitialCutscene.tscn")


#func loadAll():
#	var loaded = ResourceLoader.load(path)
#	start_transition(loaded.current_scene, loaded.player_pos)
#	ui.set("text", str(loaded.money))
#	menu.slogan_list = loaded.array
