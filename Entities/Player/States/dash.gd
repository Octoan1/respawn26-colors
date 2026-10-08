extends PlayerState

func setup() -> void:
	super()

func enter() -> void:
	#-player.camera.global_transform.basis.z
	player.movement.dash(player.get_movement_direction())
	player.sprite.play("Green Dash")
	
func exit() -> void:
	await player.sprite.animation_finished
	player.sprite.play("Green Idle")
	
func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	player.movement.apply_gravity(_delta)
	player.move_and_slide()
	
	# Jump is only the initial launch
	Transitioned.emit(self, "AIR")
