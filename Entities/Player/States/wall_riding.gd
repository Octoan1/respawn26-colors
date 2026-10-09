extends PlayerState

@export var look_into_wall_threshold := 0.3
@export var wall_turn_speed := 4.0
@export var max_turn_per_frame := 0.12
@export var look_away_threshold := 0.3
@export var hold_into_wall_threshold := 1.0 #for checking if should detach
@export var detach_grace := 0.2
@export var backward_time_scale := 2.5
@export var backward_scale_smoothing := 10.0
@export var run_threshold_speed := 2.0   # speed along the wall that counts as "running" (boost + camera steering)
@export var push_away_threshold := 0.5   # input.dot(normal) above this = pushing away from the wall
@export var push_away_grace := 0.08      # seconds you must hold it, so a tap doesn't drop you

var push_away_timer := 0.0

var run_boosted: bool = false

var time_scale := 1.0
var detach_timer := 0.0
var wall_side := 0.0

var wall_run_dir := Vector3.ZERO
var run_time := 0.0
var contact_lost_time := 0.0

const RUNSFX = [preload("uid://bxsou8ahwmaq8"), preload("uid://xid7qxgq58lu"), preload("uid://bs4wmv0aoreu0")]
var run_sfx_timer: float = 0.0


func enter() -> void:
	push_away_timer = 0.0
	player.ability_charges_r = 1
	player.ability_charges_g = 1
	player.ability_charges_b = 1
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

	# Only remove the part of the velocity heading into the wall. Vertical
	# momentum is kept, so the rise finishes naturally, and any momentum
	# along the wall is kept too.
	var into := player.velocity.dot(normal)
	if into < 0.0:
		player.velocity -= normal * into

	run_time = 0.0
	wall_side = -signf(normal.dot(player.global_transform.basis.x))  # +1 = wall on the right

	# Camera effects are driven per frame, only while running
	player.camera_roll_target = 0.0
	player.camera_fov_boost = 0.0

	detach_timer = 0.0
	contact_lost_time = 0.0
	time_scale = 1.0
	
	if player.velocity.y < 0.0:
		player.velocity.y = 0.0


func exit() -> void:
	player.camera_roll_target = 0.0
	player.camera_fov_boost = 0.0
	player.start_wall_cooldown()
	player.wall_coyote_timer.start()
	run_boosted = false
	


func update(delta: float) -> void:
	if player.velocity.dot(wall_run_dir) < run_threshold_speed:
		return   # no footsteps while just clinging
	run_sfx_timer -= delta
	if run_sfx_timer <= 0.0:
		run_sfx_timer = .22 - (.001 * player.velocity.x * player.velocity.z * player.velocity.y)
		AudioManager.play_sfx(RUNSFX[randi_range(0, 2)], randf_range(.9,1.1))


func physics_update(delta: float) -> void:
	var m := player.movement
	_update_run_direction()
	_align_to_wall(delta)

	if player.is_on_floor():
		Transitioned.emit(self, "IDLE"); return
	if not player.has_wall_run_clearance(player.wall_normal):
		Transitioned.emit(self, "PUSH_OFF_WALL"); return

	if Input.is_action_just_pressed("player_crouch"):
		player.velocity += player.wall_normal * 2
		Transitioned.emit(self, "AIR")
		return

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
	
	if _is_pushing_away(delta):
		player.velocity += _flat(player.wall_normal) * 2.0   # small nudge off the wall
		Transitioned.emit(self, "AIR")
		return

	# Moving backwards relative to where you're facing: burn the wall time faster
	var h := Vector3(player.velocity.x, 0.0, player.velocity.z)
	var target_scale := 1.0
	if h.length() > 0.5:
		var forward := _flat(-player.global_transform.basis.z)
		var backwards := clampf(-h.normalized().dot(forward), 0.0, 1.0)
		target_scale = lerpf(1.0, backward_time_scale, backwards)
	time_scale = lerpf(time_scale, target_scale, 1.0 - exp(-backward_scale_smoothing * delta))

	# The timer doesn't run while you're still rising
	if player.velocity.y <= 0.0:
		run_time += delta * time_scale

	if _should_detach(delta) or run_time >= m.wall_run_time:
		Transitioned.emit(self, "PUSH_OFF_WALL"); return

	# Speed along the wall follows the input's projection onto the wall direction.
	# No input = slow down, so you cling instead of drifting.
	var input_world := player.get_movement_direction()
	var wall_input := input_world.dot(wall_run_dir)
	var current_wall_speed := player.velocity.dot(wall_run_dir)
	var wall_speed_step := m.wall_acceleration * m.wall_speed * delta

	if _is_forward_along_wall(wall_run_dir):
		# Normal behaviour: run with input, cling to a stop without it
		var target_wall_speed := m.wall_speed if wall_input > 0.1 else 0.0
		var next_wall_speed := move_toward(current_wall_speed, target_wall_speed, wall_speed_step)
		player.velocity += wall_run_dir * (next_wall_speed - current_wall_speed)
	elif wall_input < -0.1:
		# Moving backwards but pressing the forward way: brake so you can turn around.
		# _update_run_direction() flips the direction once you're nearly stopped.
		var next_wall_speed := move_toward(current_wall_speed, 0.0, wall_speed_step)
		player.velocity += wall_run_dir * (next_wall_speed - current_wall_speed)
	# Otherwise: backward momentum is kept as is, with no boost and no input-driven acceleration

	# Camera tilt + FOV only while actually running along the wall
	var running := player.velocity.dot(wall_run_dir) > run_threshold_speed and _is_forward_along_wall(wall_run_dir)
	if running and not run_boosted:
		run_boosted = true
		player.velocity.y = maxf(player.velocity.y, m.wall_run_boost)
	player.camera_roll_target = deg_to_rad(m.wall_camera_tilt_deg) * wall_side if running else 0.0
	player.camera_roll_target = deg_to_rad(m.wall_camera_tilt_deg) * wall_side if running else 0.0
	player.camera_fov_boost = m.wall_fov_boost if running else 0.0

	var moving_factor := clampf(absf(player.velocity.dot(wall_run_dir)) / m.wall_speed, 0.0, 1.0)

	m.apply_wall_friction(delta)
	m.apply_wall_stick(_flat(player.wall_normal))
	m.apply_wall_slide(run_time / m.wall_run_time, delta, moving_factor)

	player.move_and_slide()


func _update_run_direction() -> void:
	var normal := _flat(player.wall_normal)
	var tangent := normal.cross(Vector3.UP).normalized()
	var wall_input := player.get_movement_direction().dot(tangent)
	if absf(wall_input) <= 0.1 or absf(player.velocity.dot(tangent)) >= 1.0:
		return
	var dir := tangent * signf(wall_input)
	if _is_forward_along_wall(dir):
		wall_run_dir = dir


func _align_to_wall(delta: float) -> void:
	var normal := _flat(player.wall_normal)
	var along := normal.cross(Vector3.UP).normalized()
	if along.dot(wall_run_dir) < 0:
		along = -along
	wall_run_dir = along

	# Only steer the camera once you're moving along the wall
	if player.velocity.dot(wall_run_dir) < run_threshold_speed:
		return

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

func _is_forward_along_wall(dir: Vector3) -> bool:
	# True if `dir` points the same way you're facing (or you're facing straight into the wall)
	var facing := _flat(-player.global_transform.basis.z)
	return facing.dot(dir) > -0.2

func _is_pushing_away(delta: float) -> bool:
	var normal := _flat(player.wall_normal)
	var input_world := player.get_movement_direction()

	if input_world.dot(normal) > push_away_threshold:
		push_away_timer += delta
	else:
		push_away_timer = 0.0

	return push_away_timer >= push_away_grace
