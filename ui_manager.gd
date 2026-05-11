extends CanvasLayer
class_name UI_Manager

@onready var event_popup = %event_popup

@onready var gold_amount = %gold_amount
@onready var food_amount = %food_amount
@onready var wood_amount = %wood_amount
@onready var potions_amount = %potions_amount
@onready var tools_amount = %tools_amount

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.ui_manager = self
	GameManager.values_changed.connect(_values_changed)
	
	_values_changed()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _values_changed():
	gold_amount.text = str(GameManager.gold)
	food_amount.text = str(GameManager.food)
	wood_amount.text = str(GameManager.wood)
	potions_amount.text = str(GameManager.potions)
	tools_amount.text = str(GameManager.tools)

func popup_event(cause_npc: String, target_npcs: Array, event: Array):
	event_popup.handle_event(cause_npc, target_npcs, event)
