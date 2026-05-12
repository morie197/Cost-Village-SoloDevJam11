extends Control
class_name NPCUI

@onready var happiness = %happiness
@onready var npc_name = %npc_name

func set_values(happiness_level: int, npc_name_string: String):
	happiness.text = "Happiness: " + str(happiness_level)
	npc_name.text = npc_name_string.capitalize()
	
	print(size)
	
	position -= Vector2(size.x/2.0, size.y + 8)
