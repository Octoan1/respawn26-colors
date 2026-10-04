extends PlayerState

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

func setup() -> void:
	super()
	pass

func enter() -> void: 	
	var direction: Vector3 = player.get_movement_direction()

	# If there is no input, slide in the direction we're already moving
	if direction == Vector3.ZERO:
		direction = Vector3(
			player.velocity.x,
			0.0,
			player.velocity.z
		).normalized()

	player.movement.start_slide(direction)
	
func exit() -> void: 
	pass
	
func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	# player jumps
	if Input.is_action_just_pressed("player_jump") and player.is_on_floor():
		Transitioned.emit(self, "JUMP")
		player.animation_player.play_backwards("Crouch")
		return
	
	# player starts falling (could be pushed off edge)
	if not player.is_on_floor():
		player.coyote_timer.start()
		Transitioned.emit(self, "AIR")
		player.animation_player.play_backwards("Crouch")
		return
	
	if Input.is_action_just_released("player_crouch"):
		Transitioned.emit(self,"LANDING")
		player.animation_player.play_backwards("Crouch")
		return
	
	
	if player.movement.get_horizontal_velocity().length() < player.movement.min_speed_for_slide:
		var direction := player.get_movement_direction()

		if Input.is_action_pressed("player_crouch"):
			Transitioned.emit(self, "CROUCH")
			return
		
		if direction != Vector3.ZERO:
			Transitioned.emit(self, "WALK")
			player.animation_player.play_backwards("Crouch")
			return
		else:
			Transitioned.emit(self, "IDLE")
			player.animation_player.play_backwards("Crouch")
			return
	
	player.movement.apply_slide_friction(delta)
	player.move_and_slide()
