extends KinematicBody2D

export(float) var walk_speed = 4.0

const TILE_SIZE = 16

onready var NPCraycast = $NPCRayCast2D
onready var DoorRayCast = $DoorRayCast2D
onready var ObjectRayCast = $ObjectRayCast2D
onready var camera = $Camera2D
onready var animtree = $AnimationTree
onready var animplayer = $AnimationPlayer
onready var animstate = animtree.get('parameters/playback')
# onready var dialog_box = get_node(NodePath('/root/SceneManager/DialogBox'))
onready var shop_box = get_node(NodePath('/root/SceneManager/ShopBox'))
onready var scenemanager = get_node(NodePath('/root/SceneManager'))
onready var menu = get_node(NodePath('/root/SceneManager/Menu'))
onready var saveMenu = get_node(NodePath("/root/SceneManager/Control"))
onready var ui = get_node(NodePath('/root/SceneManager/UI'))

onready var p_name = scenemanager.save_file.name

enum PlayerState { IDLE, RUNNING, TURNING, IN_PAUSE }
enum FacingDirection { LEFT, UP, RIGHT, DOWN }

onready var current_open_menu = null
onready var cutscene = false


var is_moving = false
var initial_position = Vector2(0, 0)
var input_direction = Vector2(0, 0)
var percent_to_next_tile = 0.0
var player_state = PlayerState.IDLE
var direction = FacingDirection.DOWN

signal enter_door(door)

func _ready():
	var current_scene = scenemanager.get_child(0).get_child(0)
	
	if not current_scene.name in scenemanager.list_visited_scenes:
		scenemanager.list_visited_scenes.append(current_scene.name)
	var save_file = scenemanager.save_file
	visible = true
	animtree.active = true
	if scenemanager.loading_count == 1:
		position = save_file.player_pos
	else:
		initial_position = position
	
	shop_box.connect("priority_to_player", self, "get_priority")


func _physics_process(delta):
	if cutscene:
		player_state = PlayerState.IN_PAUSE
	if player_state == PlayerState.TURNING:
		return
	elif is_moving == false:
		process_player_input()
	elif input_direction != Vector2.ZERO and !cutscene:
		animstate.travel("Run")
		move(delta)
	else:
		animstate.travel("Idle")
		is_moving = false


func process_player_input():
	if not player_state == PlayerState.IN_PAUSE and !cutscene:
		if input_direction.y == 0:
			input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
			
		if input_direction.x == 0:
			input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
			
		if input_direction != Vector2.ZERO:
			animtree.set("parameters/Idle/blend_position", input_direction)
			animtree.set("parameters/Run/blend_position", input_direction)
			animtree.set("parameters/Turn/blend_position", input_direction)
		
			if need_to_turn():
				player_state = PlayerState.TURNING
				animstate.travel("Turn")
			else:
				initial_position = position
				is_moving = true
		else:
			animstate.travel("Idle")
	
	else:
		animstate.travel("Idle")
	
	if Input.is_action_just_pressed("ui_menu"):
		openClose(menu)
	
	if Input.is_action_just_pressed("ui_save"):
		openClose(saveMenu)


func openClose(m):
	if player_state != PlayerState.IN_PAUSE:
		open_menu(m)
	elif (current_open_menu == m) and m.priority_to_player():
		close_menu()


func open_menu(m):
	cutscene = true
	current_open_menu = m
	m.priority_to_menu()


func close_menu():
	cutscene = false
	current_open_menu = null
	player_state = PlayerState.IDLE


func collided_with_npc(npc):
	print(npc.name)
	npc.interaction(self)


func entered_door(door):
	cutscene = true
	visible = false
	camera.clear_current()
#Or: door.entering()
	emit_signal("enter_door", door)


func new_scene():
	visible = true
	camera.current = true
	player_state = PlayerState.IDLE


func move(delta):
	calculate_npcraycast(NPCraycast)
	calculate_npcraycast(DoorRayCast)
	calculate_npcraycast(ObjectRayCast)
	
	percent_to_next_tile += (walk_speed * delta)
	
	if not NPCraycast.is_colliding() and not DoorRayCast.is_colliding() and not ObjectRayCast.is_colliding() and player_state != PlayerState.IN_PAUSE:
		if percent_to_next_tile >= 1.0:
			position = initial_position + (TILE_SIZE * input_direction)
			percent_to_next_tile = 0.0
			is_moving = false
		else:
			position = initial_position + (TILE_SIZE * input_direction * percent_to_next_tile)
	else:
		percent_to_next_tile = 0.0
		is_moving = false
		if Input.is_action_just_pressed("ui_accept"):
			if NPCraycast.is_colliding():
				cutscene = true
				var npc = NPCraycast.get_collider()
				collided_with_npc(npc)
			elif DoorRayCast.is_colliding():
					entered_door(DoorRayCast.get_collider())


func need_to_turn():
	var new_facing_direction
	if input_direction.x < 0:
		new_facing_direction = FacingDirection.LEFT
	elif input_direction.x > 0:
		new_facing_direction = FacingDirection.RIGHT
	elif input_direction.y < 0:
		new_facing_direction = FacingDirection.UP
	elif input_direction.y > 0:
		new_facing_direction = FacingDirection.DOWN
	
	if direction != new_facing_direction:
		direction = new_facing_direction
		return true
	direction = new_facing_direction
	return false


func finished_turning():
	player_state = PlayerState.IDLE


func calculate_npcraycast(raycast):
	match direction:
		0:
			raycast.cast_to = Vector2(-8, 0)
		1:
			raycast.cast_to = Vector2(0, -8)
		2:
			raycast.cast_to = Vector2(8, 0)
		3:
			raycast.cast_to = Vector2(0, 8)
	raycast.force_raycast_update()


func get_priority():
	cutscene = false
	player_state = PlayerState.IDLE


func set_position(pos):
	position = pos
	initial_position = pos
