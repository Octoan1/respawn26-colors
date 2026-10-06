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
	# JUMP state transition
	if Input.is_action_just_pressed("player_jump") and player.is_on_floor():
		Transitioned.emit(self, "JUMP")
		return
	
	# AIR state transition
	if not player.is_on_floor():
		player.coyote_timer.start()
		Transitioned.emit(self, "AIR")
		return
	
	# RUN state transition
	if Input.is_action_pressed("player_sprint"):
		Transitioned.emit(self, "RUN")
		return
		
	# CROUCH state transition
	if Input.is_action_just_pressed("player_crouch"):
		Transitioned.emit(self, "CROUCH")
		player.set_crouch_animation(true)
		return
	
	var direction := player.get_movement_direction()

	if direction == Vector3.ZERO:
		Transitioned.emit(self, "IDLE")
		return

	player.movement.apply_ground_friction(delta)

	player.movement.accelerate_ground(
		direction,
		player.movement.run_speed if player.movement.sprint_momentum_active() else player.movement.walk_speed,
		delta
	)
		
	player.move_and_slide()
