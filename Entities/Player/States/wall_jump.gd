extends PlayerState

func setup() -> void:
	super()
	pass

func enter() -> void: 
	player.velocity += (Vector3.UP * player.movement.jump_velocity) + (player.wall_normal * player.movement.push_off_wall_force)
	
func exit() -> void: 
	pass
	
func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	player.movement.apply_gravity(_delta)
	player.move_and_slide()
	
	Transitioned.emit(self, "AIR")
