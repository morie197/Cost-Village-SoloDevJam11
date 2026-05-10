extends CharacterBody2D
class_name NPC

@export var npc_name: String = "civilian"

@onready var npc_sprite = %npc_sprite
@onready var agent = %agent

@export var npc_visual: AtlasTexture

@export var speed = 20

var current_state: GameManager.npc_possible_states = GameManager.npc_possible_states.IDLE

var state_time: float = 0

var accumulator: float = 0
var update_rate: int = 30

var update_rate_seconds: float = 0

var target_coords: Vector2 = Vector2.ZERO
var target_object: Node2D = null

var target_achieve_distance: float = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	if npc_visual != null:
		npc_sprite.texture = npc_visual
		
	var update_rate_frames = (ProjectSettings.get_setting("physics/common/physics_ticks_per_second") / update_rate)
	update_rate_seconds = 1.0 / update_rate_frames
	accumulator = randf_range(0, update_rate_seconds)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_target_checks()

func _physics_process(delta):
	accumulator += delta
	state_time += delta
	if accumulator >= update_rate_seconds:
		accumulator = 0
		_update_npc()
	_move()
	
func _target_checks() -> bool:
	if target_coords != Vector2.ZERO:
		if target_coords.distance_to(global_position) < target_achieve_distance:
			target_coords = Vector2.ZERO
			return true
	else:
		target_coords = GameManager.house_manager.houses.values()[1].global_position
		agent.target_position = target_coords
	return false
	
func _update_npc():
	match current_state:
		GameManager.npc_possible_states.IDLE:
			_idle()
		GameManager.npc_possible_states.GOING_TO:
			_going_to()
		GameManager.npc_possible_states.INSIDE:
			_inside()
		GameManager.npc_possible_states.FIGHTING:
			_fighting()
			
func _idle():
	pass
	#if _target_checks():
		#state_time
		
	
func _going_to():
	print("going to")

func _inside():
	print("inside")

func _fighting():
	print("fighting")
	
func _move():
	var next_pos = agent.get_next_path_position()
	var moveVector = (next_pos - global_position).normalized()
	velocity = moveVector * speed
	
	move_and_slide()
