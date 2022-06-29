extends Control
var meta = Meta.new()

onready var b1 = $Panel/Container/Button
onready var b2 = $Panel/Container/Button2
onready var b3 = $Panel/Container/Button3

var started_game: bool = false

func _ready():
	b1.grab_focus()


func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") and !started_game:
		var scene = load("res://Scenes/SceneManager.tscn").instance()
	
		if b1.has_focus():
			scene.save_file = load("res://Saved/save01.tres")
			# scene.save_file.initialize()
		elif b2.has_focus():
			scene.save_file = load("res://Saved/save02.tres")
		else:
			get_tree().quit()
		
		get_child(0).queue_free()
		started_game = true
		get_tree().get_root().add_child(scene)
