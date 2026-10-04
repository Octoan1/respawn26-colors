extends PlayerState

func setup() -> void:
	super()
	pass

func enter() -> void: 
	player.wall_normal = player.get_wall_normal()	
	
func exit() -> void: 
	pass
	
func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	if player.is_on_floor():
		Transitioned.emit(self, "IDLE")
		return
	
	if player.get_wall_normal().dot(player.wall_normal) < 0.9:
		Transitioned.emit(self, "PUSH_OFF_WALL")
		return
	else:
		player.wall_normal = player.get_wall_normal()
	
	if Input.is_action_just_pressed("player_jump"):
		player.coyote_timer.stop()
		Transitioned.emit(self,"WALL_JUMP")
		return
	
	if Input.is_action_just_pressed("wall button"):
		Transitioned.emit(self, "PUSH_OFF_WALL")
		return
		
	
	if not player.is_on_wall():
		Transitioned.emit(self, "AIR")
		return
	
	var input_dir := Input.get_vector("player_left", "player_right", "player_forwards", "player_backwards")
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		player.velocity.x = move_toward(player.velocity.x, direction.x * player.movement.walk_speed, player.movement.ground_acceleration * delta)
		player.velocity.z = move_toward(player.velocity.z, direction.z * player.movement.walk_speed, player.movement.ground_acceleration * delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.acceleration * delta)
		player.velocity.z = move_toward(player.velocity.z, 0, player.acceleration * delta)
	
	player.velocity += -player.wall_normal.normalized() * player.movement.stick_force
	player.velocity.y = 0
	
	player.move_and_slide()
