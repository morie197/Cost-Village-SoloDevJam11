extends CharacterBody2D
class_name NPC

@export var npc_name: String = "civilian"

@export var npc_nickname: String = ""

@onready var npc_sprite = %npc_sprite
@onready var agent = %agent

@export var npc_visual: AtlasTexture

@export var speed: float = 50

@export var schedule: Schedule

@export var npc_home_name: String = "default"

@onready var mouse_area = %mouse_area

@onready var critical = %critical
@onready var problem = %problem
@onready var complaint = %complaint
@onready var sad = %sad
@onready var happy = %happy

var unique_name: String = ""

const NPC_UI = preload("uid://bxki08on743mw")

var ui_panel: NPCUI = null

var time_until_popup_disappears: float = 2
var popup_timer: float = 0

var current_state: GameManager.npc_possible_states = GameManager.npc_possible_states.IDLE
var current_activity: GameManager.npc_possible_activities = GameManager.npc_possible_activities.WANDERING

var state_time: float = 0

var happiness: int = 5

var accumulator: float = 0
var update_rate: int = 30

var update_rate_seconds: float = 0

var target_coords: Vector2 = Vector2.ZERO :
	set(new_pos):
		if target_coords != new_pos:
			target_coords = new_pos
		if new_pos != Vector2.ZERO:
			agent.target_position = new_pos
	
var target_object: Place = null :
	set(new_object):
		if target_object != new_object:
			target_object = new_object
		if new_object != null:
			target_coords = new_object.location

#var target_achieve_distance: float = 5
var wander_distance: float = 80

var idle_time: float = 2

var happy_sad_popup_timer: float = 3

var possible_activities: Dictionary

var current_place: Place = null

var mouse_inside: bool = false

var current_event: Array = []
var current_event_targets: Array[String] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	if npc_visual != null:
		npc_sprite.texture = npc_visual
		
	var update_rate_frames = (ProjectSettings.get_setting("physics/common/physics_ticks_per_second") / update_rate)
	update_rate_seconds = 1.0 / update_rate_frames
	accumulator = randf_range(0, update_rate_seconds)

	GameManager.time_change.connect(_time_changed)
	GameManager.new_day.connect(_new_day)
	
	mouse_area.input_event.connect(_clicked)
	mouse_area.mouse_entered.connect(_mouse_etr)
	mouse_area.mouse_exited.connect(_mouse_ext)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameManager.paused:
		return
	if ui_panel != null:
		popup_timer += delta
		if not mouse_inside:
			if popup_timer >= time_until_popup_disappears:
				ui_panel.queue_free()
				ui_panel = null
				popup_timer = 0

func _physics_process(delta):
	if GameManager.paused:
		return
	accumulator += delta
	state_time += delta
	if accumulator >= update_rate_seconds:
		accumulator = 0
		_update_npc()
	_move()
	
func _new_day():
	if current_event != []:
		EventManager.force_leftover_events(unique_name, current_event_targets, current_event)
		deal_with_event()
	
func _time_changed(new_time: int):
	possible_activities = GameManager.get_current_activities(schedule)
	var old_activity = current_activity
	current_activity = _choose_new_activity()
	if current_event != []:
		return
	if old_activity != current_activity:
		_update_state_based_on_activity()
	
func change_happiness(change_amount: int):
	happiness += change_amount
	
	print("Happiness:" + str(happiness))
	
	var timer = Timer.new()
	timer.wait_time = happy_sad_popup_timer
	timer.timeout.connect(timer.queue_free)
	add_child(timer)
	if change_amount < 0:
		sad.visible = true
		timer.timeout.connect(func(): sad.visible = false)
	elif change_amount > 0:
		happy.visible = true
		timer.timeout.connect(func(): happy.visible = false)
	timer.start()
		
func trigger_event(event_data):
	_exit_state()
	_enter_state(GameManager.npc_possible_states.WANDER)
	var danger_level = event_data[0]
	var cause = event_data[1]
	var event_name = event_data[2]
	match danger_level:
		"safe":
			complaint.visible = true
		"problem":
			problem.visible = true
		"critical":
			critical.visible = true
	
	if not EventManager.events[danger_level][cause][event_name].has("targets"):
		print("invalid target for event: " + event_name)
		return
		
	var professions = EventManager.events[danger_level][cause][event_name]["targets"]
	
	for profession in professions:
		if profession == "none":
			continue
		var profession_name: String = GameManager.npc_manager.choose_npc_with_profession(profession)
		if profession_name == "":
			print("Not enough professions")
			current_event_targets.clear()
			return
		current_event_targets.append(profession_name)
	
	current_event = event_data
	
func deal_with_event():
	complaint.visible = false
	problem.visible = false
	critical.visible = false
	current_event = []
	current_event_targets = []
	GameManager.npc_manager.npcs_with_no_event.append(unique_name)
	
func _clicked(viewport, event, shape_index):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			#print(current_event)
			if current_event != []:
				#if current_event_targets == []:
				#	print("empty targets")
				#	return
				if GameManager.ui_manager.popup_event(unique_name, current_event_targets, current_event):
					deal_with_event()
				return
			if ui_panel == null:
				ui_panel = NPC_UI.instantiate()
				add_child(ui_panel)
				ui_panel.set_values(happiness, npc_name)
	
func _mouse_etr():
	mouse_inside = true
	
func _mouse_ext():
	mouse_inside = false

func _choose_new_activity() -> GameManager.npc_possible_activities:
	var cumulative_chance: int = 0
	for chance in possible_activities.values():
		cumulative_chance += chance
	var random_number: int = randi_range(1, cumulative_chance)
	var cumulative_sum: int = 0
	for activity in possible_activities:
		cumulative_sum += possible_activities[activity]
		if random_number <= cumulative_sum:
			return activity as GameManager.npc_possible_activities
			
	print("activity randomization failed!")
	print(cumulative_chance, random_number, cumulative_sum)
	return possible_activities[possible_activities.keys()[0]]
		
func _update_state_based_on_activity():
	print("Chose activity: " + str(current_activity))
	match current_activity:
		GameManager.npc_possible_activities.WANDERING:
			_exit_state()
			_enter_state(GameManager.npc_possible_states.WANDER)
		GameManager.npc_possible_activities.WORKING:
			if is_home():
				return
			_exit_state()
			_enter_state(GameManager.npc_possible_states.GOING_TO)
			if not GameManager.house_manager.check_for_house_name(npc_home_name):
				print("no home with name: " + npc_home_name + "!")
			target_object = GameManager.house_manager.houses[npc_home_name]
		GameManager.npc_possible_activities.INSIDE:
			if is_home():
				return
			_exit_state()
			_enter_state(GameManager.npc_possible_states.GOING_TO)
			if not GameManager.house_manager.check_for_house_name(npc_home_name):
				print("no home with name: " + npc_home_name + "!")
			target_object = GameManager.house_manager.houses[npc_home_name]
			
	
func is_home() -> bool:
	if current_state == GameManager.npc_possible_states.INSIDE:
		if current_place is House:
			if current_place.house_name == npc_home_name:
				return true
				
	return false
	
func _target_checks() -> bool:
	if target_coords != Vector2.ZERO:
		#if target_coords.distance_to(global_position) < target_achieve_distance:
		if agent.is_navigation_finished():
			target_coords = Vector2.ZERO
			return true
	return false
	
func _update_npc():
	var reached_target = _target_checks()
	match current_state:
		GameManager.npc_possible_states.IDLE:
			if state_time > idle_time:
				if randf() > 0.6:
					_exit_state()
				elif state_time > idle_time * 2:
					_exit_state()
				else:
					return
					
				if current_activity == GameManager.npc_possible_activities.WANDERING:
					_enter_state(GameManager.npc_possible_states.WANDER)
		GameManager.npc_possible_states.WANDER:
			if reached_target:
				_exit_state()
				_enter_state(GameManager.npc_possible_states.IDLE)
		GameManager.npc_possible_states.GOING_TO:
			if target_object != null:
				if reached_target:
					current_place = target_object
					if target_object is House:
						var target_house: House = target_object
						if GameManager.house_manager.enter_house(target_house.house_name):
							visible = false
							_exit_state()
							_enter_state(GameManager.npc_possible_states.INSIDE)
					target_object = null
					target_coords = Vector2.ZERO
		GameManager.npc_possible_states.INSIDE:
			pass
		GameManager.npc_possible_states.FIGHTING:
			pass
			
func _enter_state(state: GameManager.npc_possible_states):
	if current_state == state:
		return
	if state != GameManager.npc_possible_states.INSIDE:
		if current_place is House:
			var target_house: House = current_place
			if GameManager.house_manager.exit_house(target_house.house_name):
				visible = true
			if state == GameManager.npc_possible_states.WANDER:
				current_state = state
				target_coords = global_position + Vector2.DOWN * wander_distance
				current_place = null
				state_time = 0
				return
		current_place = null
			
	current_state = state
	state_time = 0
	match current_state:
		GameManager.npc_possible_states.IDLE:
			pass
		GameManager.npc_possible_states.WANDER:
			print("wandernew")
			var navmap = get_world_2d().get_navigation_map()
			var wander_amount: Vector2 = (Vector2(randf_range(-1, 1), randf_range(-1, 1)) * wander_distance)
			var potential_target: Vector2 = global_position + wander_amount
			target_coords = NavigationServer2D.map_get_closest_point(navmap, potential_target)
		GameManager.npc_possible_states.GOING_TO:
			pass
		GameManager.npc_possible_states.INSIDE:
			pass
		GameManager.npc_possible_states.FIGHTING:
			pass

func _exit_state():
	match current_state:
		GameManager.npc_possible_states.IDLE:
			pass
		GameManager.npc_possible_states.WANDER:
			pass
		GameManager.npc_possible_states.GOING_TO:
			pass
		GameManager.npc_possible_states.INSIDE:
			pass
		GameManager.npc_possible_states.FIGHTING:
			pass
	
func _move():
	if agent.is_navigation_finished():
		return
	var next_pos = agent.get_next_path_position()
	var moveVector = (next_pos - global_position).normalized()
	velocity = moveVector * speed
	
	move_and_slide()
