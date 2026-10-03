extends PlayerState

func setup() -> void:
	super()
	pass

func enter() -> void: 
	pass
	
func exit() -> void: 
	pass
	
func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
	else:
		Transitioned.emit(self, "IDLE")
		return
		
	if Input.is_action_just_pressed("player_jump") and not player.coyote_timer.is_stopped():
		player.coyote_timer.stop()
		Transitioned.emit(self,"JUMP")
		return
	
	if player.is_on_wall():
		Transitioned.emit(self, "WALL_RIDING")
		return
	
	var input_dir := Input.get_vector("player_left", "player_right", "player_forwards", "player_backwards")
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		# Keep existing momentum and slightly influence it with input
		player.velocity.x += direction.x * player.air_acceleration * delta
		player.velocity.z += direction.z * player.air_acceleration * delta

		# Limit horizontal speed
		var horizontal_velocity := Vector2(player.velocity.x, player.velocity.z)

		if horizontal_velocity.length() > player.run_speed:
			horizontal_velocity = horizontal_velocity.normalized() * player.walk_speed
			player.velocity.x = horizontal_velocity.x
			player.velocity.z = horizontal_velocity.y
	
	player.move_and_slide()
