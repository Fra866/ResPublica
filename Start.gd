extends Control
var meta = Meta.new()

onready var b1 = $Panel/Container/Button
onready var b2 = $Panel/Container/Button2
onready var b3 = $Panel/Container/Button3
onready var scene
onready var save_menu
var started_game: bool = false

onready var path_save_file: String
onready var new_game: bool
#onready var config_file = load("res://Saved/config.tres")


func _ready():
	b1.grab_focus()


func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") and !started_game:
		scene = load("res://Scenes/SceneManager.tscn").instance()


func start():
	get_child(0).queue_free()
	started_game = true
	get_tree().get_root().add_child(scene)


func _on_Button_pressed():
	new_game = true
	$Panel/Container.visible = false
	$Panel/Container2.visible = true
	$Panel/Container2/Save1.grab_focus()
	
	$Panel/Container2/Save1.grab_focus()

func _on_Button2_pressed():
	new_game = false
	$Panel/Container.visible = false
	$Panel/Container2.visible = true
	$Panel/Container2/Save1.grab_focus()


func _on_Button3_pressed():
	get_tree().quit()


func _on_Save1_pressed():
	if new_game:
		path_save_file = "res://Saved/save01.tres"
		
		$Panel/Container2.visible = false
		$Panel/Container3.visible = true
		$Panel/Container3/No.grab_focus()
	else:
		scene.save_file = load("res://Saved/save01.tres")
		start()


func _on_Save2_pressed():
	if new_game:
		path_save_file = "res://Saved/save02.tres"
		
		$Panel/Container2.visible = false
		$Panel/Container3.visible = true
		$Panel/Container3/No.grab_focus()
	else:
		scene.save_file = load("res://Saved/save02.tres")
		start()


func _on_Save3_pressed():
	if new_game:
		path_save_file = "res://Saved/save03.tres"
		
		$Panel/Container2.visible = false
		$Panel/Container3.visible = true
		$Panel/Container3/No.grab_focus()
	else:
		scene.save_file = load("res://Saved/save03.tres")
		start()


func _on_Yes_pressed():
	scene.save_file = load(path_save_file)
	scene.save_file.initialize()
#	scene.save_file = load("res://Saved/config.tres")
	start()
	scene.get_child(6).save_all() # SaveMenu


func _on_No_pressed():
	$Panel/Container.visible = true
	$Panel/Container2.visible = false
	$Panel/Container3.visible = false
	b1.grab_focus()


func _on_Exit_pressed():
	$Panel/Container.visible = true
	$Panel/Container2.visible = false
	b1.grab_focus()
