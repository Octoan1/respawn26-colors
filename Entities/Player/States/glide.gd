extends PlayerState

var x: float


func setup() -> void:
	super()

func enter() -> void:
	player.velocity.y = player.velocity.y * 0.2
	if not player.wall_grab_timer.timeout.is_connected(_wall_grab_timeout):
		player.wall_grab_timer.timeout.connect(_wall_grab_timeout)
	player.wall_grab_timer.start()
	#player.velocity = _flat(player.velocity)
	player.glide_timer.start()
	player.sprite.play("Blue Transition")
	await player.sprite.animation_finished
	player.sprite.play_backwards("Blue Float")

func exit() -> void:
	player.movement.can_grab_wall = false
	player.sprite.play_backwards("Blue Transition")
	await player.sprite.animation_finished
	player.sprite.play("Blue Idle")

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
	
	if not player.glide_timer.is_stopped():
		player.movement.apply_glide_gravity(delta, 0.3)
		print(0.1)
	else:
		x += delta
		var modifier := 0.3 + 0.5 * log(1.0 + x)
		player.movement.apply_glide_gravity(delta, modifier)
		print(modifier)
	player.move_and_slide()


func _wall_grab_timeout() -> void:
	player.movement.can_grab_wall = true

func _flat(v: Vector3) -> Vector3:
	v.y = 0
	return v
