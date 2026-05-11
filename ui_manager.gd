extends CanvasLayer
class_name UI_Manager

@onready var event_popup = %event_popup

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.ui_manager = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func popup_event(cause_npc: String, target_npcs: Array, event: Array):
	event_popup.handle_event(cause_npc, target_npcs, event)
