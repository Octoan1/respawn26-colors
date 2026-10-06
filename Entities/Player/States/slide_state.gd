extends PlayerState

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var camera_3d: Camera3D = %Camera3D

var _cancelled := false


func setup() -> void:
	super()


var _air_time := 0.0

func enter() -> void:
	_air_time = 0.0
	camera_3d.enable_dyamic_fov = true
	camera_3d.fov += 5
	player.movement.start_slide()

func exit() -> void:
	player.movement.end_slide()

func physics_update(delta: float) -> void:
	camera_3d.enable_dyamic_fov = false
	camera_3d.fov = camera_3d.base_fov
	
	if Input.is_action_just_pressed("player_jump") and player.is_on_floor():
		Transitioned.emit(self, "JUMP")
		player.set_crouch_animation(false)
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

	player.movement.update_slide(player.get_movement_direction(), delta)
	player.move_and_slide()

	# Stay in the slide while crouch is held, even after losing speed. This
	# lets a downhill section restart the slide instead of bouncing through
	# CROUCH and repeatedly re-entering SLIDE.
