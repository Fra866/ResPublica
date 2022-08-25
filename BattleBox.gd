extends Node2D

onready var player_pointer = $PanelContainer/PlayerPointer


func _ready():
	pass


func move_pointer(input_direction: Vector2):
	player_pointer.position += input_direction
