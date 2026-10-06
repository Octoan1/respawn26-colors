extends PlayerState

func setup() -> void:
	super()

func enter() -> void:
	if not player.wall_grab_timer.timeout.is_connected(_wall_grab_timeout):
		player.wall_grab_timer.timeout.connect(_wall_grab_timeout)
	player.wall_grab_timer.start()

func exit() -> void:
	player.movement.can_grab_wall = false

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	# Landed
	if player.curr_ability != player.Ability_Color.BLUE or !Input.is_action_pressed("ability_activate"):
		Transitioned.emit(self, "AIR")
		return
	
	if player.is_on_floor():
		Transitioned.emit(self, "LANDING")
		return
	
	if Input.is_action_pressed("player_forwards") and player.can_wall_run():
		Transitioned.emit(self, "WALL_RIDING"); return
	
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
	player.movement.apply_glide_gravity(delta)
	
	player.move_and_slide()


func _wall_grab_timeout() -> void:
	player.movement.can_grab_wall = true
