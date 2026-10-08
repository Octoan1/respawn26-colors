extends PlayerState

const JUMP = preload("uid://1hlxkoq66361")

func setup() -> void:
	super()

func enter() -> void:
	# Apply jump velocity
	player.movement.jump()
	AudioManager.play_sfx(JUMP, randf_range(.8,1.2))
	
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	player.movement.apply_gravity(_delta)
	player.move_and_slide()
	
	# Jump is only the initial launch
	Transitioned.emit(self, "AIR")
