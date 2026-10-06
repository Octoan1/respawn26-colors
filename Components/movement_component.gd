extends Node
class_name PlayerMovement

@export_category("Ground Movement")
@export var walk_speed: float = 5.0
@export var run_speed: float = 8.0
@export var crouch_speed: float = 3.0
@export var ground_acceleration: float = 6.0
@export var ground_friction: float = 6.0

@export_category("Slide")
@export var min_speed_for_slide: float = 6.5   # entry gate; run_speed is 8, so you must be running
@export var slide_entry_boost: float = 2.0     # small burst on entry, not a snap to max
@export var slide_speed: float = 14.0          # hard cap (downhill can approach this)
@export var slide_friction: float = 3.0        # m/s^2 lost on flat ground (lower = longer slide)
@export var slide_slope_gain: float = 1.5      # how strongly slopes add/remove speed
@export var slide_steer_deg: float = 35.0      # max turn rate in deg/sec
@export var slide_end_speed: float = 3.5       # slide ends below this
@export var slide_cooldown: float = 0.8        # seconds after a slide before you can slide again
@export var slide_floor_stick: float = 2.0     # keeps the capsule attached while sliding

var slide_direction: Vector3 = Vector3.FORWARD
var slide_current_speed: float = 0.0
var _slide_ended_at: float = -999.0

@export_category("Air Movement")
@export var air_acceleration: float = 800.0
@export var air_move_speed: float = 500.0
@export var air_cap: float = 0.85
@export var auto_bhop: bool = false

@export_category("Jump")
@export var jump_velocity: float = 4.5

@export_category("Wall Movement")
@export var stick_force: float = 2.0
@export var push_off_wall_force: float = 5.0
@export var wall_speed: float = 12.0
@export var wall_acceleration: float = 0.00000000000000000000000000000000005
@export var can_grab_wall: bool = false
@export var wall_min_entry_speed: float = 0.0
@export var wall_run_time: float = 2.5       # seconds before you lose the wall
@export var wall_slip_gravity: float = 14.0  # downward accel at the end of the run
@export var wall_friction: float = 1.0       # m/s² bled off ONLY above wall_speed
@export var wall_cooldown: float = 0.3       # re-attach delay after leaving a wall
@export var wall_probe_distance := 0.3

@export_category("Wall Camera")
@export var wall_camera_tilt_deg: float = 12.0
@export var wall_tilt_speed: float = 10.0
@export var wall_fov_boost: float = 8.0

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


func can_slide() -> bool:
	var off_cooldown := _now() - _slide_ended_at >= slide_cooldown
	return player.is_on_floor() and off_cooldown and get_horizontal_speed() >= min_speed_for_slide


func start_slide() -> void:
	var h := get_horizontal_velocity()
	slide_direction = Vector3(h.x, 0.0, h.y).normalized()
	slide_current_speed = minf(h.length() + slide_entry_boost, slide_speed)
	player.velocity.y = 0.0


func end_slide() -> void:
	_slide_ended_at = _now()


func update_slide(input_dir: Vector3, delta: float) -> void:
	var n := player.get_floor_normal()
	if n == Vector3.ZERO:
		n = Vector3.UP

	# Keep the momentum direction on the floor. Steering turns the existing
	# velocity instead of replacing it, so a slide cannot instantly reverse.
	var floor_direction := slide_direction.slide(n).normalized()
	if floor_direction == Vector3.ZERO:
		floor_direction = Vector3.FORWARD.slide(n).normalized()
	slide_direction = floor_direction

	if input_dir != Vector3.ZERO:
		var target_direction := input_dir.slide(n).normalized()
		if target_direction != Vector3.ZERO:
			var turn := slide_direction.signed_angle_to(target_direction, n)
			var max_turn := deg_to_rad(slide_steer_deg) * delta
			slide_direction = slide_direction.rotated(
				n,
				clampf(turn, -max_turn, max_turn)
			).normalized()

	# Gravity projected onto the floor carries weight downhill and removes
	# momentum uphill. Friction is always applied opposite the motion.
	var gravity_along_slide := player.get_gravity().slide(n).dot(slide_direction)
	slide_current_speed += gravity_along_slide * slide_slope_gain * delta
	slide_current_speed -= slide_friction * delta
	slide_current_speed = clampf(slide_current_speed, 0.0, slide_speed)

	# The tangent velocity follows the slope naturally; the small normal
	# component prevents physics seams from launching the player.
	player.velocity = slide_direction * slide_current_speed - n * slide_floor_stick


func sync_slide_speed() -> void:
	# Call after move_and_slide(): walls and obstacles can remove momentum.
	var floor_velocity := player.velocity.slide(player.get_floor_normal())
	var carried_speed := maxf(floor_velocity.dot(slide_direction), 0.0)
	slide_current_speed = minf(slide_current_speed, carried_speed)


func _now() -> float:
	return Time.get_ticks_msec() / 1000.0

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


func accelerate_wall(direction: Vector3, speed: float, delta: float) -> void:
	if direction == Vector3.ZERO:
		return

	var current_speed := player.velocity.dot(direction)
	var add_speed := speed - current_speed
	if add_speed <= 0.0:
		return  # already faster than wall_speed: keep the momentum

	var acceleration_speed := minf(wall_acceleration * delta * speed, add_speed)
	player.velocity += direction * acceleration_speed


func apply_wall_friction(delta: float) -> void:
	# Slowly bleeds excess speed back down to wall_speed
	var horizontal := get_horizontal_velocity()
	var speed := horizontal.length()
	if speed <= wall_speed:
		return
	horizontal *= move_toward(speed, wall_speed, wall_friction * delta) / speed
	player.velocity.x = horizontal.x
	player.velocity.z = horizontal.y


func apply_wall_stick(flat_normal: Vector3) -> void:
	# Remove velocity heading into the wall, then press lightly against it
	var into := player.velocity.dot(flat_normal)
	if into < 0.0:
		player.velocity -= flat_normal * into
	player.velocity -= flat_normal * stick_force


func apply_wall_gravity(run_progress: float, delta: float) -> void:
	# Damp any upward carry from the entry, then ramp gravity so you slip off gradually
	if player.velocity.y > 0.0:
		player.velocity.y = lerpf(player.velocity.y, 0.0, 1.0 - exp(-6.0 * delta))
	player.velocity.y -= wall_slip_gravity * run_progress * run_progress * delta
