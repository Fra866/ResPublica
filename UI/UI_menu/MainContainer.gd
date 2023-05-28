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

func new_item(pos: Vector2, element = null):
	var item = load(res_path).instance()
	if element:
		item.res = element
	item.position = pos
	return item


func move(advance: int):
	if advance:
		if index < size - 1:
			index += 1
	elif index:
		index -= 1
	current_el = list.get_child(index)


func get_items():
	return list.get_children()

func get_i(index: int):
	return list.get_child(index)
