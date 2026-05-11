extends PanelContainer

@onready var option_text = %option_text
@onready var option_result = %option_result

var choice_number: int = 0

var master = null

var accidental_press_hoken: float = 0.5
var time_since_created: float = 0

var original_panel_color: Color
var selected_panel_color: Color = Color(0.75, 0.75, 0.75, 0.75)
var invalid_panel_color: Color = Color(0.75, 0.0, 0.0, 0.75)

var invalid: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var panel = get_theme_stylebox("panel").duplicate()
	add_theme_stylebox_override("panel", panel) #make unique
	original_panel_color = panel.bg_color
	
	gui_input.connect(_gui_event)
	mouse_entered.connect(_enter)
	mouse_exited.connect(_exit)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if time_since_created < accidental_press_hoken:
		time_since_created += delta
	

func _enter():
	toggle_panel_color(false)
	
func _exit():
	toggle_panel_color(true)
	
func toggle_panel_color(original: bool):
	if invalid:
		return
	var panel = get_theme_stylebox("panel")
	
	if original:
		panel.bg_color = original_panel_color
	else:
		panel.bg_color = selected_panel_color
		
func invalid_option():
	var panel = get_theme_stylebox("panel")
	invalid = true
	panel.bg_color = invalid_panel_color

func _gui_event(event):
	if invalid:
		return
		
	if time_since_created < accidental_press_hoken:
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			master.option_choosed(choice_number)

func process_choice(choice: Dictionary, self_format_data: Dictionary, target_format_data: Dictionary):
	
	var description: String = choice["description"].format(self_format_data)
	var attributes: Dictionary = choice["attributes"]
	var new_attributes_keys: Dictionary = {}
	
	for profession in target_format_data:
		var description_target_data: Dictionary = {profession: target_format_data[profession]}
		description = description.format(description_target_data)
		
	for key in attributes:
		var final_key: String = key
		for profession in target_format_data:
			var description_target_data: Dictionary = {profession: target_format_data[profession]}
			final_key = final_key.format(self_format_data)
			final_key = final_key.format(description_target_data)
			
		new_attributes_keys[final_key] = attributes[key]
	
	option_text.text = description
	
	var event_data = master.current_event[2]
	
	var danger_level: String = event_data[0]
	var cause_npc_profession: String = event_data[1]
	var danger_name: String = event_data[2]
	
	var event = EventManager.events[danger_level][cause_npc_profession][danger_name]
	
	var original_self_format_data = {"self": master.current_event[0]}
	var original_target_format_data = EventManager.get_raw_target_professions(event["targets"], master.current_event[1])
	print("Original: " + str(original_target_format_data))
	
	var original_attributes: Dictionary = {}
	
	if choice_number == -1:
		original_attributes = event["attributes"]
	else:
		original_attributes = event["choices"][choice_number]["attributes"]
		
	var original_attribute_keys: Dictionary = {}
		
	for key in original_attributes:
		var final_key: String = key
		final_key = final_key.format(original_self_format_data)
		for profession in original_target_format_data:
			final_key = final_key.format(original_target_format_data)
			
		original_attribute_keys[final_key] = original_attributes[key]
	
	for key: String in original_attribute_keys:
		print("Key: " + key)
		if option_result.text != "":
			option_result.text += " / "
		
		var amount = int(original_attribute_keys[key])
		var amount_text: String = str(amount)
		if amount >= 0:
			amount_text = "+" + amount_text
			amount_text = "[color=green]" + amount_text + "[/color]"
		else:
			amount_text = "[color=red]" + amount_text + "[/color]"
		if key.contains("happiness"):
			#
			var happiness_target = key.split(",")[0]
			#print(happiness_target)
			if not GameManager.npc_manager.unique_npcs.has(happiness_target):
				#print(GameManager.npc_manager.unique_npcs)
				print("INVALID HAPPINESS TARGET: " + happiness_target)
				continue
			var current_target_happiness: String = str(GameManager.npc_manager.unique_npcs[happiness_target].happiness)
			option_result.text += GameManager.npc_manager.unique_npcs[happiness_target].npc_nickname.capitalize() + ": [hint=Happiness][img=16x16]res://resources/happiness.tres[/img][/hint] " + current_target_happiness + amount_text
		elif key.contains("dead"):
			var dead_target = key.split(",")[0]
			if not GameManager.npc_manager.unique_npcs.has(dead_target):
				#print(GameManager.npc_manager.unique_npcs)
				print("INVALID DEAD TARGET  : " + dead_target)
				continue
			option_result.text += GameManager.npc_manager.unique_npcs[dead_target].npc_nickname.capitalize() + ": [hint=Death][img=16x16]res://resources/dead.tres[/img][/hint] "
		elif key == "tool":
			if -amount > GameManager.tools:
				invalid_option()
			option_result.text += "[hint=Tools][img=16x16]res://resources/tools.tres[/img][/hint] " + amount_text
		elif key == "gold":
			if -amount > GameManager.gold:
				invalid_option()
			option_result.text += "[hint=Gold][img=16x16]res://resources/gold.tres[/img][/hint] " + amount_text
		elif key == "food":
			if -amount > GameManager.food:
				invalid_option()
			option_result.text += "[hint=Food][img=16x16]res://resources/food.tres[/img][/hint] " + amount_text
		elif key == "potions":
			if -amount > GameManager.potions:
				invalid_option()
			option_result.text += "[hint=Potions][img=16x16]res://resources/potions.tres[/img][/hint] " + amount_text
		elif key == "wood":
			if -amount > GameManager.wood:
				invalid_option()
			option_result.text += "[hint=Wood][img=16x16]res://resources/wood.tres[/img][/hint] " + amount_text
		else:
			invalid_option()
			print("Unknown resource: " + key)
	
	
	
