extends CharacterBody3D
class_name Player

@export var mouse_sensitivity: float = 0.002

@onready var head: Node3D = $Head
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var movement: PlayerMovement = $Movement
@onready var camera: Camera3D = $Head/Camera3D
@onready var outline_material: ShaderMaterial = $Head/Shader.material_override as ShaderMaterial
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var debug_velocity: Label = $Debug/DebugVelocity
@onready var debug_state: Label = $Debug/DebugState
@onready var debug_fov: Label = $Debug/DebugFOV

@onready var ray: RayCast3D = $Head/Camera3D/RayCast3D
var coyote_timer: Timer
var jump_buffer_timer: Timer
var wall_grab_timer: Timer
var glide_timer: Timer

var wall_normal: Vector3

var wall_cooldown_timer: float = 0.0
var camera_roll_target: float = 0.0
var camera_fov_boost: float = 0.0
var base_fov: float = 75.0
var _crouch_animation_target := false
var stand_height: float = 2.0
var capsule: CapsuleShape3D

# conner added this, sorry if it breaks something
var freeze_control: bool = false

enum Ability_Color {
	BASE,
	RED,
	GREEN,
	BLUE
}
var abilities: Array[Ability_Color]
var ability_index: int
var curr_ability: Ability_Color
var ability_charges_r: int = 1
var ability_charges_g: int = 1
var ability_charges_b: int = 1

func _ready() -> void:
	animation_player.play("RESET")
	capsule = collision_shape.shape as CapsuleShape3D
	if outline_material == null:
		push_error("Player outline material is missing or is not a ShaderMaterial.")
	
	base_fov = camera.fov
	
	coyote_timer = Timer.new()
	coyote_timer.one_shot = true
	coyote_timer.wait_time = 0.25
	add_child(coyote_timer)
	
	wall_grab_timer = Timer.new()
	wall_grab_timer.one_shot = true
	wall_grab_timer.wait_time = 0.1
	add_child(wall_grab_timer)
	
	jump_buffer_timer = Timer.new()
	jump_buffer_timer.one_shot = true
	jump_buffer_timer.wait_time = 0.1
	add_child(jump_buffer_timer)
	
	glide_timer = Timer.new()
	glide_timer.one_shot = true
	glide_timer.wait_time = 2.0
	add_child(glide_timer)
	
	curr_ability = Ability_Color.BASE
	abilities = []
	ability_index = -1

	var debug_manager := get_node_or_null("/root/DebugManager")
	if debug_manager and debug_manager.has_signal("toggle_auto_bhop"):
		if not debug_manager.is_connected("toggle_auto_bhop", _on_toggle_auto_bhop):
			debug_manager.connect("toggle_auto_bhop", _on_toggle_auto_bhop)

func _unhandled_input(event: InputEvent) -> void:
	if freeze_control:
		return
	
	# Recapture mouse
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Release mouse
	if event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event is InputEventMouseMotion:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			return
		
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(
			head.rotation.x,
			deg_to_rad(-89),
			deg_to_rad(89)
		)
	
	if event is InputEvent:
		change_ability(event)
	
	if event.is_action_pressed("GOD_MODE"):
		var sm := $StateMachine
		var current: State = sm.current_state
		if current.name == "GOD_MODE":
			current.Transitioned.emit(current, "AIR")
		else:
			current.Transitioned.emit(current, "GOD_MODE")
		return
	
	if event.is_action_pressed("toggle_r"):
		if abilities.find(Ability_Color.RED) != -1:
			remove_ability(Ability_Color.RED)
		else:
			gain_ability(Ability_Color.RED)
		print("Abilities: ", abilities)
		print("Curr_Ability: ", curr_ability)
		print("Ability_Index: ", ability_index)
	if event.is_action_pressed("toggle_g"):
		if abilities.find(Ability_Color.GREEN) != -1:
			remove_ability(Ability_Color.GREEN)
		else:
			gain_ability(Ability_Color.GREEN)
		print("Abilities: ", abilities)
		print("Curr_Ability: ", curr_ability)
		print("Ability_Index: ", ability_index)
	if event.is_action_pressed("toggle_b"):
		if abilities.find(Ability_Color.BLUE) != -1:
			remove_ability(Ability_Color.BLUE)
		else:
			gain_ability(Ability_Color.BLUE)
		print("Abilities: ", abilities)
		print("Curr_Ability: ", curr_ability)
		print("Ability_Index: ", ability_index)

func _physics_process(delta: float) -> void:
	wall_cooldown_timer = maxf(wall_cooldown_timer - delta, 0.0)

func _process(delta: float) -> void:
	debug_velocity.text = "Vel: %.2f" % velocity.length()
	debug_state.text = $StateMachine.current_state.name
	debug_fov.text = "fov: %.2f" % camera.fov

	if outline_material != null:
		outline_material.set_shader_parameter(
			"player_inverse_transform",
			global_transform.affine_inverse()
		)
	
	var w := 1.0 - exp(-movement.wall_tilt_speed * delta)
	camera.rotation.z = lerp_angle(camera.rotation.z, camera_roll_target, w)

func start_wall_cooldown() -> void:
	wall_cooldown_timer = movement.wall_cooldown


func set_crouch_animation(crouched: bool) -> void:
	if _crouch_animation_target == crouched and animation_player.is_playing():
		return

	_crouch_animation_target = crouched
	if crouched:
		animation_player.play("Crouch")
	else:
		animation_player.play_backwards("Crouch")


func can_wall_run() -> bool:
	if is_on_floor() or wall_cooldown_timer > 0.0:
		return false
	var normal := find_wall_normal()
	return normal != Vector3.ZERO and has_wall_run_clearance(normal)

func get_movement_direction() -> Vector3:
	var input_dir := Input.get_vector(
		"player_left",
		"player_right",
		"player_forwards",
		"player_backwards"
	)

	var direction := transform.basis * Vector3(
		input_dir.x,
		0.0,
		input_dir.y
	)

	direction.y = 0.0

	return direction.normalized()

func find_wall_normal() -> Vector3:
	# Test for a wall just beside/in front of us, without needing to be pressed into it
	var dirs: Array[Vector3] = [
		get_movement_direction(),
		-global_transform.basis.z,
		global_transform.basis.x,
		-global_transform.basis.x,
	]
	for d in dirs:
		if d == Vector3.ZERO:
			continue
		var col := KinematicCollision3D.new()
		if test_move(global_transform, d.normalized() * movement.wall_probe_distance, col):
			var n := col.get_normal()
			if absf(n.y) <= 0.1:   # near-vertical surfaces only
				return n
	return Vector3.ZERO

func has_wall_run_clearance(normal: Vector3) -> bool:
	var new_wall_normal := Vector3(normal.x, 0.0, normal.z).normalized()
	var capsule := collision_shape.shape as CapsuleShape3D
	if new_wall_normal == Vector3.ZERO or capsule == null:
		return false

	# Check just inside the top and bottom of the capsule. The wall must span
	# both points, leaving only the configured margin outside the body.
	var half_height := maxf(capsule.height * 0.5 - movement.wall_run_clearance, 0.1)
	var center := collision_shape.global_position
	var cast_distance := maxf(movement.wall_probe_distance + 0.2, 0.5)
	var query_points := [
		center + Vector3.UP * half_height,
		center - Vector3.UP * half_height,
	]

	for point: Vector3 in query_points:
		var query := PhysicsRayQueryParameters3D.create(
			point + new_wall_normal * cast_distance,
			point - new_wall_normal * cast_distance,
			collision_mask
		)
		query.exclude = [get_rid()]
		if get_world_3d().direct_space_state.intersect_ray(query).is_empty():
			return false

	return true

func remove_ability(color: Ability_Color) -> void:
	if abilities.find(color) != -1:
		abilities.remove_at(abilities.find(color))
		if abilities.is_empty():
			ability_index = -1
			curr_ability = Ability_Color.BASE
		else:
			ability_index = 0
			curr_ability = abilities[ability_index]

func gain_ability(color: Ability_Color) -> void:
	if abilities.find(color) == -1:
		abilities.append(color)
	if curr_ability == Ability_Color.BASE:
		ability_index = 0
		curr_ability = abilities[ability_index]

func change_ability(event: InputEvent) -> void:
	if abilities.is_empty():
		return
	if event.is_action_pressed("cycle_ability_left"):
		ability_index = (ability_index - 1) % abilities.size()
		curr_ability = abilities[ability_index]
		print("Abilities: ", abilities)
		print("Curr_Ability: ", curr_ability)
		print("Ability_Index: ", ability_index)
		return
	if event.is_action_pressed("cycle_ability_right"):
		ability_index = (ability_index + 1) % abilities.size()
		curr_ability = abilities[ability_index]
		print("Abilities: ", abilities)
		print("Curr_Ability: ", curr_ability)
		print("Ability_Index: ", ability_index)
		return
	if event.is_action_pressed("change_ability_r"):
		var index := abilities.find(Ability_Color.RED)
		if index != -1:
			ability_index = index
			curr_ability = Ability_Color.RED
			print("Abilities: ", abilities)
			print("Curr_Ability: ", curr_ability)
			print("Ability_Index: ", ability_index)
		return
	if event.is_action_pressed("change_ability_g"):
		var index := abilities.find(Ability_Color.GREEN)
		if index != -1:
			ability_index = index
			curr_ability = Ability_Color.GREEN
			print("Abilities: ", abilities)
			print("Curr_Ability: ", curr_ability)
			print("Ability_Index: ", ability_index)
		return
	if event.is_action_pressed("change_ability_b"):
		var index := abilities.find(Ability_Color.BLUE)
		if index != -1:
			ability_index = index
			curr_ability = Ability_Color.BLUE
			print("Abilities: ", abilities)
			print("Curr_Ability: ", curr_ability)
			print("Ability_Index: ", ability_index)
		return

func _on_toggle_auto_bhop() -> void:
	movement.auto_bhop = not movement.auto_bhop

func can_stand() -> bool:
	# How much taller we'd get by standing up
	var extra := stand_height - capsule.height
	if extra <= 0.01:
		return true   # already standing

	# true from test_move means we'd hit something, so there's no room
	return not test_move(global_transform, Vector3.UP * extra)
