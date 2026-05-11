extends Node
class_name HouseManager

var houses: Dictionary[String, House] = {}
var house_occupants: Dictionary[House, int] = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.house_manager = self
	
	var houses_seen: Dictionary = {}
	
	for node in get_children():
		if node is House:
			var house: House = node
			var house_name = house.house_name
			house_occupants[house] = 0
			if houses.has(house.house_name):
				print("already house with name: " + house.house_name + "!")
				
			if not houses_seen.has(house.house_name):
				houses_seen[house.house_name] = 1
			else:
				houses_seen[house.house_name] += 1
				house_name += str(houses_seen[house.house_name])
			houses[house_name] = house
			
	#print(houses)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func check_for_house_name(house_name: String) -> bool:
	if not houses.has(house_name):
		print("no house with name: " + house_name)
		return false
	
	var house = houses[house_name]
	if not house_occupants.has(house):
		print("house doesn't exist: " + house_name)
		return false
		
	return true

func enter_house(house_name: String) -> bool:
	if not check_for_house_name(house_name):
		return false
	
	var house = houses[house_name]
	house_occupants[house] += 1
	return true
	
func exit_house(house_name: String) -> bool:
	if not check_for_house_name(house_name):
		return false
	
	var house = houses[house_name]
	house_occupants[house] -= 1
	return true
	
	
	
	
