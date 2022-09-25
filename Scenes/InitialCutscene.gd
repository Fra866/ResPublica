extends Node2D

export(Array, String) var list_texts = []

onready var scene_manager = get_parent().get_parent()
onready var ui = scene_manager.get_child(5)
onready var menu = scene_manager.get_child(1)

onready var sprite = $ImageContainer/Sprite
onready var text_label = $TextContainer/RichTextLabel


func _ready():
	ui.visibility(false)
	yield(get_tree().create_timer(1), "timeout")
	
	animation()


func animation():
	for current_text in list_texts:
		text_label.text = current_text
		text_label.visible_characters = 0
		
		for _i in len(text_label.text):
			yield(get_tree().create_timer(0.05), "timeout")
			text_label.visible_characters += 1
		
		yield(get_tree().create_timer(1), "timeout")
	
	# menu.visible = true
	
	ask_name_and_gender()


func ask_name_and_gender():
	sprite.visible = false
	text_label.rect_position.y = -16
	
	text_label.text = "Come ti chiami?"
	
	start_game()


func start_game():
	scene_manager.start_transition("res://Scenes/Level1.tscn", Vector2(80, 16))
	ui.visibility(true)
