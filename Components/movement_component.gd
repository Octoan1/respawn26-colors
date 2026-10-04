extends Node
class_name PlayerMovement

@export_category("Ground Movement")
@export var walk_speed: float = 5.0
@export var run_speed: float = 8.0
@export var crouch_speed: float = 3.0
@export var ground_acceleration: float = 6.0
@export var ground_friction: float = 6.0

@export_category("Slide")
@export var slide_speed: float = 14.0
@export var slide_friction: float = 1.0
@export var min_speed_for_slide: float = 5.0

@export_category("Air Movement")
@export var air_acceleration: float = 800.0
@export var air_move_speed: float = 500.0
@export var air_cap: float = 0.85
@export var auto_bhop: bool = false

@export_category("Jump")
@export var jump_velocity: float = 4.5

@onready var player: Player = get_parent()


func accelerate_ground(
	direction: Vector3,
	speed: float,
	delta: float
) -> void:
	if direction == Vector3.ZERO:
		return

	# How fast we are already moving in the desired direction
	var current_speed := player.velocity.dot(direction)

	# How much speed we can still add
	var add_speed := speed - current_speed

	if add_speed <= 0.0:
		return

	# Accelerate toward the desired speed
	var acceleration_speed := ground_acceleration * delta * speed
	acceleration_speed = min(acceleration_speed, add_speed)

	player.velocity += direction * acceleration_speed


func apply_ground_friction(delta: float) -> void:
	var horizontal_velocity := Vector3(
		player.velocity.x,
		0.0,
		player.velocity.z
	)

	var speed := horizontal_velocity.length()

	if speed <= 0.0:
		return

	# Friction slows the player down
	var control: float = max(speed, 1.0)
	var drop: float = control * ground_friction * delta

	var new_speed: float = max(speed - drop, 0.0)

	horizontal_velocity *= new_speed / speed

	player.velocity.x = horizontal_velocity.x
	player.velocity.z = horizontal_velocity.z


func start_slide(direction: Vector3) -> void:
	var current_speed: float = get_horizontal_speed()
	
	var speed: float = max(current_speed, slide_speed)
	
	player.velocity.x = direction.x * speed
	player.velocity.z = direction.z * speed


func apply_slide_friction(delta: float) -> void:
	var horizontal_velocity: Vector2 = get_horizontal_velocity()

	var speed: float = horizontal_velocity.length()

	if speed <= 0.0:
		return

	var drop: float = speed * slide_friction * delta
	var new_speed: float = max(speed - drop, 0.0)

	horizontal_velocity = horizontal_velocity.normalized() * new_speed

	player.velocity.x = horizontal_velocity.x
	player.velocity.z = horizontal_velocity.y


func accelerate_air(direction: Vector3, delta: float) -> void:
	if direction == Vector3.ZERO:
		return

	# Speed already moving in the desired direction
	var current_speed: float = player.velocity.dot(direction)

	# Maximum speed we can have in the desired direction
	var capped_speed: float = min(air_move_speed * direction.length(), air_cap)

	# How much more speed we can add
	var add_speed: float = capped_speed - current_speed

	if add_speed <= 0.0:
		return

	var acceleration_speed := air_acceleration * air_move_speed * delta
	acceleration_speed = min(acceleration_speed, add_speed)

	player.velocity += acceleration_speed * direction


func jump() -> void:
	# Keep horizontal momentum
	player.velocity.y = jump_velocity


func apply_gravity(delta: float) -> void:
	player.velocity += player.get_gravity() * delta


func get_horizontal_velocity() -> Vector2:
	return Vector2(
		player.velocity.x,
		player.velocity.z
	)


func get_horizontal_speed() -> float:
	return get_horizontal_velocity().length()
