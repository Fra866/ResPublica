extends Control

#onready var menu = get_parent().get_parent()
#onready var battle_cont = $BattleSlogans/MainContainer
onready var battle_menu = $BattleSlogans
onready var battle_cont = battle_menu.container
onready var slog_cont = $MainContainer

onready var displayer = $DescriptionDisplayer

onready var manage_slogs = $ManageSlogans
onready var manage_slogs_text = $ManageSlogans/Panel/RichTextLabel
onready var ms_yes = $ManageSlogans/Panel/Container/Yes
onready var ms_no = $ManageSlogans/Panel/Container/No

enum STATE {ALL, BATTLESLOGS}
var state = STATE.ALL


func _ready():
	battle_menu.connect("battleslog_text", self, "display_bs_text")
	battle_menu.connect("switched", self, "refresh_cont")


func toggle_battleslog(vis: bool):
	#vis = vis and battle_cont.size
	state = STATE.BATTLESLOGS if vis else STATE.ALL
	
	battle_cont.shows(vis)
	
	var txt = battle_cont.current_el.get_slog_name() if battle_cont.current_el != null else "-"

	if (battle_cont.selector.visible):
		displayer.set_text(txt)
	
	slog_cont.shows(!vis)
	if (slog_cont.selector.visible):
		displayer.set_text(slog_cont.current_el.get_slog_name())
	

func prompt_manage_slogs():
	var prompt
	if state == STATE.ALL:
		prompt = "Sia '" + slog_cont.current_el.get_slog_name() + "' slogan di battaglia?"
	elif battle_cont.size:
		prompt = "Rimuovere '" + battle_cont.current_el.get_slog_name() + "'?"
	else:
		return
	
	manage_slogs_text.text = prompt
	manage_slogs.visible = true
	ms_yes.grab_focus()


func handle_input(val: int) -> void:
	if manage_slogs.visible:
		return
	
	var container: Node2D
	match state:
		STATE.ALL:
			slog_cont.move(val)
			slog_cont.selector.rect_position = get_cont_vector(slog_cont)
			var d = slog_cont.current_el
			displayer.set_text(slog_cont.current_el.get_slog_name() + str(slog_cont.current_el.res.ideologies[0].period1)) # SloganNode name
			print("Current el. ", slog_cont.current_el)
		STATE.BATTLESLOGS:
			if !slog_cont.current_el in battle_cont.get_items() and battle_cont.size < 4:
				battle_menu.move(val)


func get_cont_vector(container):
	var index = container.index
	match container:
		slog_cont:
			return Vector2(
				32 * (index % 6) + 3,
				40 * (index / 6) + 9
			)
	return null


func reload_battleslogs_menu(i: int = 0):
	for battleslog in battle_cont.get_items():
		battleslog.position = Vector2(30 * (i % 2) + 35, 40*(i / 2) + 15)
		i += 1


func display_bs_text(txt):
	displayer.set_text(txt)

func refresh_cont():
	battle_cont = battle_menu.container
