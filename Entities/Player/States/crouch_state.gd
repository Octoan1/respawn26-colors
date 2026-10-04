extends PlayerState

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

func setup() -> void:
	super()
	pass

func enter() -> void: 
	# shrink head
	animation_player.play("start_slide")
	
func exit() -> void: 
	# restore head
	animation_player.play("end_slide")
	pass
	
func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	var direction := player.get_movement_direction()
	
	# no direction -> no input -> transition idle
	if Input.is_action_just_released("player_slide"):
		Transitioned.emit(self, "IDLE")
		return

	player.movement.apply_ground_friction(delta)

	player.movement.accelerate_ground(
		direction,
		player.movement.crouch_speed,
		delta
	)
	
	player.move_and_slide()
