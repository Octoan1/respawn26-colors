extends PlayerState

const WALKSFX = [preload("uid://bxsou8ahwmaq8"), preload("uid://xid7qxgq58lu"), preload("uid://bs4wmv0aoreu0")]
var walk_sfx_timer = 0.0

func setup() -> void:
	super()
	pass

func enter() -> void: 
	pass
	
func exit() -> void: 
	pass
	
func update(_delta: float) -> void:
	walk_sfx_timer -= _delta
	
	if walk_sfx_timer <= 0.0:
		walk_sfx_timer = .325 - (.001 * player.velocity.x * player.velocity.z * player.velocity.y)
		AudioManager.play_sfx(WALKSFX[randi_range(0, 2)], randf_range(.6,1.0))

func physics_update(delta: float) -> void:
	# JUMP state transition
	if Input.is_action_just_pressed("player_jump") and player.is_on_floor():
		Transitioned.emit(self, "JUMP")
		return
	
	if player.curr_ability == player.Ability_Color.GREEN and Input.is_action_just_pressed("ability_activate") and player.ability_charges_g > 0:
		player.ability_charges_g -= 1
		Transitioned.emit(self, "DASH")
		return
	
	if player.curr_ability == player.Ability_Color.RED and Input.is_action_just_pressed("ability_activate") and player.ability_charges_r > 0:
		player.ability_charges_r -= 1
		Transitioned.emit(self, "ROCKET_JUMP")
		return
	
	# AIR state transition
	if not player.is_on_floor():
		player.coyote_timer.start()
		Transitioned.emit(self, "AIR")
		return
	
	# RUN state transition
	var input_dir := Input.get_vector("player_left", "player_right", "player_forwards", "player_backwards")
	if Input.is_action_pressed("player_sprint") and input_dir.y < 0.0:
		Transitioned.emit(self, "RUN")
		return
		
	# CROUCH state transition
	if Input.is_action_just_pressed("player_crouch"):
		Transitioned.emit(self, "CROUCH")
		player.set_crouch_animation(true)
		return
	
	var direction := player.get_movement_direction()

	if direction == Vector3.ZERO:
		Transitioned.emit(self, "IDLE")
		return

	player.movement.apply_ground_friction(delta)

	player.movement.accelerate_ground(
		direction,
		player.movement.run_speed if player.movement.sprint_momentum_active() else player.movement.walk_speed,
		delta
	)
		
	player.move_and_slide()
