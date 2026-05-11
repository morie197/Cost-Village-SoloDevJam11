extends Node

var house_manager: HouseManager = null
var npc_manager: NpcManager = null
var ui_manager: UI_Manager = null

enum npc_possible_states{IDLE, WANDER, GOING_TO, INSIDE, FIGHTING}
enum npc_possible_activities{WANDERING, WORKING, INSIDE}

const day_intervals: int = 10

var day_length: float = 20
var current_time: int = 1
var time_padding: float = 2

var day_interval_length: float = 0

var accumulated_time: float = 0

var paused: bool = false

var min_events_per_day: int = 5
var max_events_per_day: int = 7

var event_trigger_times: Dictionary = {}

signal time_change(new_time: int)

func _unhandled_input(event):
	if Input.is_action_just_pressed("debug"):
		pass
		

# Called when the node enters the scene tree for the first time.
func _ready():
	day_interval_length = day_length / day_intervals


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if paused:
		return
	var current_real_time: float = (current_time * day_interval_length) + accumulated_time
	if event_trigger_times.has(floori(current_real_time)):
		var event: Dictionary = event_trigger_times[floori(current_real_time)]
		cause_event(event)
		event_trigger_times.erase(floori(current_real_time))
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
	
func cause_event(event_data):
	var event_data_keys: Array = event_data.keys()
	var event_data_values: Array = event_data.values()
	var cause_npc: String = event_data_keys[0]
	var event: Array = event_data_values[0]
	EventManager.trigger_event(cause_npc, event)
	
	
func create_events():
	var number_of_events: int = randi_range(min_events_per_day, max_events_per_day)
	var event_npcs: Array = []
	for event in range(number_of_events):
		var random_npc = npc_manager.choose_cause_npc()
		if random_npc == "":
			print("Not enough npcs")
			break
		event_npcs.append(random_npc)
	
	number_of_events = event_npcs.size()
	
	var event_time = day_length - time_padding
	if event_time - time_padding <= 0:
		print("Invalid event day length: " + str(event_time - time_padding))
		return
	for event in range(number_of_events):
		var random_trigger_time: int = randi_range(int(time_padding), event_time)
		while event_trigger_times.has(random_trigger_time):
			random_trigger_time = randi_range(int(time_padding), event_time)
			
		var random_event: Array = EventManager.get_event(event_npcs[event])
		if random_event == []:
			npc_manager.npcs_with_no_event.append(event_npcs[event])
			print("Not enough events")
			continue
		
		event_trigger_times[random_trigger_time] = {event_npcs[event]: random_event}
		
	print(event_trigger_times)
	

func get_current_activities(schedule: Schedule) -> Dictionary:
	var routines: Array = [schedule.morning_routine_1, schedule.morning_routine_2,
	schedule.day_routine_1, schedule.day_routine_2, schedule.day_routine_3, schedule.day_routine_4, schedule.day_routine_5, 
	schedule.night_routine_1, schedule.night_routine_2, schedule.night_routine_3]
	
	return routines[current_time - 1]
	
