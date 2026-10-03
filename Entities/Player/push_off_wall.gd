extends PlayerState

func setup() -> void:
	super()
	pass

func enter() -> void: 
	player.velocity += player.wall_normal * player.push_off_wall_force
	
func exit() -> void: 
	pass
	
func update(_delta: float) -> void:
	Transitioned.emit(self, "AIR")

func physics_update(_delta: float) -> void:
	pass
