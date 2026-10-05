extends PlayerState


func setup() -> void:
	super()
	pass

func enter() -> void: 
	if player.movement.get_horizontal_velocity().length() >= player.movement.min_speed_for_slide:
		Transitioned.emit(self, "SLIDE")
	
func exit() -> void: 
	pass
	
func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	var direction := player.get_movement_direction()
	
	if Input.is_action_just_released("player_crouch"):
		Transitioned.emit(self, "IDLE")
		player.animation_player.play_backwards("Crouch")
		return

	player.movement.apply_ground_friction(delta)

	player.movement.accelerate_ground(
		direction,
		player.movement.crouch_speed,
		delta
	)
	
	player.move_and_slide()
