extends PlayerState

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

func setup() -> void:
	super()
	pass

func enter() -> void: 
	# shrink head
	animation_player.play("start_slide")
	
	var direction: Vector3 = player.get_movement_direction()

	# If there is no input, slide in the direction we're already moving
	if direction == Vector3.ZERO:
		direction = Vector3(
			player.velocity.x,
			0.0,
			player.velocity.z
		).normalized()

	player.movement.start_slide(direction)
	
func exit() -> void: 
	# restore head
	animation_player.play("end_slide")
	pass
	
func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	# player jumps
	if Input.is_action_just_pressed("player_jump") and player.is_on_floor():
		Transitioned.emit(self, "JUMP")
	
	# player starts falling (could be pushed off edge)
	if not player.is_on_floor():
		player.coyote_timer.start()
		Transitioned.emit(self, "AIR")
		return
	
	if Input.is_action_just_released("player_slide"):
		Transitioned.emit(self,"LANDING")
	
	
	if player.movement.get_horizontal_velocity().length() < player.movement.min_speed_for_slide:
		Transitioned.emit(self,"IDLE")
	
	player.movement.apply_slide_friction(delta)
	player.move_and_slide()
