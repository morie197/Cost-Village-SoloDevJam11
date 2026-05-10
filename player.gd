extends Node2D

@onready var camera = %Camera2D

var speed: float = 500
var zoom_min: float = 1
var zoom_max: float = 3

var zoom_in_amount: float = 0.8
var zoom_out_amount: float = 1.4

var scroll_amount: float = 1

var max_distance_from_center: float = 500
var center_position: Vector2

func _unhandled_input(event):
	if Input.is_action_pressed("zoom_in"):
		scroll_amount = zoom_in_amount
	elif Input.is_action_pressed("zoom_out"):
		scroll_amount = zoom_out_amount

# Called when the node enters the scene tree for the first time.
func _ready():
	center_position = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_zoom(delta)
	
func _physics_process(delta):
	_move(delta)
	
func _move(_delta):
	var move_input: Vector2 = Input.get_vector("left", "right", "up", "down")
	if move_input == Vector2.ZERO:
		return
		
	var tween = create_tween()
	var move_amount: Vector2 = move_input * (speed / camera.zoom.x) * _delta
	var move_pos: Vector2 = global_position + move_amount
	var offset_from_center: Vector2 = move_pos - center_position
	
	offset_from_center  = Vector2(clampf(offset_from_center.x, -max_distance_from_center, max_distance_from_center), clampf(offset_from_center.y, -max_distance_from_center, max_distance_from_center))
	
	#if offset_from_center.length() > max_distance_from_center:
	#	offset_from_center = offset_from_center.limit_length(max_distance_from_center)
	
	tween.tween_property(self, "global_position", center_position + offset_from_center, _delta)
		
func _zoom(_delta):
	if scroll_amount != 1.0:
		var new_zoom = clampf(camera.zoom.x * scroll_amount, zoom_min, zoom_max)
		
		scroll_amount = 1.0
		
		var tween = create_tween()
		tween.tween_property(camera, "zoom", Vector2(new_zoom, new_zoom), 0.1)
