extends Node
const LEVEL_LIST: LevelList = preload("res://levels/level_list.tres")
const TITLE = preload("uid://cad2mj4oauw32")
const MAIN = preload("uid://c8mcfocbl178j")

var current_index: int = 0

## Starts a fresh run from the first level.
func start_game() -> void:
	go_to_level(0)

func go_to_title() -> void:
	var scene: PackedScene = TITLE
	var title_screen: Node = scene.instantiate()
	get_tree().root.add_child(title_screen)

## Loads the level at [param index] in the list, refusing indices that don't exist.
func go_to_level(index: int) -> void:
	if not _is_valid_index(index):
		push_error("LevelManager: no level at index %d" % index)
		return
	
	current_index = index
	
	var scene: PackedScene = get_current_level()
	if scene == null:
		return
	var level: Node = scene.instantiate()
	
	print(get_tree().root)
	print(get_tree().root.get_children())
	
	var main: Node = get_tree().root.get_child(2)
	main.add_child(level)
	remove_level(current_index - 1)


## Advances to the next level, or back to the title after the last one.
func complete_level() -> void:
	if _is_valid_index(current_index + 1):
		go_to_level(current_index + 1)
	else:
		remove_level(current_index)
		current_index = 0
		go_to_title()

func remove_level(index: int) -> void:
	if not _is_valid_index(index):
		#push_error("LevelManager: no level at index %d" % index)
		return
	var level_num: int = index + 1
	var level_name: String = "Level" + str(level_num)
	#print(level_name)
	
	var main: Node = get_tree().root.get_child(2)
	for child in main.get_children():
		#print(child.name)
		if child.name == level_name:
			#print("level found.")
			child.queue_free()

## Reloads the current level from scratch.
func restart_level() -> void:
	go_to_level(current_index)


## Returns the scene for the level currently being played, or null if the index is bad.
func get_current_level() -> PackedScene:
	if not _is_valid_index(current_index):
		push_error("LevelManager: no level at index %d" % current_index)
		return null
	return LEVEL_LIST.levels[current_index]


## Whether [param index] points at a filled slot in the level list.
func _is_valid_index(index: int) -> bool:
	return index >= 0 and index < LEVEL_LIST.levels.size() and LEVEL_LIST.levels[index] != null
