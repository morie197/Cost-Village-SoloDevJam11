extends Resource
class_name Schedule

enum possible_activities{WANDERING, WORKING, INSIDE}

@export var morning_routine_1: Dictionary[possible_activities, float]
@export var morning_routine_2: Dictionary[possible_activities, float]
	
@export var day_routine_1: Dictionary[possible_activities, float]
@export var day_routine_2: Dictionary[possible_activities, float]
@export var day_routine_3: Dictionary[possible_activities, float]
@export var day_routine_4: Dictionary[possible_activities, float]
@export var day_routine_5: Dictionary[possible_activities, float]

@export var night_routine_1: Dictionary[possible_activities, float]
@export var night_routine_2: Dictionary[possible_activities, float]
@export var night_routine_3: Dictionary[possible_activities, float]
