extends Camera3D

@export var max_fov: float = 100
## Controls how much the FOV increases with speed.
@export var fov_multiplier: float = 3.0
## Controls how quickly the FOV changes.
@export var fov_smoothing: float = 5.0

@onready var player: Player = $"../.."
var base_fov: float

func _ready() -> void:
	# Store the camera's starting FOV
	base_fov = self.fov

func _process(delta: float) -> void:
	# Update the FOV based on the player's speed
	update_fov(delta)
	
func update_fov(delta: float) -> void:
	# Get the player's speed in the direction the camera is facing
	var forward_speed: float = player.velocity.dot(-%Head.global_transform.basis.z)
	
	# Ignore movement that is backwards
	forward_speed = max(forward_speed, 0.0)

	# Increase the FOV based on the player's forward speed
	var target_fov: float = base_fov + forward_speed * fov_multiplier
	
	# Prevent the FOV from going above the maximum
	target_fov = clamp(target_fov, base_fov, max_fov)

	# Smoothly move the current FOV toward the target FOV
	self.fov = lerp(self.fov, target_fov, delta * fov_smoothing)
