extends PlayerState

var coyote_timer: Timer

func setup() -> void:
	super()
	coyote_timer = Timer.new()
	coyote_timer.wait_time = 0.25
	pass

func enter() -> void: 
	pass
	
func exit() -> void: 
	pass
	
func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	if Input.is_action_just_pressed("player_jump") and coyote_timer.is_stopped():
		Transitioned.emit(self, "JUMP")
	
	if not player.is_on_floor():
		Transitioned.emit(self, "AIR")
	
	
	var input_dir := Input.get_vector("player_left", "player_right", "player_forwards", "player_backwards")
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		player.velocity.x = move_toward(player.velocity.x, direction.x * player.speed, player.acceleration * delta)
		player.velocity.z = move_toward(player.velocity.z, direction.z * player.speed, player.acceleration * delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.acceleration * delta)
		player.velocity.z = move_toward(player.velocity.z, 0, player.acceleration * delta)
	
	player.move_and_slide()
