extends Node
const LEVEL_LIST: LevelList = preload("res://levels/level_list.tres")

var player_time: float
var stopwatch_on: bool = false
var player_freeze: bool = false

var main: Node
var player: Node3D
var goal: Area3D
var state_machine: StateMachine

var current_index: int = 0
"""
TO ADD A LEVEL:
Create a new LevelData resource
Give the proper data to the level
Put that level data resource into the LevelList resource
"""

func _ready() -> void:
	for child in get_tree().root.get_children():
		if child.name == "Main":
			main = child
			break

## Starts a fresh run from the first level.
func start_game() -> void:
	go_to_level(0)



## Loads the level at [param index] in the list, refusing indices that don't exist.
func go_to_level(index: int) -> void:
	player_freeze = false
	if not _is_valid_index(index):
		push_error("LevelManager: no level at index %d" % index)
		return
	
	await TransitionManager.play_transition()
	
	current_index = index
	
	var scene: PackedScene = get_current_level()
	if scene == null:
		return
	var level: Node = scene.instantiate()
	
	cleanup_main()
	main.add_child(level)
	
	get_level_references()
	goal.give_player(player)
	
	await TransitionManager.end_transition()
	
	# handle time vars
	player_time = 0
	stopwatch_on = true


## Advances to the next level, or back to the title after the last one.
## rework this block so it instead opens up the level_finish ui.
func complete_level() -> void:
	stopwatch_on = false
	
	get_level_references()
	freeze_player()
	
	var level: LevelData = LEVEL_LIST.levels[current_index]
	level.is_complete = true
	
	## display level_report ui here
	UiManager.show_level_report()
	SaveManager.save_game()

func next_level() -> void:
	if _is_valid_index(current_index + 1):
		go_to_level(current_index + 1)
	else:
		#cleanup_main()
		current_index = 0
		UiManager.go_to_title()

## Reloads the current level from scratch.
func restart_level() -> void:
	go_to_level(current_index)


## Returns the scene for the level currently being played, or null if the index is bad.
func get_current_level() -> PackedScene:
	if not _is_valid_index(current_index):
		push_error("LevelManager: no level at index %d" % current_index)
		return null
	return LEVEL_LIST.levels[current_index].scene


## Whether [param index] points at a filled slot in the level list.
func _is_valid_index(index: int) -> bool:
	return index >= 0 and index < LEVEL_LIST.levels.size() and LEVEL_LIST.levels[index] != null

func _process(delta: float) -> void:
	if stopwatch_on:
		player_time += delta
	
	if player_freeze:
		if player and goal:
			var target_pos: Vector3 = goal.target_sprite.global_transform.origin
			var direction: Vector3 = player.camera.global_position.direction_to(target_pos)
			if direction.is_zero_approx():
				return
			
			var target_basis: Basis = Basis.looking_at(direction, Vector3.UP)
			player.camera.global_transform.basis = player.camera.global_transform.basis.slerp(target_basis, 5 * delta)

func freeze_player() -> void:
	state_machine.is_frozen = true
	player.freeze_control = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player_freeze = true
	
	#var target_pos: Vector3 = goal.target_sprite.global_transform.origin
	#player.camera.look_at(target_pos, Vector3.UP)

func get_level_references() -> void:
	for child in main.get_child(1).get_children():
		if child is Player:
			player = child
		if child.name == "Goal":
			goal = child
	
	for child in player.get_children():
		if child.name == "StateMachine":
			state_machine = child

func cleanup_main() -> void:
	for child in LevelManager.main.get_children():
		if child.name == "CanvasLayer":
			for grandchild in child.get_children():
				grandchild.queue_free()
			continue
		child.queue_free()
