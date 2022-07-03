extends Node2D

onready var main_pointer = $Pointer
onready var next_pointer = $Pointer2

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	main_pointer.visible = false
	next_pointer.visible = false


func visibility(vis: bool):
	visible = vis
	main_pointer.visible = vis


func reset_pointer():
	main_pointer.rect_position = Vector2(-2, -2)


func set_main_pointer(x: float, y: float):
	main_pointer.rect_position = Vector2(x*4 - 2, y*4 - 2)


func set_next_pointer(x: float, y: float):
	next_pointer.visible = true
	next_pointer.rect_position = Vector2(x*4 - 2, y*4 - 2)


func next_pointer_visible(vis: bool):
	next_pointer.visible = vis

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
