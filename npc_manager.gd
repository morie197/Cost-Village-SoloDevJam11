extends Node
class_name NpcManager

var npcs: Dictionary[String, Array] = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.npc_manager = self
	
	for npc in get_children():
		if npc is not NPC:
			continue
		else:
			if npcs.has(npc.npc_name):
				npcs[npc.npc_name].append(npc)
			else:
				npcs[npc.npc_name] = [npc]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
