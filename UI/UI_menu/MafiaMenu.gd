extends Control

onready var container = $MainContainer

func handle_input() -> void:
	container.move(get_cont_vector())
	var current_el = container.current_el
	var string = current_el.npc_name + "\n" + str(current_el.mafia_target)
	container.set_text(string)


func get_cont_vector():
	return Vector2(
		32 * (container.index % 4) + 3,
		40 * (container.index / 4) + 16
	)
