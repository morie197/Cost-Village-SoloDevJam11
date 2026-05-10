extends Node

var house_manager: HouseManager = null
var npc_manager: NpcManager = null

enum npc_possible_states{IDLE, WANDER, GOING_TO, INSIDE, FIGHTING}
enum npc_possible_activities{WANDERING, WORKING, INSIDE}

const day_intervals: int = 10

var day_length: float = 180
var current_time: int = 1

var day_interval_length: float = 0

var accumulated_time: float = 0

var paused: bool = false

signal time_change(new_time: int)

func _unhandled_input(event):
	if Input.is_action_just_pressed("debug"):
		if paused:
			unpause()
		else:
			pause()
		

# Called when the node enters the scene tree for the first time.
func _ready():
	day_interval_length = day_length / day_intervals


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if paused:
		return
	accumulated_time += delta
	if accumulated_time >= day_interval_length:
		accumulated_time -= day_interval_length
		current_time += 1
		if current_time == day_intervals + 1:
			current_time = 1
			
		#print(current_time)
		time_change.emit(current_time)

func pause():
	print("paused")
	paused = true

func unpause():
	print("unpaused")
	paused = false

func get_current_activities(schedule: Schedule) -> Dictionary:
	var routines: Array = [schedule.morning_routine_1, schedule.morning_routine_2,
	schedule.day_routine_1, schedule.day_routine_2, schedule.day_routine_3, schedule.day_routine_4, schedule.day_routine_5, 
	schedule.night_routine_1, schedule.night_routine_2, schedule.night_routine_3]
	
	return routines[current_time - 1]
