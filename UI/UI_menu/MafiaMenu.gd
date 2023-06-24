extends Control

onready var container = $MainContainer
onready var desc_displayer = $DescriptionDisplayer

func handle_input(input: int) -> void:
	container.move(input)
	var string = container.current_el.npc_name + "\n" + str(container.current_el.mafia_target)
	desc_displayer.set_text(string)
	container.selector.rect_position = get_cont_vector()


func get_cont_vector():
	return Vector2(
		32 * (container.index % 4) + 3,
		40 * (container.index / 4) + 16
	)
