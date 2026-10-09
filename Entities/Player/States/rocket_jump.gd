extends PlayerState

const RED_ABILITY = preload("uid://dqgtx6o5l3pqt")

func setup() -> void:
	super()

func enter() -> void:
	player.movement.fire_explosion()
	player.sprite.play("Red Push")
	
	AudioManager.play_sfx(RED_ABILITY, randf_range(.8, 1.1), 1.2)
	
func exit() -> void:
	await player.sprite.animation_finished
	player.sprite.play("Red Idle")
	
func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	player.movement.apply_gravity(_delta)
	player.move_and_slide()
	
	# Jump is only the initial launch
	Transitioned.emit(self, "AIR")
