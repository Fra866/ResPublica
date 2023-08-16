extends Node2D

onready var c1 = $Control/C1
onready var c2 = $Control/C2
onready var c3 = $Control/C3

onready var d_list: Array
onready var next_dialog_delimiters: Array
onready var npc_id: int


func _ready():
	c1.grab_focus()


func _on_C1_pressed():
	send_response(int(next_dialog_delimiters[0]))


func _on_C2_pressed():
	send_response(int(next_dialog_delimiters[1]))


func _on_C3_pressed():
	send_response(int(next_dialog_delimiters[2]))


func send_response(delimiter: int):
	visible = false
	
	var dialog_box = load("res://UI/DialogBox.tscn").instance()
	dialog_box.i = delimiter
	get_parent().add_child(dialog_box)
	dialog_box.display_dialog(npc_id, false)
	# get_parent().remove_child(self)
