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
	# slide pressed
	if Input.is_action_pressed("player_slide"):
		if player.horizonal_velocity.length() > player.slide_spd_req:
			Transitioned.emit(self,"SLIDE")
	
	var input_dir := Input.get_vector("player_left", "player_right", "player_forwards", "player_backwards")
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if Input.is_action_pressed("player_sprint"):
			Transitioned.emit(self,"RUN")
		else:
			Transitioned.emit(self,"WALK")
	else:
		Transitioned.emit(self,"IDLE")
		
