extends Node

var house_manager: HouseManager = null
var npc_manager: NpcManager = null

enum npc_possible_states{IDLE, WANDER, GOING_TO, INSIDE, FIGHTING}
enum npc_possible_activities{WANDERING, WORKING, INSIDE}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
