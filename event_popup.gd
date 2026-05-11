extends PanelContainer

const OPTION = preload("uid://ctsghtdnjdwug")

@onready var title_text = %title_text
@onready var event_description = %event_description
@onready var options_container = %options_container

func _ready():
	visible = false
	
func handle_event(cause_npc: String, target_npcs: Array, event_data: Array):
	print("cause npc: " + cause_npc)
	print("target_npcs: " + str(target_npcs))
	print("event_data: " + str(event_data))
	
	visible = true
	
	var danger_level: String = event_data[0]
	var cause_npc_profession: String = event_data[1]
	var danger_name: String = event_data[2]
	
	var event = EventManager.events[danger_level][cause_npc_profession][danger_name]
	
	var cause_data = {"self" = cause_npc.capitalize()}
	var description: String = event["description"].format(cause_data)
	
	var target_data = {}
	
	for target_profession in event["targets"]:
		var raw_profession: String = target_profession.rstrip("0123456789")
		var id_number: String = target_profession.erase(0, raw_profession.length())
		for target: String in target_npcs:
			match raw_profession:
				"anyone":
					var data_name = "random" + str(id_number)
					if target_data.has(data_name):
						print("Already have that profession!")
					target_data[data_name] = target.capitalize()
				"blacksmith":
					var data_name = "blacksmith" + str(id_number)
					if target_data.has(data_name):
						print("Already have that profession!")
					target_data[data_name] = target.capitalize()
				"wizard":
					var data_name = "wizard" + str(id_number)
					if target_data.has(data_name):
						print("Already have that profession!")
					target_data[data_name] = target.capitalize()
				"lumberjack":
					var data_name = "lumberjack" + str(id_number)
					if target_data.has(data_name):
						print("Already have that profession!")
					target_data[data_name] = target.capitalize()
				"civilian":
					var data_name = "civilian" + str(id_number)
					if target_data.has(data_name):
						print("Already have that profession!")
					target_data[data_name] = target.capitalize()
				_:
					print("Unknown profession: " + target_profession)
			
	for profession in target_data:
		var description_target_data: Dictionary = {profession: target_data[profession]}
		description = description.format(description_target_data)
	
	event_description.text = description
	
	for choice in event["choices"]:
		var option = OPTION.instantiate()
		options_container.add_child(option)
		option.process_choice(event["choices"][choice], cause_data, target_data)
