extends PlayerState
## Posible State Transitions
# IDLE -> JUMP
# IDLE -> WALK
# IDLE -> AIR

func setup() -> void:
	super()


func enter() -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(delta: float) -> void:
	# Jump
	if Input.is_action_just_pressed("player_jump") and player.is_on_floor():
		Transitioned.emit(self, "JUMP")
		return
	
	# Player left the ground
	if not player.is_on_floor():
		player.coyote_timer.start()
		Transitioned.emit(self, "AIR")
		return
	
	var direction := player.get_movement_direction()

	if direction != Vector3.ZERO:
		Transitioned.emit(self, "WALK")
		return

	player.movement.apply_ground_friction(delta)
	player.move_and_slide()
