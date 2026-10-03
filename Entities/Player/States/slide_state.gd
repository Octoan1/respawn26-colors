extends PlayerState

func setup() -> void:
	super()
	pass

func enter() -> void: 
	# shrink head
	%Head.position.y -= 0.25
	player.velocity *= Vector3(1.5,0,1.5)
	
func exit() -> void: 
	# restore head
	%Head.position.y += 0.25
	pass
	
func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	if player.velocity:
		player.velocity.x = move_toward(player.velocity.x, 0, 0.25* player.acceleration * delta)
		player.velocity.z = move_toward(player.velocity.z, 0, 0.25*player.acceleration * delta)
	
	
	if player.horizonal_velocity.length() < 3:
		Transitioned.emit(self,"IDLE")
	
	player.move_and_slide()
