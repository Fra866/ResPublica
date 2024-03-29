extends Control

onready var container = $MainContainer
onready var displayer = $DescriptionDisplayer

func handle_input(val: int) -> void:
	container.move(val)
	container.selector.rect_position = get_cont_vector()
	displayer.set_text(container.current_el.res.description)


func get_cont_vector():
	return Vector2(
		32 * (container.index % 6) + 3,
		40 * (container.index / 6) + 9
	)
