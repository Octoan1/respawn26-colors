extends Camera3D

@export var enable_dyamic_fov: bool = true
@export var max_fov: float = 100.0
@export var fov_multiplier: float = 3.0
@export var fov_smoothing: float = 5.0
@export var fov_start_speed: float = 8.0
@export var slide_fov_lurch_amount: float = 12.0
@export var slide_fov_lurch_decay: float = 80.0
@export var slide_min_fov: float = 80.0
@export var slide_fov_entry_speed: float = 25.0

@onready var player: Player = $"../.."

var base_fov: float
var _slide_fov_lurch_offset: float = 0.0
var _slide_fov_entry_active := false


func _ready() -> void:
	base_fov = fov


func _process(delta: float) -> void:
	#if not enable_dyamic_fov:
		#return

	_slide_fov_lurch_offset = move_toward(
		_slide_fov_lurch_offset,
		0.0,
		slide_fov_lurch_decay * delta
	)

	var forward_speed := maxf(
		player.velocity.dot(-%Head.global_transform.basis.z),
		0.0
	)
	var speed_fov := maxf(forward_speed - fov_start_speed, 0.0) * fov_multiplier
	var normal_fov := clampf(
		base_fov + speed_fov + player.camera_fov_boost,
		base_fov,
		max_fov
	)
	var target_fov := normal_fov + _slide_fov_lurch_offset
	var fov_speed := fov_smoothing
	if _slide_fov_entry_active:
		target_fov = maxf(target_fov, slide_min_fov)
		fov_speed = slide_fov_entry_speed

	fov = lerpf(
		fov,
		target_fov,
		1.0 - exp(-fov_speed * delta)
	)
	if _slide_fov_entry_active and fov >= slide_min_fov - 0.1:
		_slide_fov_entry_active = false


func trigger_slide_lurch() -> void:
	_slide_fov_entry_active = fov < slide_min_fov
	_slide_fov_lurch_offset = slide_fov_lurch_amount
