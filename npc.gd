extends CharacterBody2D
class_name NPC

@export var npc_name: String = "civilian"

@onready var npc_sprite = %npc_sprite
@onready var agent = %agent

@export var npc_visual: AtlasTexture

var current_state: GameManager.npc_possible_states = GameManager.npc_possible_states.IDLE

var state_time: float = 0

var accumulator: float = 0
var update_rate: int = 30

var update_rate_seconds: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if npc_visual != null:
		npc_sprite.texture = npc_visual
		
	var update_rate_frames = (ProjectSettings.get_setting("physics/common/physics_ticks_per_second") / update_rate)
	update_rate_seconds = 1.0 / update_rate_frames
	accumulator = randf_range(0, update_rate_seconds)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	accumulator += delta
	state_time += delta
	if accumulator >= update_rate_seconds:
		accumulator = 0
		_update_npc()
	
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
	print("idle")
	
func _going_to():
	print("going to")

func _inside():
	print("inside")

func _fighting():
	print("fighting")
	
