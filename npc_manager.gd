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
	npcs_with_no_event.erase(cause)
		
	return cause
