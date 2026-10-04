extends PlayerState

const HEADBOB_MOVE_AMOUNT = 0.06
const HEADBOB_FREQUENCY = 2.4
var headbob_time := 0.0

func setup() -> void:
	super()

func enter() -> void:
	pass
	
func exit() -> void:
	pass
	
func update(delta: float) -> void:
	headbob_time += delta * player.velocity.length()
	%Camera3D.transform.origin = Vector3(
		cos(headbob_time * HEADBOB_FREQUENCY * 0.5) * HEADBOB_MOVE_AMOUNT,
		sin(headbob_time * HEADBOB_FREQUENCY) * HEADBOB_MOVE_AMOUNT,
		0
	)

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
		if player.movement.get_horizontal_velocity().length() >= player.movement.min_speed_for_slide:
			Transitioned.emit(self, "SLIDE")
			return
		else:
			Transitioned.emit(self, "CROUCH")
			return
	
	# Sprint released -> walk
	if Input.is_action_just_released("player_sprint"):
		Transitioned.emit(self, "WALK")
		return
	
	var direction := player.get_movement_direction()
	
	# no direction -> no input -> transition idle
	if direction == Vector3.ZERO:
		Transitioned.emit(self, "IDLE")
		return

	player.movement.apply_ground_friction(delta)

	player.movement.accelerate_ground(
		direction,
		player.movement.run_speed,
		delta
	)
	
	player.move_and_slide()
