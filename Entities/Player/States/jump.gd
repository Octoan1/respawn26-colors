extends PlayerState

func setup() -> void:
	super()

func enter() -> void:
	# Apply jump velocity
	player.movement.jump()
	
	# Jump is only the initial launch
	Transitioned.emit(self, "AIR")
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
