extends Control

onready var container = $MainContainer


func handle_input() -> void:
	container.move(get_cont_vector())


func get_cont_vector():
	return Vector2(
		32 * (container.index % 4) + 3,
		40 * (container.index / 4) + 16
	)
