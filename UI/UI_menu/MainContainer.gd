extends Node2D

export(String) var res_path
onready var list = $List
onready var selector = $Selector
var size: int = 0
var index: int = 0
var current_el


func shows(b: bool):
	selector.visible = b


func add(item: Node):
	list.add_child(item)
	if !size:
		current_el = list.get_child(0)
	size += 1

func remove(item: Node):
	list.remove_child(item)
	size -= 1
	if !size:
		current_el = null

func new_item(pos: Vector2):
	var item = load(res_path).instance()
	item.position = pos
	return item


func move(pos: Vector2):
	if Input.is_action_just_pressed("ui_right"):
		if index < size - 1:
			index += 1
	if Input.is_action_just_pressed("ui_left"):
		if index > 0:
			index -= 1
	selector.rect_position = pos
	current_el = list.get_child(index)


func get_items():
	return list.get_children()

func get_i(index: int):
	return list.get_child(index)
