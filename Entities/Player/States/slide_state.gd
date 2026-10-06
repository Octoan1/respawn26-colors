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

	if player.movement.slide_current_speed < player.movement.slide_end_speed:
		if Input.is_action_pressed("player_crouch"):
			Transitioned.emit(self, "CROUCH")
		elif player.get_movement_direction() != Vector3.ZERO:
			Transitioned.emit(self, "WALK")
			player.animation_player.play_backwards("Crouch")
		else:
			Transitioned.emit(self, "IDLE")
			player.animation_player.play_backwards("Crouch")
		return

	player.movement.update_slide(player.get_movement_direction(), delta)
	player.move_and_slide()
	player.movement.sync_slide_speed()
