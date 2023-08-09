extends Node2D

onready var current_scene: Node
onready var menu = $Menu
onready var ui = $UI
onready var transition_animation = $ScreenTransition/AnimationPlayer
onready var scene_container = $CurrentScene

onready var list_visited_scenes: Array
onready var ended_cutscenes: Array

onready var save_file
onready var slot: int
onready var loading_count: int = 1

signal new_main_scene

var scene
var first_scene_path = "res://Scenes/GameLocations/BarScene.tscn"

signal p

func _ready():
	print(save_file.battleslogs)
	ended_cutscenes = save_file.ended_cutscenes
	
	for i in scene_container.get_children():
		i.queue_free()
	
	scene = save_file.current_scene
	
	if !scene:
		starting_game()
	
	scene_container.add_child(scene.instance())
	ended_cutscenes = save_file.ended_cutscenes
	current_scene = scene_container.get_child(0)
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
	current_scene = scene_container.get_children().back()
	transition_animation.play("FadeToTransparent")
	var p = current_scene.find_node("Player")
	if p:
		p.position = player_pos
		p.new_scene()
	
	emit_signal("new_main_scene")


func starting_game():
	scene = load("res://Scenes/InitialCutscene.tscn")


func to_battle(path: String, pos: Vector2, npc):
	var prev = current_scene.name
	var cur_pos = current_scene.find_node("Player").position
	
	start_transition(path, pos)
	current_scene.set_npc(npc)
	current_scene.set_attacks(npc.attack_ids)
	current_scene.set_next_scene(prev, cur_pos)
