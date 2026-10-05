extends Node
const TEST_LEVEL = preload("uid://dpvvbsn3hlm2p")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_map"):
		go_to_debug_map()
	if event.is_action_pressed("debug_delete_save"):
		SaveManager.clear_save_data()
		SaveManager.load_game()

## Loads the level at [param index] in the list, refusing indices that don't exist.
func go_to_debug_map() -> void:
	
	var scene: PackedScene = TEST_LEVEL
	var level: Node = scene.instantiate()
	
	cleanup_main()
	LevelManager.main.add_child(level)

func cleanup_main() -> void:
	for child in LevelManager.main.get_children():
		if child.name == "CanvasLayer":
			for grandchild in child.get_children():
				grandchild.queue_free()
			continue
		child.queue_free()
