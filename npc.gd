extends CharacterBody2D

@export var npc_name: String = "civilian"

@onready var npc_sprite = %npc_sprite
@onready var agent = %agent

@export var npc_visual: AtlasTexture

# Called when the node enters the scene tree for the first time.
func _ready():
	if npc_visual != null:
		npc_sprite.texture = npc_visual


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
