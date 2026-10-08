extends PlayerState

func setup() -> void:
	super()

func enter() -> void:
	player.movement.fire_explosion()
	
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	player.movement.apply_gravity(_delta)
	player.move_and_slide()
	
	# Jump is only the initial launch
	Transitioned.emit(self, "AIR")
