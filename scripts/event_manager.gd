extends Node

var resource_path: String = "res://resources/Jammmy - Sheet1.csv"

var events: Dictionary = {
	"safe": {},
	"problem":{},
	"critical":{}
		
}

var event_chances: Dictionary = {
	"safe": 90,
	"problem": 10,
	"critical": 0
}

var experienced_events: Dictionary = {
	"safe": {},
	"problem": {},
	"critical": {}
}

var planned_events: Dictionary = {}

#func _unhandled_input(event):
	#if Input.is_action_just_pressed("debug"):
		#trigger_event("blacksmith")

# Called when the node enters the scene tree for the first time.
func _ready():
	create_event_dictionary()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func create_event_dictionary():
	var read = FileAccess.open(resource_path, FileAccess.READ)
	
	read.get_csv_line()
	
	while not read.eof_reached():
		var line = read.get_csv_line()
		var danger_level: String = line[1]
		var danger_name: String = line[0]
		var danger_text: String = line[2]
		var is_choice: bool = false
		if line[3].to_lower() == "true":
			is_choice = true
			
		var danger_attributes: Dictionary = {}
		var attributes: Array = line[4].split(";")
		for attribute in attributes:
			var clean_attribute = attribute.strip_edges()
			var parts: Array = clean_attribute.split(" ")
			danger_attributes[parts[0]] = int(parts[1])
			
		var causes: Array = ["none"]
		var targets: Array = ["none"]
		var subjects = line[5].split(";")
		if subjects.size() > 0:
			causes = subjects[0].strip_edges().split(",")
		if subjects.size() > 1:
			targets = subjects[1].strip_edges().split(",")
			
		if not events.has(danger_level):
			print("Unknown danger level: " + danger_level)
		
		var danger_entry = {
			"description": danger_text,
			"attributes": danger_attributes
		}
		
		for cause in causes:
			if not events[danger_level].has(cause):
				events[danger_level][cause] = {}
			if events[danger_level][cause].has(danger_name):
				if is_choice:
					if not events[danger_level][cause][danger_name].has("choices"):
						events[danger_level][cause][danger_name]["choices"] = {}
					var choices_length: int = events[danger_level][cause][danger_name]["choices"].size()
					events[danger_level][cause][danger_name]["choices"][choices_length] = danger_entry
				else:
					print("Already danger with name: " + danger_name)
		
			else:
				danger_entry["causes"] = causes
				danger_entry["targets"] = targets
				if not events[danger_level].has(cause):
					events[danger_level][cause] = {}
				events[danger_level][cause][danger_name] = danger_entry
				
		print(events)

func choose_random_event(trigger_npc: String) -> Dictionary:
	var safety_level: String
	var cumulative_chance: int = 0
	for chance in event_chances.values():
		cumulative_chance += chance
	var random_number: int = randi_range(1, cumulative_chance)
	var cumulative_sum: int = 0
	for level in event_chances:
		cumulative_sum += event_chances[level]
		if random_number <= cumulative_sum:
			safety_level = level
			break
	
	if not events.has(safety_level):
		print("No safety level with: " + safety_level)
		return {}
		
	if events[safety_level].size() == 0:
		print("Empty safety level: " + safety_level)
		return {}
		
	if not events[safety_level].has(trigger_npc):
		print("No trigger for npc with: " + trigger_npc)
		if events[safety_level].has("anyone"):
			trigger_npc = "anyone"
		else:
			print("No trigger for any npcs")
	
	var chosen_event
	
	var unique_events: Array = []
	if experienced_events[safety_level].has(trigger_npc):
		unique_events = events[safety_level][trigger_npc].keys().filter(func(event) : return not experienced_events[safety_level][trigger_npc].has(event))
	else:
		unique_events = events[safety_level][trigger_npc].keys()
	
	if unique_events.size() == 0:
		print("no unique events")
		chosen_event = events[safety_level][trigger_npc].keys()[randi_range(0, events[safety_level][trigger_npc].size() - 1)]
		
	else:
		var random_event_index: int = randi_range(0, unique_events.size() - 1)
		chosen_event = unique_events[random_event_index]
		if not experienced_events[safety_level].has(trigger_npc):
			experienced_events[safety_level][trigger_npc] = {}
		experienced_events[safety_level][trigger_npc][chosen_event] = 1
	
	return {[safety_level, trigger_npc, chosen_event]: events[safety_level][trigger_npc][chosen_event]}
	
func get_event(trigger_npc: String) -> Array:
	var role: String = trigger_npc
	if randi_range(0, 2) > 1:
		role = "anyone"
	
	var event = choose_random_event(role)
	print(event)
	if event == {}:
		print("Not a valid event!")
		return []
	var event_keys = event.keys()
	#print(event_keys[0])
	if event_keys[0].size() < 3:
		print("Not enough keys!")
		return []
	var event_key_name = event_keys[0][2]
	var event_value = event.values()
	if planned_events.has(event_key_name):
		print("already event: " + str(event_key_name) + " going on!")
		return []
	
	planned_events[event_key_name] = event_value
	
	return event_keys[0]
		
func trigger_event(npc_cause: String, event: Array):
	print("Cause: " + npc_cause)
	print("Event data: " + str(event))
	
	if not GameManager.npc_manager.unique_npcs.has(npc_cause):
		print("No npc with unique game: " + npc_cause)
		return
	GameManager.npc_manager.unique_npcs[npc_cause].trigger_event(event)
	
