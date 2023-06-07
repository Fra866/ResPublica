extends Control

onready var container = $MainContainer

func handle_input(direction: int) -> void:
	container.move(direction)
	container.selector.rect_position = get_cont_vector()


func get_cont_vector():
	return Vector2(
		32 * (container.index % 4) + 3,
		40 * (container.index / 4) + 16
	)


func reload_voters_menu(i: int = -1):
	for v in container.get_items():
		if (i >= 0):
			print(v.npc_name, " -> ", v.position)
			v.position = Vector2(32 * (i % 4) + 5, 40 * (i / 4) + 18)
		i += 1
