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
	# player jumps
	if Input.is_action_just_pressed("player_jump") and player.is_on_floor():
		Transitioned.emit(self, "JUMP")
	
	# player starts falling (could be pushed off edge)
	if not player.is_on_floor():
		player.coyote_timer.start()
		Transitioned.emit(self, "AIR")
		return
	
	# movement input -> switch to walk
	var input_dir := Input.get_vector("player_left", "player_right", "player_forwards", "player_backwards")
	if input_dir: 
		Transitioned.emit(self,"WALK")
	
	# slow player to a standstill
	if player.velocity:
		player.velocity.x = move_toward(player.velocity.x, 0, player.acceleration * delta)
		player.velocity.z = move_toward(player.velocity.z, 0, player.acceleration * delta)
	
	player.move_and_slide()
