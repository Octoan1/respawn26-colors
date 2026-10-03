extends PlayerState

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

func setup() -> void:
	super()
	pass

func enter() -> void: 
	# shrink head
	animation_player.play("start_slide")
	player.velocity *= Vector3(1.5,0,1.5)
	
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
		
	if player.velocity:
		player.velocity.x = move_toward(player.velocity.x, 0, 0.25* player.acceleration * delta)
		player.velocity.z = move_toward(player.velocity.z, 0, 0.25*player.acceleration * delta)
	
	
	if player.horizonal_velocity.length() < 3:
		Transitioned.emit(self,"IDLE")
	
	player.move_and_slide()
