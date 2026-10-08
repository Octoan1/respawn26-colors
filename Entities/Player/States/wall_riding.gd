extends PlayerState

@export var look_into_wall_threshold := 0.3
@export var wall_turn_speed := 8.0
@export var max_turn_per_frame := 0.12
@export var look_away_threshold := 0.3      # forward.dot(normal): above this = looking away from the wall
@export var hold_into_wall_threshold := 0.3 # input.dot(-normal): above this = pushing into the wall
@export var detach_grace := 0.2            # seconds you can look away before dropping

var detach_timer := 0.0

var wall_run_dir := Vector3.ZERO
var run_time := 0.0
var contact_lost_time := 0.0


func enter() -> void:
	player.ability_charges_r = 1
	player.ability_charges_g = 1
	player.ability_charges_b = 1
	var m := player.movement
	var n := player.find_wall_normal()
	player.wall_normal = n if n != Vector3.ZERO else player.get_wall_normal()
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

	# Keep only momentum that was already moving along the wall. Do not turn
	# momentum directed into the wall into forward wall-run speed.
	var along_speed := h.dot(wall_run_dir)
	along_speed = maxf(along_speed, -m.wall_backward_speed)
	player.velocity.x = wall_run_dir.x * along_speed
	player.velocity.z = wall_run_dir.z * along_speed
	player.velocity.y = clampf(player.velocity.y, -2.0, 3.0)
	run_time = 0.0

	# +1 = wall on the right. Camera leans away from the wall.
	var wall_side := -signf(normal.dot(player.global_transform.basis.x))
	player.camera_roll_target = deg_to_rad(m.wall_camera_tilt_deg) * wall_side
	player.camera_fov_boost = m.wall_fov_boost
	
	detach_timer = 0.0
	contact_lost_time = 0.0


func exit() -> void:
	player.camera_roll_target = 0.0
	player.camera_fov_boost = 0.0
	player.start_wall_cooldown()


func physics_update(delta: float) -> void:
	var m := player.movement
	_align_to_wall(delta)

	if player.is_on_floor():
		Transitioned.emit(self, "IDLE"); return
	if not player.has_wall_run_clearance(player.wall_normal):
		Transitioned.emit(self, "PUSH_OFF_WALL"); return

	if player.is_on_wall():
		contact_lost_time = 0.0
		if player.get_wall_normal().dot(player.wall_normal) < 0.8:
			Transitioned.emit(self, "PUSH_OFF_WALL"); return
		player.wall_normal = player.find_wall_normal()
	else:
		contact_lost_time += delta
		if contact_lost_time > 0.5:
			Transitioned.emit(self, "AIR"); return

	if Input.is_action_just_pressed("player_jump"):
		player.coyote_timer.stop()
		Transitioned.emit(self, "WALL_JUMP"); return
	
	if player.curr_ability == player.Ability_Color.GREEN and Input.is_action_just_pressed("ability_activate") and player.ability_charges_g > 0:
		player.ability_charges_g -= 1
		Transitioned.emit(self, "DASH")
		return
	
	if player.curr_ability == player.Ability_Color.RED and Input.is_action_just_pressed("ability_activate") and player.ability_charges_r > 0:
		player.ability_charges_r -= 1
		Transitioned.emit(self, "ROCKET_JUMP")
		return

	run_time += delta
	var input_world := player.get_movement_direction()

	if _should_detach(delta) or run_time >= m.wall_run_time or m.get_horizontal_speed() < m.wall_min_entry_speed:
		Transitioned.emit(self, "PUSH_OFF_WALL"); return

	# Use the input's projection onto the wall tangent. This prevents camera
	# forward/backward from incorrectly forcing movement along the wall.
	var target_wall_speed := 0.0
	var wall_input := input_world.dot(wall_run_dir)
	if wall_input > 0.1:
		target_wall_speed = m.wall_speed
	elif wall_input < -0.1:
		target_wall_speed = -m.wall_backward_speed

	var current_wall_speed := player.velocity.dot(wall_run_dir)
	var wall_speed_step := m.wall_acceleration * m.wall_speed * delta
	var next_wall_speed := move_toward(
		current_wall_speed,
		target_wall_speed,
		wall_speed_step
	)
	if target_wall_speed < 0.0:
		next_wall_speed = maxf(next_wall_speed, -m.wall_backward_speed)
	player.velocity += wall_run_dir * (next_wall_speed - current_wall_speed)
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

func _should_detach(delta: float) -> bool:
	var normal := _flat(player.wall_normal)
	var forward := _flat(-player.global_transform.basis.z)

	var looking_away := forward.dot(normal) > look_away_threshold
	
	var holding_into_wall := player.get_movement_direction().dot(-normal) > hold_into_wall_threshold

	if looking_away and not holding_into_wall:
		detach_timer += delta
	else:
		detach_timer = 0.0

	return detach_timer >= detach_grace
