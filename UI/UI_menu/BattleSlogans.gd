extends Control

enum STATE {
	ROMAN_ERA=1,
	MIDDLE_AGES,
	RENAISSANCE,
	MODERN_ERA
}

var state: int = STATE.ROMAN_ERA

onready var containers = [
	$RomanEraContainer,
	$MiddleAgesContainer,
	$RenaissanceContainer,
	$ModernEraContainer
]

onready var container: Node2D = containers[state-1]
onready var label = $ColorRect/RichTextLabel

signal battleslog_text
signal switched


func move(advance: int):
	if((advance and container.index < container.size -1)
	or (!advance and container.index)):
		container.move(advance)
		container.selector.rect_position = get_vector()
		emit_signal("battleslog_text", container.current_el.get_slog_name())
	else:
		switch(advance)


func switch(advance: int):
	container.visible = false
	if advance:
		if state < len(containers):
			state += 1
	elif state > 1:
		state -= 1
	
	container = containers[state-1]
	if container.current_el == null:
		emit_signal("battleslog_text", "-")
	else:
		emit_signal("battleslog_text", container.current_el.get_slog_name())
	emit_signal("switched")
	label.text = STATE.keys()[state-1]
	container.visible = true


func get_vector():
	var index = container.index
	return Vector2(
		32 * (index & 1) + 23,
		40 * (index >> 1) + 3
	)
