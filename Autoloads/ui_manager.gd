extends Node
const TITLE = preload("uid://cad2mj4oauw32")
const LEVEL_SELECT = preload("uid://b4bgodk2ydk3r")
const LEVEL_FINISH = preload("uid://1mvsvkkyyb8e")

## Instantiates the title scene
func go_to_title() -> void:
	var scene: PackedScene = TITLE
	var title_screen: Node = scene.instantiate()
	LevelManager.cleanup_main()
	
	LevelManager.main.add_child(title_screen)

## Instantiates the level select scene
func go_to_level_select() -> void:
	var scene: PackedScene = LEVEL_SELECT
	var level_select_screen: Node = scene.instantiate()
	LevelManager.cleanup_main()
	
	LevelManager.main.add_child(level_select_screen)

func show_level_report() -> void:
	var scene: PackedScene = LEVEL_FINISH
	var level_report_screen: Node = scene.instantiate()
	
	LevelManager.main.add_child(level_report_screen)
