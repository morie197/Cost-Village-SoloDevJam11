extends PanelContainer

const OPTION = preload("uid://ctsghtdnjdwug")

@onready var title_text = %title_text
@onready var event_description = %event_description
@onready var options_container = %options_container

var ignore_description: String = "Do nothing"

var current_event: Array = []

func _ready():
	visible = false
	
func handle_event(cause_npc: String, target_npcs: Array, event_data: Array):
	GameManager.pause()
	#print("cause npc: " + cause_npc)
	#print("target_npcs: " + str(target_npcs))
	#print("event_data: " + str(event_data))
	
	current_event = [cause_npc, target_npcs, event_data]
	
	visible = true
	
	var danger_level: String = event_data[0]
	var cause_npc_profession: String = event_data[1]
	var danger_name: String = event_data[2]
	
	var event = EventManager.events[danger_level][cause_npc_profession][danger_name]
	
	var cause_data = {"self" = cause_npc.capitalize()}
	var description: String = event["description"].format(cause_data)
	
	var target_data = EventManager.get_raw_target_professions(event["targets"], target_npcs)
		
	var target_data_capital: Dictionary = {}
		
	for target_profession in target_data:
		for target: String in target_npcs:
			target_data_capital[target_profession] = target.capitalize()

	for profession in target_data_capital:
		var description_target_data: Dictionary = {profession: target_data_capital[profession]}
		description = description.format(description_target_data)
	
	event_description.text = description
	var option
	
	for choice in event["choices"]:
		option = OPTION.instantiate()
		option.master = self
		option.choice_number = choice
		options_container.add_child(option)
		option.process_choice(event["choices"][choice], cause_data, target_data_capital)
		
		
	option = OPTION.instantiate()
	option.master = self
	option.choice_number = -1
	options_container.add_child(option)
	option.process_choice({"description": ignore_description, "attributes": event["attributes"]}, cause_data, target_data_capital)
	
	

func option_choosed(option_chosen: int):
	var event_data = current_event[2]
	
	var danger_level: String = event_data[0]
	var cause_npc_profession: String = event_data[1]
	var danger_name: String = event_data[2]
	
	var event = EventManager.events[danger_level][cause_npc_profession][danger_name]
	
	var self_format_data = {"self": current_event[0]}
	var target_format_data = EventManager.get_raw_target_professions(event["targets"], current_event[1])
	
	var attributes: Dictionary
	
	if option_chosen == -1:
		attributes = event["attributes"]
	else:
		attributes = event["choices"][option_chosen]["attributes"]
	var new_attributes_keys: Dictionary = {}
		
	for key in attributes:
		var final_key: String = key
		for profession in target_format_data:
			var description_target_data: Dictionary = {profession: target_format_data[profession]}
			final_key = final_key.format(self_format_data)
			final_key = final_key.format(description_target_data)
			
		new_attributes_keys[final_key] = attributes[key]

	EventManager.apply_atributes(new_attributes_keys)
	GameManager.unpause()
	visible = false
	for option in options_container.get_children():
		option.queue_free()
		current_event = []
