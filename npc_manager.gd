extends Node
class_name NpcManager

var npcs: Dictionary[String, Array] = {}
var unique_npcs: Dictionary[String, NPC] = {}

var npcs_with_no_event: Array[String] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.npc_manager = self
	
	var npcs_seen: Dictionary = {}
	
	for node in get_children():
		if node is not NPC:
			continue
		var npc: NPC = node
		var unique_npc_name = npc.npc_name
		if not npcs_seen.has(unique_npc_name):
			npcs_seen[unique_npc_name] = 1
		else:
			npcs_seen[unique_npc_name] += 1
			unique_npc_name += str(npcs_seen[unique_npc_name])
			
		unique_npcs[unique_npc_name] = npc
		npc.unique_name = unique_npc_name
			
		if npcs.has(npc.npc_name):
			npcs[npc.npc_name].append(npc)
		else:
			npcs[npc.npc_name] = [npc]

	npcs_with_no_event = unique_npcs.keys()
	
	GameManager.create_events()
	
func choose_random_npc() -> String:
	var possible_npcs: Array = npcs_with_no_event
	if possible_npcs.size() == 0:
		print("No more npcs available!")
		return ""
	var random_npc = possible_npcs[randi_range(0, possible_npcs.size() - 1)]
	return random_npc
	
func choose_cause_npc() -> String:
	if not npcs_with_no_event.size() >= 1:
		print("Not enough npcs available")
		return ""
	var cause = choose_random_npc()
	#print("Cause npc: " + cause)
	#print(npcs_with_no_event)
	npcs_with_no_event.erase(cause)
	#print(npcs_with_no_event)
		
	return cause

func choose_npc_with_profession(profession: String) -> String:
	if npcs_with_no_event.size() == 0:
			print("No npcs available")
			#print(npcs_with_no_event)
			return ""
	
	if profession == "anyone":
		return npcs_with_no_event[randi_range(0, npcs_with_no_event.size() - 1)]
		
	if not npcs.has(profession):
		print("No profession called: " + profession)
		
	for npc in npcs[profession]:
		if npcs_with_no_event.has(npc.unique_name):
			return npc.unique_name
	print("No npcs available with profession: " + profession)
	return ""
	
func change_happiness(target_unique_name, change: int):
	if not unique_npcs.has(target_unique_name):
		print("No npc with the name: " + target_unique_name)
		return
	
	var target = unique_npcs[target_unique_name]
	target.change_happiness(change)
