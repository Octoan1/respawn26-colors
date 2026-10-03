extends Node
const TEST_LEVEL = preload("uid://dpvvbsn3hlm2p")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_map"):
		go_to_debug_map()

## Loads the level at [param index] in the list, refusing indices that don't exist.
func go_to_debug_map() -> void:
	
	var scene: PackedScene = TEST_LEVEL
	var level: Node = scene.instantiate()
	
	cleanup_main()
	LevelManager.main.add_child(level)

func cleanup_main() -> void:
	for child in LevelManager.main.get_children():
		child.queue_free()
