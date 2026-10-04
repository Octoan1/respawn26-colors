extends PlayerState

func setup() -> void:
	super()

func enter() -> void:
	if not player.wall_grab_timer.timeout.is_connected(_wall_grab_timeout):
		player.wall_grab_timer.timeout.connect(_wall_grab_timeout)
	player.wall_grab_timer.start()

func exit() -> void:
	player.movement.can_grab_wall = false
	pass

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	# Landed
	if player.is_on_floor():
		Transitioned.emit(self, "LANDING")
		return
	
	if player.is_on_wall() and player.movement.can_grab_wall:
		Transitioned.emit(self, "WALL_RIDING")
		return
	
	# Coyote-time jump
	if Input.is_action_just_pressed("player_jump") and not player.coyote_timer.is_stopped():
		player.coyote_timer.stop()
		Transitioned.emit(self, "JUMP")
		return
		
	# Jump-buffer start 
	if Input.is_action_just_pressed("player_jump"):
		player.jump_buffer_timer.start()
	
	# Air movement
	var direction := player.get_movement_direction()
	player.movement.accelerate_air(direction, delta)
	player.movement.apply_gravity(delta)
	
	player.move_and_slide()


func _wall_grab_timeout() -> void:
	player.movement.can_grab_wall = true
