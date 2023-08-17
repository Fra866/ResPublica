extends Node2D

onready var list = $Control
onready var d_list: Array
onready var next_dialog_delimiters: Array
onready var npc_id: int


func add(text):
	var b = Button.new()
	list.add_child(b)
	b.text = text
	b.rect_position.y = 30 * b.get_index()
	if b.get_index() == 0:
		b.grab_focus()
	
	b.connect("pressed", self, "send_response", [b.get_index()])


func send_response(id_arr):
	visible = false
	
	var delimiter = int(next_dialog_delimiters[id_arr])
	var dialog_box = load("res://UI/DialogBox.tscn").instance()
	dialog_box.i = delimiter
	get_parent().add_child(dialog_box)
	dialog_box.display_dialog(npc_id, false)
	# get_parent().remove_child(self)
