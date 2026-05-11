extends CanvasLayer
class_name UI_Manager

@onready var event_popup = %event_popup

@onready var gold_amount = %gold_amount
@onready var food_amount = %food_amount
@onready var wood_amount = %wood_amount
@onready var potions_amount = %potions_amount
@onready var tools_amount = %tools_amount

@onready var death_sound = %death_sound

@onready var try_again_button = %try_again_button
@onready var you_lost = %you_lost
@onready var you_win = %you_win

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.ui_manager = self
	GameManager.values_changed.connect(_values_changed)
	GameManager.lost_game.connect(_lost_game)
	GameManager.won_game.connect(_won_game)
	you_lost.visible = false
	you_win.visible = false
	
	try_again_button.pressed.connect(GameManager.restart)
	
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

func popup_event(cause_npc: String, target_npcs: Array, event: Array) -> bool:
	if event_popup.in_event:
		return false
	event_popup.handle_event(cause_npc, target_npcs, event)
	return true
	
func _lost_game():
	GameManager.pause()
	you_lost.visible = true

func _won_game():
	GameManager.pause()
	you_win.visible = true
