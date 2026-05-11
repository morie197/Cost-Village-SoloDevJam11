extends Place
class_name House

@onready var house_enter = %house_enter

@export var house_name: String = "default"

func _ready():
	visible = false
