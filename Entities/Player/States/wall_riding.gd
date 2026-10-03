extends PlayerState

var wall_normal: Vector3

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
		player.velocity += player.get_gravity() * 0.2 * delta
		pass
	else:
		Transitioned.emit(self, "IDLE")
		return
	
	if Input.is_action_just_pressed("player_jump"):
		player.coyote_timer.stop()
		Transitioned.emit(self,"WALL_JUMP")
		return
		
	if player.is_on_wall():
		wall_normal = player.get_wall_normal()	
	else:
		Transitioned.emit(self, "AIR")
		return
	
	
	var input_dir := Input.get_vector("player_left", "player_right", "player_forwards", "player_backwards")
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		player.velocity.x = move_toward(player.velocity.x, direction.x * player.walk_speed, player.acceleration * delta)
		player.velocity.z = move_toward(player.velocity.z, direction.z * player.walk_speed, player.acceleration * delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.acceleration * delta)
		player.velocity.z = move_toward(player.velocity.z, 0, player.acceleration * delta)
	
	player.velocity += -wall_normal * player.stick_force
	
	player.move_and_slide()
