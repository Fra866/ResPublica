extends Control

onready var battle_cont = $BattleSlogans/MainContainer
onready var slog_cont = $MainContainer

#onready var no_text = $NoSloganText
onready var displayer = $DescriptionDisplayer

onready var manage_slogs = $ManageSlogans
onready var manage_slogs_text = $ManageSlogans/Panel/RichTextLabel
onready var ms_yes = $ManageSlogans/Panel/Container/Yes
onready var ms_no = $ManageSlogans/Panel/Container/No

enum STATE {ALL, BATTLESLOGS}
var state = STATE.ALL


func toggle_battleslog(vis: bool):
	if battle_cont.size:
		battle_cont.shows(vis)
		slog_cont.shows(!vis)
		if vis:
			state = STATE.BATTLESLOGS
		else:
			state = STATE.ALL


func prompt_manage_slogs():
	var prompt
	if state == STATE.ALL:
		prompt = "Sia '{_}' slogan di battaglia?".format(slog_cont.current_el.get_slog_name())
	else:
		prompt = "Rimuovere '{_}'?".format(battle_cont.current_el.get_slog_name())
	
	manage_slogs_text.text = prompt
	manage_slogs.visible = true
	ms_yes.grab_focus()


func handle_input() -> void:
	if !manage_slogs.visible:
		var container: Node2D
		match state:
			STATE.ALL:
				container = slog_cont
			STATE.BATTLESLOGS:
				if !slog_cont.current_el in battle_cont.get_items() and battle_cont.size < 4:
					container = battle_cont
				else:
					return
		container.move(get_cont_vector(container))
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
