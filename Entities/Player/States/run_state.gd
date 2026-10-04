extends PlayerState

func setup() -> void:
	super()

func enter() -> void:
	pass
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	# Handle jump
	if Input.is_action_just_pressed("player_jump") and player.is_on_floor():
		Transitioned.emit(self, "JUMP")
		return
	
	# Handle falling
	if not player.is_on_floor():
		player.coyote_timer.start()
		Transitioned.emit(self, "AIR")
		return
	
	# Slide pressed
	if Input.is_action_just_pressed("player_slide"):
		if player.horizonal_velocity.length() > player.movement.slide_speed_requirement:
			Transitioned.emit(self, "SLIDE")
			return
	
	# Sprint released -> walk
	if Input.is_action_just_released("player_sprint"):
		Transitioned.emit(self, "WALK")
		return
	
	var direction := player.get_movement_direction()
	
	if direction:
		player.movement.accelerate(
			direction,
			player.movement.run_speed,
			delta
		)
	else:
		# No direction -> transition to idle
		Transitioned.emit(self, "IDLE")
		return
	
	player.move_and_slide()
