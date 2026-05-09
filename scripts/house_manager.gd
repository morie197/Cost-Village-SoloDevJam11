extends Node
class_name HouseManager

var houses: Dictionary[String, Array] = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.house_manager = self
	
	for house in get_children():
		if house is not House:
			continue
		else:
			if houses.has(house.house_name):
				houses[house.house_name].append(house)
			else:
				houses[house.house_name] = [house]
			
	print(houses)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
