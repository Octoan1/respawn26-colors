extends PlayerState

const JUMP = preload("uid://1hlxkoq66361")

func setup() -> void:
	super()
	pass

func enter() -> void: 
	var m := player.movement

	var normal := player.wall_normal
	normal.y = 0.0
	normal = normal.normalized()

	# Remove the "pressed into the wall" component left over from the wall stick,
	# otherwise it eats into the push-off
	var into := player.velocity.dot(normal)
	if into < 0.0:
		player.velocity -= normal * into

	# Kick away from the wall, keep the speed along it
	player.velocity += normal * m.push_off_wall_force

	# Set (not add) vertical speed so a slipping, falling run still gives a full jump
	player.velocity.y = m.jump_velocity
	
	AudioManager.play_sfx(JUMP, randf_range(1.0,1.2))
	
func exit() -> void: 
	pass
	
func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	player.movement.apply_gravity(_delta)
	player.move_and_slide()
	
	Transitioned.emit(self, "AIR")
