extends HBoxContainer

@onready var day_1 = %day1
@onready var day_2 = %day2
@onready var day_3 = %day3
@onready var day_4 = %day4
@onready var day_5 = %day5

@onready var day_changed_panel = %day_changed_panel

var default_font_size: int = 64
var day_smoothness: float = 1
var day_wait: float = 0.5
var day_screen_time: float = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate = Color.TRANSPARENT
	day_changed_panel.modulate = Color.TRANSPARENT
	day_changed_panel.visible = true
	visible = true
	GameManager.new_day.connect(_update_visuals)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _update_visuals():
	if GameManager.day > 5:
		return
	var day_text: Array[RichTextLabel] = [day_1, day_2, day_3, day_4, day_5]
	var current_day_index = GameManager.day
	
	for index in range(day_text.size()):
		var distance: int = abs(index - (current_day_index - 1)) + 1
		var new_font_size: int = roundi((current_day_index/clampf(float(distance) * 1.5, 1, 5)) * float(default_font_size))
		#print(new_font_size)
		day_text[index].add_theme_font_size_override("normal_font_size", new_font_size)
		day_text[index].modulate.a = clampf(current_day_index/float(distance), 0.25, 1.0)
		print("Distance: " + str(distance))
		print(current_day_index/float(distance))
		print(day_text[index].modulate.a)
	
	var tweeny = create_tween()
	tweeny.tween_property(self, "modulate", Color.WHITE, day_wait)
	tweeny.tween_property(day_changed_panel, "modulate", Color.WHITE, day_wait)
	
	var timey = Timer.new()
	add_child(timey)
	timey.timeout.connect(timey.queue_free)
	timey.wait_time = day_wait
	timey.start()
	await timey.timeout
	
	var new_position: Vector2 = Vector2(position.x - (60 + 4), position.y)
	var tween = create_tween()
	tween.tween_property(self, "position", new_position, day_smoothness)
	%next_day_sound.play()
	
	

		
	var timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(timer.queue_free)
	timer.wait_time = day_screen_time
	timer.start()
	await timer.timeout
	
	GameManager.npc_manager.npc_create_items()
	
	var tweener = create_tween()
	tweener.tween_property(self, "modulate", Color.TRANSPARENT, day_wait)
	tweener.tween_property(day_changed_panel, "modulate", Color.TRANSPARENT, day_wait)
	
	GameManager.unpause()
