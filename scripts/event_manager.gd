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

func _unhandled_input(event):
	if Input.is_action_just_pressed("debug"):
		choose_random_event()

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
			
		if not events.has(danger_level):
			print("Unknown danger level: " + danger_level)
		
		var danger_entry = {
			"description": danger_text,
			"attributes": danger_attributes
		}
		
		if events[danger_level].has(danger_name):
			if is_choice:
				if not events[danger_level][danger_name].has("choices"):
					events[danger_level][danger_name]["choices"] = {}
				var choices_length: int = events[danger_level][danger_name]["choices"].size()
				events[danger_level][danger_name]["choices"][choices_length] = danger_entry
			else:
				print("Already danger with name: " + danger_name)
		
		else:
			events[danger_level][danger_name] = danger_entry

func choose_random_event():
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
		return
		
	if events[safety_level].size() == 0:
		print("Empty safety level: " + safety_level)
		return
		
	var chosen_event
		
	var unique_events: Array = events[safety_level].keys().filter(func(event) : return not experienced_events[safety_level].has(event))
	
	if unique_events.size() == 0:
		print("no unique events")
		chosen_event = events[safety_level].keys()[randi_range(0, events[safety_level].size() - 1)]
		return
	
	var random_event_index: int = randi_range(0, unique_events.size() - 1)
	chosen_event = unique_events[random_event_index]
	experienced_events[safety_level][chosen_event] = 1
	
	print(chosen_event)
	
	
	
	
	
