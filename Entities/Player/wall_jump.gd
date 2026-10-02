extends PlayerState

func setup() -> void:
	super()
	pass

func enter() -> void: 
	player.velocity.y = player.jump_velocity
	
func exit() -> void: 
	pass
	
func update(_delta: float) -> void:
	Transitioned.emit(self, "AIR")

func physics_update(_delta: float) -> void:
	pass
