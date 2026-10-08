extends PlayerState

const DASH = preload("uid://b8xoxahaqno7g")

func setup() -> void:
	super()

func enter() -> void:
	#-player.camera.global_transform.basis.z
	player.movement.dash(player.get_movement_direction())
	player.sprite.play("Green Dash")
	AudioManager.play_sfx(DASH, randf_range(.8,1.2))

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
