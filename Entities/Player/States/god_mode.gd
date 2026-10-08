extends PlayerState

@export var fly_speed := 12.0
@export var sprint_multiplier := 3.0

var saved_layer := 0
var saved_mask := 0


func setup() -> void:
	super()

func enter() -> void:
	saved_layer = player.collision_layer
	saved_mask = player.collision_mask
	player.collision_layer = 0
	player.collision_mask = 0

	player.velocity = Vector3.ZERO

	# Clear wall run camera effects
	player.camera_roll_target = 0.0
	player.camera_fov_boost = 0.0

func exit() -> void:
	player.collision_layer = saved_layer
	player.collision_mask = saved_mask
	player.velocity = Vector3.ZERO

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	var input_dir := Input.get_vector("player_left", "player_right", "player_forwards", "player_backwards")

	# Fly relative to where the camera is looking (including pitch)
	var cam_basis := player.camera.global_transform.basis
	var direction := cam_basis * Vector3(input_dir.x, 0.0, input_dir.y)

	# Vertical movement
	direction.y += Input.get_axis("player_crouch", "player_jump")

	var speed := fly_speed
	if Input.is_action_pressed("player_sprint"):
		speed *= sprint_multiplier

	# Move directly instead of using move_and_slide(), so floor snapping
	# and slide logic never interfere
	player.global_position += direction.normalized() * speed * delta
