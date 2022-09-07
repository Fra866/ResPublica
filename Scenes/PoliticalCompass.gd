extends Node2D

onready var main_pointer = $Pointer
onready var enemy_pointer = $Pointer2
onready var next_position = $Line2D
onready var damage_area = $ExtraDamageArea

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	main_pointer.visible = false
	enemy_pointer.visible = false
	next_position.visible = false


func visibility(vis: bool):
	visible = vis
	main_pointer.visible = vis


func reset_pointer():
	main_pointer.rect_position = Vector2(-2, -2)


func get_main_pointer():
	return main_pointer.rect_position


func set_main_pointer(x: float, y: float):
	main_pointer.visible = true
	main_pointer.rect_position = Vector2(x*4 - 2, y*4 - 2)


func move_main_pointer(x: float, y: float):
	main_pointer.rect_position.x += x
	main_pointer.rect_position.y += y


func set_enemy_pointer(x: float, y: float):
	enemy_pointer.visible = true
	enemy_pointer.rect_position = Vector2(x*4 - 2, y*4 - 2)


func set_damage_area(dm: Array):
	damage_area.polygon = dm


func hide_damage_area():
	damage_area.visible = false


func show_damage_area():
	damage_area.visible = true


func set_line(initial_pos: Vector2, x: float, y: float):
	next_position.visible = true
	next_position.points[0] = Vector2(initial_pos.x + 4, initial_pos.y + 4)
	next_position.points[1] = Vector2(x*4 + 2, y*4 + 2)


func hide_line():
	next_position.visible = false


func enemy_pointer_visible(vis: bool):
	enemy_pointer.visible = vis

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
