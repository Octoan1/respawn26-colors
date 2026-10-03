extends Node
class_name PlayerMovement

@export_category("Ground Movement")
@export var acceleration: float = 30.0
@export var deceleration: float = 20.0

@export_category("Air Movement")
@export var air_acceleration: float = 5.0

@export_category("Vertical Movement")
@export var gravity: float = 20.0
@export var jump_velocity: float = 8.0

@onready var player: CharacterBody3D = get_parent()


func accelerate(direction: Vector3, speed: float, delta: float) -> void:
	# Accelerate toward the desired movement speed
	player.velocity.x = move_toward(
		player.velocity.x,
		direction.x * speed,
		acceleration * delta
	)

	player.velocity.z = move_toward(
		player.velocity.z,
		direction.z * speed,
		acceleration * delta
	)


func decelerate(delta: float) -> void:
	# Slow down horizontal movement
	player.velocity.x = move_toward(
		player.velocity.x,
		0.0,
		deceleration * delta
	)

	player.velocity.z = move_toward(
		player.velocity.z,
		0.0,
		deceleration * delta
	)


func air_control(direction: Vector3, delta: float) -> void:
	# Slightly change horizontal momentum while in the air
	player.velocity.x += direction.x * air_acceleration * delta
	player.velocity.z += direction.z * air_acceleration * delta


func apply_gravity(delta: float) -> void:
	# Pull the player downward
	player.velocity.y -= gravity * delta


func jump() -> void:
	# Give the player upward velocity
	player.velocity.y = jump_velocity


func get_horizontal_velocity() -> Vector2:
	# Get horizontal velocity without vertical movement
	return Vector2(player.velocity.x, player.velocity.z)


func get_horizontal_speed() -> float:
	# Get the player's horizontal speed
	return get_horizontal_velocity().length()
