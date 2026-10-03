extends CharacterBody3D
class_name Player

@export var walk_speed:float = 5.0
@export var run_speed:float = 8.0
@export var jump_velocity:float = 4.5
@export var acceleration:float = 15.0
@export var air_acceleration:float = 10.0
@export var mouse_sensitivity:float = 0.002
@export var stick_force:float = 2.0
@export var slide_spd_req:float = 7.0
@export var push_off_wall_force:float = 2.0

@onready var head:Node3D = $Head
@onready var debug_velocity: Label3D = $Head/DebugVelocity
@onready var debug_state: Label3D = $Head/DebugState

var coyote_timer: Timer
var wall_grab_timer: Timer

## this is a helper value for checking horizontal velocity, it doesn't change players horizontal velocity
var horizonal_velocity: Vector2 = Vector2.ZERO
var wall_normal: Vector3

func _ready() -> void:
	coyote_timer = Timer.new()
	coyote_timer.one_shot = true
	coyote_timer.wait_time = 0.25
	add_child(coyote_timer)
	
	wall_grab_timer = Timer.new()
	wall_grab_timer.one_shot = true
	wall_grab_timer.wait_time = 0.2
	add_child(wall_grab_timer)

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

func _process(_delta: float) -> void:
	horizonal_velocity = Vector2(velocity.x, velocity.z)
	
	debug_velocity.text = "Vel: %.2f" % velocity.length()
	debug_state.text = $StateMachine.current_state.name
