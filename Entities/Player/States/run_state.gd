extends PlayerState

@onready var animated_sprite_2d: AnimatedSprite2D = $"../../Debug/AnimatedSprite2D"
var origin: Vector2

const HEADBOB_MOVE_AMOUNT = 0.06
const HEADBOB_FREQUENCY = 2.4
var headbob_time := 0.0

const RUNSFX = [preload("uid://bxsou8ahwmaq8"), preload("uid://xid7qxgq58lu"), preload("uid://bs4wmv0aoreu0")]
var run_sfx_timer = 0.0

func setup() -> void:
	origin = animated_sprite_2d.transform.origin + Vector2(0,20)
	super()

func enter() -> void:
	if player.toggle_sprint_on:
		player.is_sprinting = true
	
func exit() -> void:
	pass
	
func update(delta: float) -> void:
	headbob_time += delta * player.velocity.length()
	
	run_sfx_timer -= delta
	
	if run_sfx_timer <= 0.0:
		run_sfx_timer = .23
		AudioManager.play_sfx(RUNSFX[randi_range(0, 2)], randf_range(.6,1.0))
	
	if false:
		%Camera3D.transform.origin = Vector3(
			cos(headbob_time * HEADBOB_FREQUENCY * 0.5) * HEADBOB_MOVE_AMOUNT,
			sin(headbob_time * HEADBOB_FREQUENCY) * HEADBOB_MOVE_AMOUNT,
			0
		)
	animated_sprite_2d.global_position = origin - Vector2(0, 10 * sin(headbob_time * HEADBOB_FREQUENCY))

func physics_update(delta: float) -> void:
	# Handle jump
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
	
	# Handle falling
	if not player.is_on_floor():
		player.coyote_timer.start()
		Transitioned.emit(self, "AIR")
		return

	var input_dir := Input.get_vector("player_left", "player_right", "player_forwards", "player_backwards")
	if input_dir.y >= 0.0:
		if player.toggle_sprint_on:
			player.is_sprinting = false
		Transitioned.emit(self, "WALK")
		return
	
	# Slide pressed
	if Input.is_action_just_pressed("player_crouch"):
		Transitioned.emit(self, "CROUCH")
		player.set_crouch_animation(true)

	if not player.toggle_sprint_on:
		# Sprint released -> walk
		if Input.is_action_just_released("player_sprint"):
			player.movement.remember_sprint_release()
			Transitioned.emit(self, "WALK")
			return
	
	var direction := player.get_movement_direction()
	
	# no direction -> no input -> transition idle
	if direction == Vector3.ZERO:
		if player.toggle_sprint_on:
			player.is_sprinting = false
		Transitioned.emit(self, "IDLE")
		return

	player.movement.apply_ground_friction(delta)

	player.movement.accelerate_ground(
		direction,
		player.movement.run_speed,
		delta
	)
	
	player.move_and_slide()

func _flat(v: Vector3) -> Vector3:
	v.y = 0.0
	return v
