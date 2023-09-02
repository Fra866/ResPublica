extends Control

onready var battle = get_parent()
onready var label = $MarginContainer/Panel/RichTextLabel
var dialog = []
var last = 0
var current = 0

signal done

func _ready():
	margin_top = 192
	margin_left = 160
	
	dialog = [
		"Scegli uno slogan per attaccare:",
		"più è vicino alla sua ideologia, più lo convincerai.",
		"Se fai scendere i suoi punti vita a 15, potrai catturarlo,",
		"così da farlo entrare nel tuo partito.",
		"E sei hai paura o hai preso troppi danni, te ne puoi sempre anna'."
	]
	battle.battlemenu.visible = false
	battle.set_process(false)


func close():
	last = 0
	current = 0
	battle.slogButton.grab_focus()
	battle.battlemenu.visible = true
	battle.set_process(true)
	queue_free()


func _input(event):
	if event.is_action_pressed("ui_accept"):
		if last < len(dialog):
			display_text_line(dialog[last])
			current = last
			last += 1
		else:
			close()
	
	if event.is_action_pressed("ui_left"):
		if current > 0:
			current -= 1
			label.set_text(dialog[current])
	if event.is_action_pressed("ui_right"):
		if current < last - 1:
			current += 1
			label.set_text(dialog[current])


func display_text_line(line: String):
	label.set_text(line)
	label.percent_visible = 0.0
	while(label.percent_visible < 1):
		label.percent_visible += 1.0/len(line)
		yield(get_tree().create_timer(0.01), "timeout")
	yield(get_tree().create_timer(0.5), "timeout")
