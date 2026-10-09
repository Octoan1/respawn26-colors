extends PlayerState

const CROUCH_UP = preload("uid://bn1y50ycc78gq")
const CROUCH_DOWN = preload("uid://0b1cdkt1jdg0")

const WALKSFX = [preload("uid://bxsou8ahwmaq8"), preload("uid://xid7qxgq58lu"), preload("uid://bs4wmv0aoreu0")]
var walk_sfx_timer = 0.0

func setup() -> void:
	super()
	pass

func enter() -> void: 
	AudioManager.play_sfx(CROUCH_DOWN, randf_range(1.0,1.2), .6)
	
func exit() -> void: 
	pass
	
func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	var direction := player.get_movement_direction()
	
	if player.get_real_velocity().x or player.get_real_velocity().x > 0.0:
		walk_sfx_timer -= delta
		if walk_sfx_timer <= 0.0:
			walk_sfx_timer = .38 - (.001 * player.velocity.x * player.velocity.z * player.velocity.y)
			AudioManager.play_sfx(WALKSFX[randi_range(0, 2)], randf_range(.6,1.0), .7)
			
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
		AudioManager.play_sfx(CROUCH_UP, randf_range(1.0,1.2), .6)
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
