extends CanvasLayer

onready var label = $MarginContainer/Panel/RichTextLabel
onready var container
var m_text: String
var maxchar: int
var rect_x : int
var words = []
var line_id = 0


func _ready():
	rect_x = label.rect_size.x
#	Should be rect_x / font's width. Got to find a way to compute the latter, as Godot only shows the height.
	maxchar = 16
#	split(m_text)
#	display()


func _process(_delta):
	if Input.is_action_just_pressed("ui_down") and line_id < label.get_line_count() - 1:
		line_id += 3
		label.scroll_to_line(line_id)
	if Input.is_action_just_pressed("ui_up") and line_id > 2:
		line_id -= 3
		label.scroll_to_line(line_id)
	if Input.is_action_just_pressed("ui_end"):
		self_close()


#func self_load():
#	container = 
#	container.add_child(self)

func self_close():
	self.queue_free()


func split(text: String):
	var word = ""
	for i in len(text):
		if text[i] != ' ' or '\n':
			word += text[i]
		else:
			word += text[i]
			words.append(word)
			word = ""

	words.append(word)

func display():
	var c = 0
	for wd in words:
		if c + len(wd) > maxchar:
			label.newline()
			c = 0
		label.add_text(wd)
		c += len(wd)
