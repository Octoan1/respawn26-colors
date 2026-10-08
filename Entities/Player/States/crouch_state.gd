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
	var direction := player.get_movement_direction()
	
	if player.movement.can_slide():
		Transitioned.emit(self, "SLIDE")
		return
	
	if player.curr_ability == player.Ability_Color.GREEN and Input.is_action_just_pressed("ability_activate") and player.ability_charges_g > 0:
		player.ability_charges_g -= 1
		Transitioned.emit(self, "DASH")
		return
	
	if player.curr_ability == player.Ability_Color.RED and Input.is_action_just_pressed("ability_activate") and player.ability_charges_r > 0:
		player.ability_charges_r -= 1
		Transitioned.emit(self, "ROCKET_JUMP")
		return
	
	if not Input.is_action_pressed("player_crouch") and player.can_stand():
		Transitioned.emit(self, "IDLE")
		player.set_crouch_animation(false)
		return
		
	if not player.is_on_floor():
		player.coyote_timer.start()
		Transitioned.emit(self, "AIR")
		return

	player.movement.apply_ground_friction(delta)

	player.movement.accelerate_ground(
		direction,
		player.movement.crouch_speed,
		delta
	)
	
	player.move_and_slide()
