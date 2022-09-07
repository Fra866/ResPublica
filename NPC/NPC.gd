extends StaticBody2D

# onready var player = get_node(NodePath('/root/SceneManager/CurrentScene/Level1/YSort/Player'))
onready var animplayer = $AnimationPlayer
onready var animtree = $AnimationTree
onready var sprite = $Sprite

const TILE_SIZE = 16

onready var dialouge_box = get_node(NodePath('/root/SceneManager/DialougeBox'))
onready var texture

onready var raycast = $RayCast2D

export(Array, String) var dialouge_list
export(Array, int) var attack_ids
export(Vector2) var political_pos
export(Array) var influence_area = [[],[]]
export(bool) var is_seller
export(bool) var battle_won
export(int) var votes
export(String) var battle_sprite_path
#export(int) var attack


export(String) var sprite_path

enum FacingDirection { LEFT, UP, RIGHT, DOWN }
enum NPCState { IDLE, RUN }

var npc_state = NPCState.IDLE
var direction = FacingDirection.DOWN

onready var cutscene = false
var is_moving = false
var initial_position = Vector2(0, 0)
var input_direction = Vector2(0, 0)
var percent_to_next_tile = 0.0
var walk_speed = 4

# var direction = FacingDirection.DOWN

export(int) var hf
export(int) var vf
export(int) var f


func _ready():
	setting_up_sprite()
	# animplayer.play("IdleRight")


func setting_up_sprite():
	sprite.texture = load(sprite_path)
	
	sprite.hframes = hf
	sprite.vframes = vf
	sprite.frame = f


func interaction(player):
	animtree.set("parameters/blend_position", (player.position - position) / 16)
	dialouge_box.display_dialouge(self)


func _physics_process(delta):
	if is_moving == false:
		process_player_input()
	elif input_direction != Vector2.ZERO and !cutscene:
		# animstate.travel("Run")
		move(delta)
	else:
		# animstate.travel("Idle")
		is_moving = false


func process_player_input():
	if input_direction.y == 0:
		pass
		# input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	
	if input_direction.x == 0:
		pass
	
	if input_direction != Vector2.ZERO:
		#animtree.set("parameters/Idle/blend_position", input_direction)
		#animtree.set("parameters/Run/blend_position", input_direction)
		#animtree.set("parameters/Turn/blend_position", input_direction)
		
		initial_position = position
		is_moving = true
	else:
		pass
		# animstate.travel("Idle")


func move(delta):
	# print("% to next tile" , percent_to_next_tile)
	percent_to_next_tile += (walk_speed * delta)
	
	if not raycast.is_colliding():
		if percent_to_next_tile >= 1.0:
			position = initial_position + (TILE_SIZE * input_direction)
			percent_to_next_tile = 0.0
			is_moving = false
		else:
			position = initial_position + (TILE_SIZE * input_direction * percent_to_next_tile)
	else:
		percent_to_next_tile = 0.0
		is_moving = false

