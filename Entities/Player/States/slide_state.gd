extends PlayerState

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

var _cancelled := false


func setup() -> void:
	super()


var _air_time := 0.0

func enter() -> void:
	_air_time = 0.0
	player.movement.start_slide()

func exit() -> void:
	player.movement.end_slide()

func physics_update(delta: float) -> void:
	# ... jump check stays first ...

	if player.is_on_floor():
		_air_time = 0.0
	else:
		_air_time += delta

	if _air_time > 0.1:
		player.coyote_timer.start()
		Transitioned.emit(self, "AIR")
		player.animation_player.play_backwards("Crouch")
		return

	if Input.is_action_just_released("player_crouch"):
		Transitioned.emit(self, "LANDING")
		player.animation_player.play_backwards("Crouch")
		return

	player.movement.update_slide(player.get_movement_direction(), delta)
	player.move_and_slide()

	# Stay in the slide while crouch is held, even after losing speed. This
	# lets a downhill section restart the slide instead of bouncing through
	# CROUCH and repeatedly re-entering SLIDE.
