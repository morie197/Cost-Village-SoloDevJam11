extends PanelContainer

@onready var option_text = %option_text
@onready var option_result = %option_result


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

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
	
	for key: String in new_attributes_keys:
		if option_result.text != "":
			option_result.text += " / "
		
		var amount = int(new_attributes_keys[key])
		var amount_text: String = str(amount)
		if amount >= 0:
			amount_text = "+" + amount_text
			amount_text = "[color=green]" + amount_text + "[/color]"
		else:
			amount_text = "[color=red]" + amount_text + "[/color]"
		if key.contains("happiness"):
			var happiness_target = key.split(",")[0]
			option_result.text += happiness_target + ": [hint=Happiness][img=16x16]res://resources/happiness.tres[/img][/hint] " + amount_text
		elif key == "tool":
			option_result.text += "[hint=Tools][img=16x16]res://resources/tools.tres[/img][/hint] " + amount_text
		elif key == "gold":
			option_result.text += "[hint=Gold][img=16x16]res://resources/gold.tres[/img][/hint] " + amount_text
		elif key == "food":
			option_result.text += "[hint=Food][img=16x16]res://resources/food.tres[/img][/hint] " + amount_text
		elif key == "potions":
			option_result.text += "[hint=Potions][img=16x16]res://resources/potions.tres[/img][/hint] " + amount_text
		elif key == "wood":
			option_result.text += "[hint=Wood][img=16x16]res://resources/wood.tres[/img][/hint] " + amount_text
		else:
			print("Unknown resource: " + key)
	
	#[hint=This is the blacksmith]{blacksmith} [img=32x32]res://icon.svg[/img][/hint] dropped an iron hammer.
	
