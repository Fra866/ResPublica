extends Control

#onready var menu = get_parent().get_parent()
onready var battle_cont = $BattleSlogans/MainContainer
onready var slog_cont = $MainContainer

onready var displayer = $DescriptionDisplayer

onready var manage_slogs = $ManageSlogans
onready var manage_slogs_text = $ManageSlogans/Panel/RichTextLabel
onready var ms_yes = $ManageSlogans/Panel/Container/Yes
onready var ms_no = $ManageSlogans/Panel/Container/No

enum STATE {ALL, BATTLESLOGS}
var state = STATE.ALL


func toggle_battleslog(vis: bool):
	vis = vis and battle_cont.size
	state = STATE.BATTLESLOGS if vis else STATE.ALL
	battle_cont.shows(vis)
	slog_cont.shows(!vis)
	

func prompt_manage_slogs():
	var prompt
	if state == STATE.ALL:
		prompt = "Sia '" + slog_cont.current_el.get_slog_name() + "' slogan di battaglia?"
	else:
		prompt = "Rimuovere '" + battle_cont.current_el.get_slog_name() + "'?"
	
	manage_slogs_text.text = prompt
	manage_slogs.visible = true
	ms_yes.grab_focus()


func handle_input(val: int) -> void:
	var container: Node2D
	match state:
		STATE.ALL:
			container = slog_cont
		STATE.BATTLESLOGS:
			if !slog_cont.current_el in battle_cont.get_items() and battle_cont.size < 4:
				container = battle_cont
			else:
				return
	container.move(val)
	container.selector.rect_position = get_cont_vector(container) # To abstract.
	displayer.set_text(container.current_el.get_slog_name())


func get_cont_vector(container):
	var index = container.index
	match container:
		slog_cont:
			return Vector2(
				32 * (index % 6) + 3,
				40 * (index / 6) + 9
			)
		battle_cont:
			return Vector2(
				32 * (index % 2) + 23,
				40 * (index / 2) + 3
			)
	return null


func reload_battleslogs_menu(i: int = 0):
	for battleslog in battle_cont.get_items():
		battleslog.position = Vector2(30 * (i % 2) + 35, 40*(i / 2) + 15)
		i += 1
