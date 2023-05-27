extends CanvasLayer

onready var background = $Background
onready var sloganbg = $Background/SloganBG
onready var objectbg = $Background/ObjectBG
onready var slog_selector = $Background/SloganBG/Selector
onready var obj_selector = $Background/ObjectBG/Selector
onready var slogan_list = $Background/SloganBG/Slogans
onready var object_list = $Background/ObjectBG/Objects
onready var player
onready var menu = get_node(NodePath('/root/SceneManager/Menu'))
onready var ui = get_node("/root/SceneManager/UI")
onready var prize_sign = $PrizeSign
onready var prize_var = $PrizeSign/Interior/Control/PrizeVar
onready var text_box = $TextBox
onready var description = $TextBox/ColorRect/Panel/Description
onready var ideologicalDesc = $TextBox/ColorRect/Panel/Description2
onready var histDesc = $TextBox/ColorRect/Panel/Description3

onready var n_slogans = $Background/SloganBG/Slogans.get_child_count()
onready var n_objects = $Background/ObjectBG/Objects.get_child_count()
onready var open: bool = false
onready var first_accept: bool = true
var id_slogan: int = 0
var id_object: int = 0

var tmp_slogan = null
var tmp_object = null

signal priority_to_player
#signal closed

func _ready():
	menu.connect("just_bought", self, "error")
	prize_sign.visible = false
	open = false
	background.visible = false
	text_box.visible = false


func priority_to_menu():
	id_slogan = 0
	id_object = 0
	background.visible = true
	sloganbg.visible = true
	objectbg.visible = false
	text_box.visible = true
	
	open = true
	first_accept = true


func get_instance(node: Node, index: int):
	return node.get_child(index)


func _process(_delta):
	player = get_parent().get_child(0).get_child(0).find_node('Player')
	prize_sign.visible = open
	
	if open:
		if sloganbg.visible:
			id_slogan = handle_input(id_slogan, n_slogans, slog_selector)
			tmp_slogan = get_instance(slogan_list, id_slogan).slogan_res
			description.text = tmp_slogan.name
			
			for id in tmp_slogan.ideologies:
				id._ready()
			ideologicalDesc.text = str(tmp_slogan.ideologies[0].name)
			histDesc.text = str(tmp_slogan.ideologies[0].period1)
			
			
			if Input.is_action_just_pressed("ui_accept"):
				if not first_accept:
					bought("slogan")
				first_accept = false
				
			if Input.is_action_just_pressed("ui_object"):
				sloganbg.visible = false
				objectbg.visible = true
				# political_compass.visibility(false)
				
		else:
			id_object = handle_input(id_object, n_objects, obj_selector)
			tmp_object = get_instance(object_list, id_object).object_res
			description.text = tmp_object.description
			
			if Input.is_action_just_pressed("ui_accept"):
				if not first_accept:
					bought("object")
				first_accept = false
				
			if Input.is_action_just_pressed("ui_slogan"):
				sloganbg.visible = true
				objectbg.visible = false
				#political_compass.visibility(true)

		if Input.is_action_just_pressed("ui_end"):
				open = false
				priority_to_player()


func bought(type: String):
	var selected_el = null
	match type:
		"slogan":
			selected_el = get_instance(slogan_list, id_slogan)
			menu.new_slogan(selected_el.slogan_res)
		"object":
			selected_el = get_instance(object_list, id_object)
			menu.new_object(selected_el.object_res)


func error(slogan: SloganResource):
	print("Va' che l'hai già comprato, il " + slogan.name)


func handle_input(index, maxv, selector):
	if Input.is_action_just_pressed("ui_left") and index > 0:
		index -= 1
	if Input.is_action_just_pressed("ui_right") and index < maxv - 1:
		index += 1
	if Input.is_action_just_pressed("ui_down") and index < maxv - 5:
		index += 5
	if Input.is_action_just_pressed("ui_up") and index > 4:
		index -= 5
		
	selector.rect_position.x = 4 + (index % 5)*32
	selector.rect_position.y = 4 + (index / 5)*28
	return index


func priority_to_player():
	background.visible = false
	text_box.visible = false
	
	emit_signal("priority_to_player")
