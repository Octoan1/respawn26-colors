extends CharacterBody3D
class_name Player

@export var speed:float = 5.0
@export var jump_velocity:float = 4.5
@export var acceleration:float = 25.0
@export var mouse_sensitivity:float = 0.002

@onready var head:Node3D = $Head

var coyote_timer: Timer

func _ready() -> void:
	coyote_timer = Timer.new()
	coyote_timer.wait_time = 0.25

func _unhandled_input(event: InputEvent) -> void:
	# recapture mouse 
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# allow releasing mouse	
	if event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event is InputEventMouseMotion:
		if not Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			return
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
