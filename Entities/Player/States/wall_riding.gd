extends PlayerState

@export var look_into_wall_threshold := 0.3
@export var wall_turn_speed := 8.0
@export var max_turn_per_frame := 0.12

var wall_run_dir := Vector3.ZERO
var run_time := 0.0


func enter() -> void:
	var m := player.movement
	player.wall_normal = player.get_wall_normal()
	var normal := _flat(player.wall_normal)

	var along := normal.cross(Vector3.UP).normalized()
	var h := Vector3(player.velocity.x, 0, player.velocity.z)
	if h.length() > 0.5:
		if along.dot(h) < 0:
			along = -along
	else:
		if along.dot(_flat(-player.global_transform.basis.z)) < 0:
			along = -along
	wall_run_dir = along

	# Redirect all horizontal momentum along the wall, with a speed floor
	var speed := maxf(h.length(), m.wall_speed)
	player.velocity.x = wall_run_dir.x * speed
	player.velocity.z = wall_run_dir.z * speed
	player.velocity.y = clampf(player.velocity.y, -2.0, 3.0)
	run_time = 0.0

	# +1 = wall on the right. Camera leans away from the wall.
	var wall_side := -signf(normal.dot(player.global_transform.basis.x))
	player.camera_roll_target = deg_to_rad(m.wall_camera_tilt_deg) * wall_side
	player.camera_fov_boost = m.wall_fov_boost


func exit() -> void:
	player.camera_roll_target = 0.0
	player.camera_fov_boost = 0.0
	player.start_wall_cooldown()


func physics_update(delta: float) -> void:
	var m := player.movement
	_align_to_wall(delta)

	if player.is_on_floor():
		Transitioned.emit(self, "IDLE"); return

	if not player.is_on_wall():
		Transitioned.emit(self, "AIR"); return

	if player.get_wall_normal().dot(player.wall_normal) < 0.8:
		Transitioned.emit(self, "PUSH_OFF_WALL"); return
	player.wall_normal = player.get_wall_normal()

	if Input.is_action_just_pressed("player_jump"):
		player.coyote_timer.stop()
		Transitioned.emit(self, "WALL_JUMP"); return

	run_time += delta
	var input_dir := Input.get_vector("player_left", "player_right", "player_forwards", "player_backwards")

	if input_dir.y > 0.5 or run_time >= m.wall_run_time or m.get_horizontal_speed() < m.wall_min_entry_speed:
		Transitioned.emit(self, "AIR"); return

	# Movement is along the wall, independent of where the camera points
	if input_dir.y < -0.1:
		m.accelerate_wall(wall_run_dir, m.wall_speed, delta)
	m.apply_wall_friction(delta)
	m.apply_wall_stick(_flat(player.wall_normal))
	m.apply_wall_gravity(run_time / m.wall_run_time, delta)

	player.move_and_slide()


func _align_to_wall(delta: float) -> void:
	var normal := _flat(player.wall_normal)
	var along := normal.cross(Vector3.UP).normalized()
	if along.dot(wall_run_dir) < 0:
		along = -along
	wall_run_dir = along

	var forward := _flat(-player.global_transform.basis.z)
	var into_wall := forward.dot(-normal)
	if into_wall < look_into_wall_threshold or forward.dot(wall_run_dir) <= 0:
		return

	var target_yaw := atan2(-wall_run_dir.x, -wall_run_dir.z)
	var diff := angle_difference(player.rotation.y, target_yaw)
	var weight := 1.0 - exp(-wall_turn_speed * into_wall * delta)
	player.rotation.y += clampf(diff * weight, -max_turn_per_frame, max_turn_per_frame)


func _flat(v: Vector3) -> Vector3:
	v.y = 0
	return v.normalized()
