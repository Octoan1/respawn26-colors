extends PlayerState

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var camera_3d: Camera3D = %Camera3D

const SLIDE_INITIAL = preload("uid://bjv2tpgfxic3d")
const SLIDESFX = preload("uid://b26uh7audsn6e")
var slide_sfx_timer = 0.0
var slide_sfx_player = AudioManager.create_sfx_adv(SLIDESFX, 1.0, 1.2)


func setup() -> void:
	super()

var _air_time := 0.0

func enter() -> void:
	_air_time = 0.0
	camera_3d.trigger_slide_lurch()
	player.movement.start_slide()
	
	AudioManager.play_sfx(SLIDE_INITIAL,randf_range(.1, .3), .3)

func exit() -> void:
	player.movement.end_slide()
	slide_sfx_player.stop()
	slide_sfx_timer = 0.0
	#print("SFX STOP")
	
func update(delta: float) -> void:
	slide_sfx_timer -= delta
	
	if slide_sfx_timer <= 0.0:
		slide_sfx_timer = 5.22
		slide_sfx_player.pitch_scale = randf_range(.6,1.0)
		slide_sfx_player.play()
		#print("SFX PLAY")

func physics_update(delta: float) -> void:
	if Input.is_action_just_pressed("player_jump") and player.is_on_floor():
		Transitioned.emit(self, "JUMP")
		player.set_crouch_animation(false)
		return
	
	if player.curr_ability == player.Ability_Color.GREEN and Input.is_action_just_pressed("ability_activate") and player.ability_charges_g > 0:
		player.ability_charges_g -= 1
		Transitioned.emit(self, "DASH")
		return
	
	if player.curr_ability == player.Ability_Color.RED and Input.is_action_just_pressed("ability_activate") and player.ability_charges_r > 0:
		player.ability_charges_r -= 1
		Transitioned.emit(self, "ROCKET_JUMP")
		return

	if player.is_on_floor():
		_air_time = 0.0
	else:
		_air_time += delta

	if _air_time > 0.1:
		player.coyote_timer.start()
		Transitioned.emit(self, "AIR")
		player.set_crouch_animation(false)
		return

	if Input.is_action_just_released("player_crouch"):
		Transitioned.emit(self, "LANDING")
		player.set_crouch_animation(false)
		return
		
	if player.movement.get_horizontal_speed() < player.movement.slide_end_speed:
		Transitioned.emit(self, "CROUCH")
		return

	player.movement.update_slide(player.get_movement_direction(), delta)
	player.move_and_slide()

	# Stay in the slide while crouch is held, even after losing speed. This
	# lets a downhill section restart the slide instead of bouncing through
	# CROUCH and repeatedly re-entering SLIDE.
