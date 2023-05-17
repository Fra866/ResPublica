extends Node2D

export(Array, String) var list_texts = []

onready var scene_manager = get_parent().get_parent()
onready var ui = get_node(NodePath("/root/SceneManager/UI"))
onready var menu = scene_manager.get_child(1)
onready var name_label = menu.get_child(0).get_child(0).get_child(1).get_child(4)

onready var sprite = $ImageContainer/Sprite
onready var text_label = $TextContainer/RichTextLabel
onready var input_name_edit = $AskForName/LineEdit
onready var buttons_container = $AskForGender
onready var buttons = [$AskForGender/Panel/Man, $AskForGender/Panel/Woman]

enum STATE_CUTSCENE {INTRO, ASKING_NAME, ASKING_GENDER}
onready var state = STATE_CUTSCENE.INTRO


func _ready():
	buttons_container.visible = false
	input_name_edit.visible = false
	ui.visibility(false)
	yield(get_tree().create_timer(1), "timeout")
	
	animation()


func animation():
	for current_text in list_texts:
		text_label.text = current_text
		text_label.visible_characters = 0
			
		for letter in len(current_text):
			yield(get_tree().create_timer(0.05), "timeout")
			text_label.visible_characters += 1
		
		yield(get_tree().create_timer(1), "timeout")
	
	# menu.visible = true
	
	ask_name()


func ask_name():
	state = STATE_CUTSCENE.ASKING_NAME
	sprite.visible = false
	text_label.rect_position.y = -16
	text_label.text = "Come ti chiami?"
	
	for i in len(text_label.text):
		text_label.visible_characters = i
	
	input_name_edit.visible = true
	input_name_edit.grab_focus()
	
	# start_game()


func ask_gender():
	buttons_container.visible = true
	state = STATE_CUTSCENE.ASKING_GENDER
	
	text_label.text = "Sei uomo o donna?"
	
	for i in len(text_label.text):
		text_label.visible_characters = i
	
	buttons[0].grab_focus()


func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		if state == STATE_CUTSCENE.ASKING_NAME and len(input_name_edit.text) >= 3:
			name_label.text = input_name_edit.text
			scene_manager.save_file.name = name_label.text
			input_name_edit.visible = false
			
			ask_gender()
		
		elif state == STATE_CUTSCENE.ASKING_GENDER:
			name_label.text = input_name_edit.text
			scene_manager.save_file.name = name_label.text
			input_name_edit.visible = false
			
			start_game()


func start_game():
	scene_manager.start_transition(scene_manager.first_scene_path, Vector2(32, 96))
	ui.visibility(true)
