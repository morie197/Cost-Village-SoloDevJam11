extends CharacterBody2D
class_name NPC

@export var npc_name: String = "civilian"

@onready var npc_sprite = %npc_sprite
@onready var agent = %agent

@export var npc_visual: AtlasTexture

@export var speed = 20

@export var schedule: Schedule

var current_state: GameManager.npc_possible_states = GameManager.npc_possible_states.IDLE

var state_time: float = 0

var accumulator: float = 0
var update_rate: int = 30

var update_rate_seconds: float = 0

var target_coords: Vector2 = Vector2.ZERO
var target_object: Node2D = null

var target_achieve_distance: float = 5
var wander_distance: float = 30

var idle_time: float = 5

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
		#if target_coords.distance_to(global_position) < target_achieve_distance:
		if agent.is_navigation_finished():
			target_coords = Vector2.ZERO
			return true
	return false
	
func _update_npc():
	match current_state:
		GameManager.npc_possible_states.IDLE:
			if state_time > idle_time:
				if randf() > 0.6:
					_exit_state()
				elif state_time > idle_time * 2:
					_exit_state()
		GameManager.npc_possible_states.WANDER:
			pass
		GameManager.npc_possible_states.GOING_TO:
			pass
		GameManager.npc_possible_states.INSIDE:
			pass
		GameManager.npc_possible_states.FIGHTING:
			pass
			
func _enter_state(state: GameManager.npc_possible_states):
	if current_state == state:
		return
	state_time = 0
	match state:
		GameManager.npc_possible_states.IDLE:
			pass
		GameManager.npc_possible_states.WANDER:
			var navmap = get_world_2d().get_navigation_map()
			var wander_amount: Vector2 = (Vector2(randf_range(-1, 1), randf_range(-1, 1)) * wander_distance)
			var potential_target: Vector2 = global_position + wander_amount
			agent.target_position = NavigationServer2D.map_get_closest_point(navmap, global_position + potential_target)
			target_coords = agent.target_position
		GameManager.npc_possible_states.GOING_TO:
			pass
		GameManager.npc_possible_states.INSIDE:
			pass
		GameManager.npc_possible_states.FIGHTING:
			pass

func _exit_state():
	match current_state:
		GameManager.npc_possible_states.IDLE:
			pass
		GameManager.npc_possible_states.WANDER:
			pass
		GameManager.npc_possible_states.GOING_TO:
			pass
		GameManager.npc_possible_states.INSIDE:
			pass
		GameManager.npc_possible_states.FIGHTING:
			pass
	
func _move():
	var next_pos = agent.get_next_path_position()
	var moveVector = (next_pos - global_position).normalized()
	velocity = moveVector * speed
	
	move_and_slide()
