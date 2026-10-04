extends Node
class_name PlayerMovement

@export_category("Ground Movement")
@export var walk_speed:float = 5.0
@export var run_speed:float = 8.0
@export var ground_acceleration:float = 15.0
@export var ground_deceleration: float = 10.0
@export var slide_spd_req:float = 5.1

@export_category("Air Movement")
@export var air_acceleration: float = 10.0
@export var air_speed: float = 8.0

@export_category("Vertical Movement")
@export var gravity: float = 20.0
@export var jump_velocity: float = 6.0

@export_category("Wall Movement")
@export var stick_force:float = 2.0
@export var push_off_wall_force:float = 2.0


@onready var player: CharacterBody3D = get_parent()


func accelerate(direction: Vector3, speed: float, delta: float) -> void:
	# Accelerate toward the desired movement speed
	player.velocity.x = move_toward(
		player.velocity.x,
		direction.x * speed,
		ground_acceleration * delta
	)

	player.velocity.z = move_toward(
		player.velocity.z,
		direction.z * speed,
		ground_acceleration * delta
	)


func decelerate(delta: float) -> void:
	# Slow down horizontal movement
	player.velocity.x = move_toward(
		player.velocity.x,
		0.0,
		ground_deceleration * delta
	)

	player.velocity.z = move_toward(
		player.velocity.z,
		0.0,
		ground_deceleration * delta
	)


func air_control(direction: Vector3, delta: float) -> void:
	# Target direction based on input
	var target_velocity := direction * run_speed
	
	# Gradually steer existing momentum toward the target
	player.velocity.x = move_toward(
		player.velocity.x,
		target_velocity.x,
		air_acceleration * delta
	)
	
	player.velocity.z = move_toward(
		player.velocity.z,
		target_velocity.z,
		air_acceleration * delta
	)


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
