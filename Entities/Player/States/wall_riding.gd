extends PlayerState

@export var look_into_wall_threshold := 0.3  # 0 = perpendicular to wall, 1 = straight into it
@export var wall_turn_speed := 8.0
@export var max_turn_per_frame := 0.12
var wall_run_dir := Vector3.ZERO

func setup() -> void:
	super()
	pass

func enter() -> void: 
	player.wall_normal = player.get_wall_normal()
	var normal := player.wall_normal
	normal.y = 0
	normal = normal.normalized()

	var along := normal.cross(Vector3.UP).normalized()

	# Pick the direction the player is actually travelling in when they hit the wall
	var horizontal_vel := Vector3(player.velocity.x, 0, player.velocity.z)
	if horizontal_vel.length() > 0.5:
		if along.dot(horizontal_vel) < 0:
			along = -along
	else:
		# Standing still on entry: fall back to where they're looking
		var forward := -player.global_transform.basis.z
		forward.y = 0
		if along.dot(forward) < 0:
			along = -along

	wall_run_dir = along
	
func exit() -> void: 
	pass
	
func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	_align_to_wall(delta)
	if player.is_on_floor():
		Transitioned.emit(self, "IDLE")
		return
	
	if player.get_wall_normal().dot(player.wall_normal) < 0.9:
		print("Wall Normal: ", player.wall_normal, ", Current Normal: ", player.get_wall_normal(), ", Dot Product: ", player.get_wall_normal().dot(player.wall_normal))
		Transitioned.emit(self, "PUSH_OFF_WALL")
		return
	else:
		player.wall_normal = player.get_wall_normal()
	
	if Input.is_action_just_pressed("player_jump"):
		player.coyote_timer.stop()
		Transitioned.emit(self,"WALL_JUMP")
		return
		
	
	if not player.is_on_wall():
		Transitioned.emit(self, "AIR")
		return
	
	var input_dir := Input.get_vector("player_left", "player_right", "player_forwards", "player_backwards")
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#player.movement.apply_ground_friction(delta)
	#
	#player.movement.accelerate_wall(
		#direction,
		#player.movement.wall_speed,
		#delta
	#)
	
	if direction:
		player.velocity.x = move_toward(player.velocity.x, direction.x * player.movement.wall_speed, player.movement.wall_acceleration * delta)
		player.velocity.z = move_toward(player.velocity.z, direction.z * player.movement.wall_speed, player.movement.wall_acceleration * delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.movement.wall_acceleration * delta)
		player.velocity.z = move_toward(player.velocity.z, 0, player.movement.wall_acceleration * delta)
	
	player.velocity += -player.wall_normal.normalized() * player.movement.stick_force
	player.velocity.y = 0
	
	player.move_and_slide()



func _align_to_wall(delta: float) -> void:
	var normal := player.wall_normal
	normal.y = 0
	normal = normal.normalized()

	var forward := -player.global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()

	# How much the player is looking into the wall (1 = head-on, 0 = parallel, <0 = away)
	var into_wall := forward.dot(-normal)
	if into_wall < look_into_wall_threshold:
		return  # looking along or away from the wall, leave the camera alone

	# Direction along the wall
	var along := normal.cross(Vector3.UP).normalized()

	# Choose which way along the wall: prefer the way the player is already moving,
	# otherwise the side they're already leaning toward
	if along.dot(forward) < 0:
		along = -along

	# Godot's forward is -Z, so convert the direction to a yaw angle
	var target_yaw := atan2(-along.x, -along.z)

	# Frame-rate independent smoothing, scaled so a sharper look into the wall turns faster
	var weight := 1.0 - exp(-wall_turn_speed * into_wall * delta)
	player.rotation.y = lerp_angle(player.rotation.y, target_yaw, weight)
