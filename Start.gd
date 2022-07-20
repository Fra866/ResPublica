extends Control
#var meta = Meta.new()

onready var b0 = $Panel/Container/Button
onready var b3 = $Panel/Container2/Button

var btn_id = 0
var new: bool = false
var scene = null
var started_game: bool = false

func _ready():
	b0.grab_focus()


func _process(_delta):
	if Input.is_action_just_pressed("ui_down"):
		if btn_id != 2 and btn_id != 6:
			btn_id += 1
	if Input.is_action_just_pressed("ui_up"):
		if btn_id != 0 and btn_id != 3:
			btn_id -= 1

	if Input.is_action_just_pressed("ui_accept") and !started_game:
		scene = load("res://Scenes/SceneManager.tscn").instance()
		parse_input(btn_id)


func parse_input(id: int):
	match id:
		0:
			switch_menu($Panel/Container2, $Panel/Container)
			btn_id = 3
			b3.grab_focus()
			new = true
		1:
			switch_menu($Panel/Container2, $Panel/Container)
			btn_id = 3
			b3.grab_focus()
		2:
			get_tree().quit()
		3, 4, 5:
			scene.save_file = load("res://Saved/save0" + str(id - 2) + ".tres")
			if new:
				scene.save_file.initialize()
			start()
		6:
			switch_menu($Panel/Container, $Panel/Container2)
			new = false
			btn_id = 0
			b0.grab_focus()


func switch_menu(main_menu, side_menu):
	main_menu.visible = true
	side_menu.visible = false

func start():
		get_child(0).queue_free()
		started_game = true
		get_tree().get_root().add_child(scene)
