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
	
	# Movement input -> switch to walk
	var input_dir := Input.get_vector(
		"player_left",
		"player_right",
		"player_forwards",
		"player_backwards"
	)
	
	if input_dir:
		Transitioned.emit(self, "WALK")
		return
	
	# Slow player to a stop
	player.movement.decelerate(delta)
	
	player.move_and_slide()
