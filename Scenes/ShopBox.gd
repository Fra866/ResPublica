extends CanvasLayer
export(int) var firstTime
var file1 = "res://gabibbo.txt"
var test = "res://gabibbo.tres"
var slogans = []

onready var background = $Background
onready var selecter = $Background/Background2/Selecter
onready var player
onready var menu = get_node(NodePath('/root/SceneManager/Menu'))
onready var ui = get_node("/root/SceneManager/UI")
onready var prize_sign = $PrizeSign
onready var prize_var = $PrizeSign/Interior/Control/PrizeVar

onready var open: bool = false
onready var first_accept: bool = true
var index_element: int = 0

signal priority_to_player
#signal closed

func _ready():
	prize_sign.visible = false
	open = false
	background.visible = false

func priority_to_menu():
	index_element = 0
	background.visible = true
	open = true
	first_accept = true

func get_slogan_instance(index):
	return get_node(NodePath("Background/Background2/Node2D/SloganNode" + str(index + 1)))

func _process(_delta):
	player = get_parent().get_child(0).get_child(0).find_node('Player')
	prize_sign.visible = open
	
	if open:
		prize_var.text = str(get_slogan_instance(index_element).slogan_res.prize)
		if Input.is_action_just_pressed("ui_left") and index_element > 0:
			index_element -= 1
		if Input.is_action_just_pressed("ui_right") and index_element < 19:
			index_element += 1
		
		if Input.is_action_just_pressed("ui_down") and index_element < 15:
			index_element += 5
		if Input.is_action_just_pressed("ui_up") and index_element > 4:
			index_element -= 5
	
		if Input.is_action_just_pressed("ui_accept"):
			if not first_accept:
				brought(index_element)
			first_accept = false
	
		if Input.is_action_just_pressed("ui_end"):
			index_element = 0
			open = false
			priority_to_player()
	
		selecter.rect_position.x = 4 + (index_element % 5)*32
		selecter.rect_position.y = 4 + (index_element / 5)*28


func brought(i_element):
	var selected_slogan = get_slogan_instance(i_element)
	# slogans.append(selected_slogan)
	
#	print(selected_slogan.slogan_res in menu.slogan_list)
	
	menu.new_slogan(selected_slogan.slogan_res)

func save(path):
	var file = File.new()
	file.open(path, File.READ_WRITE)
	for s in menu.slogan_list:
		file.store_line(s.slogan_res.get_path())

func priority_to_player():
	background.visible = false
	player.get_priority()
