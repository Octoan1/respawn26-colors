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

func physics_update(_delta: float) -> void:
	if not player.jump_buffer_timer.is_stopped() or (Input.is_action_pressed("player_jump") and player.movement.auto_bhop):
		Transitioned.emit(self, "JUMP")
	
	# slide pressed
	if Input.is_action_pressed("player_crouch"):
		Transitioned.emit(self,"SLIDE")
		player.animation_player.play("Crouch")
	
	var input_dir := Input.get_vector("player_left", "player_right", "player_forwards", "player_backwards")
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if Input.is_action_pressed("player_sprint"):
			Transitioned.emit(self,"RUN")
		else:
			Transitioned.emit(self,"WALK")
	else:
		Transitioned.emit(self,"IDLE")
		
