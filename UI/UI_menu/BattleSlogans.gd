extends Control

enum STATE {
	ALL=0,
	ROMAN_ERA,
	MIDDLE_AGES,
	RENAISSANCE,
	MODERN_ERA
}

var state: int = STATE.ROMAN_ERA

onready var containers = [
	$AllEraContainer,
	$RomanEraContainer,
	$MiddleAgesContainer,
	$RenaissanceContainer,
	$ModernEraContainer
]

onready var container: Node2D = containers[state]
onready var label = $ColorRect/RichTextLabel

signal battleslog_text
signal switched


func _ready():
	label.text = STATE.keys()[state]
	

func move(advance: int):
	if((advance and container.index < container.size -1)
	or (!advance and container.index > 0)):
		container.move(advance)
		emit_signal("battleslog_text", container.current_el.get_slog_name())
		
		container.show_selector(true)
		container.selector.rect_position = get_vector()
	else:
		switch(advance)


func switch(advance: int):
	container.visible = false
	if advance:
		if state < len(containers) - 1:
			state += 1
	elif state:
		state -= 1
	
	container = containers[state]
	if container.current_el == null:
		emit_signal("battleslog_text", "-")
	else:
		emit_signal("battleslog_text", container.current_el.get_slog_name())
	emit_signal("switched")
	label.text = STATE.keys()[state]
	container.selector.rect_position = get_vector()
	container.visible = true


func new_battleslog(element, i: int, period: int):
	var pos = Vector2 (
		30 * ((i - 1) % 2) + 35,
		40 * ((i - 1) / 2) + 15
	)
	
	container = containers[period]
	state = period
	label.text = STATE.keys()[state]
	
	var new_slog_instance = container.new_item(pos)
	new_slog_instance.res = element.res
	new_slog_instance.visible = true
	
	container.add(new_slog_instance)
	
	emit_signal("switched")
	var a000 = container.get_items()


func meta(period: int, fn: String, arg = null):
	if arg:
		return containers[period].call(fn, arg)
	return containers[period].call(fn)


func get_vector():
	var index = container.index
	return Vector2(
		32 * (index & 1) + 23,
		40 * (index >> 1) + 3
	)
