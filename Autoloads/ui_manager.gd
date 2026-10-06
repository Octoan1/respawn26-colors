extends Node
const TITLE = preload("uid://cad2mj4oauw32")
const LEVEL_SELECT = preload("uid://b4bgodk2ydk3r")
const LEVEL_FINISH = preload("uid://1mvsvkkyyb8e")
const LEVEL_BRIEF = preload("uid://cwequt0alhfgo")

var main_canvas: CanvasLayer

## Instantiates the title scene
func go_to_title(startup: bool = false) -> void:
	get_canvas_layer()
	
	var scene: PackedScene = TITLE
	var title_screen: Node = scene.instantiate()
	
	if !startup:
		await TransitionManager.play_transition()
	LevelManager.cleanup_main()
	
	main_canvas.add_child(title_screen)
	if !startup:
		await TransitionManager.end_transition()

## Instantiates the level select scene
func go_to_level_select() -> void:
	get_canvas_layer()
	
	var scene: PackedScene = LEVEL_SELECT
	var level_select_screen: Node = scene.instantiate()
	
	await TransitionManager.play_transition()
	
	LevelManager.cleanup_main()
	main_canvas.add_child(level_select_screen)
	
	await TransitionManager.end_transition()
	

func show_level_report() -> void:
	get_canvas_layer()
	
	var scene: PackedScene = LEVEL_FINISH
	var level_report_screen: Node = scene.instantiate()
	
	main_canvas.add_child(level_report_screen)

func go_to_level_brief(level_num: int, from: String) -> void:
	get_canvas_layer()
	await TransitionManager.play_transition()
	
	var scene: PackedScene = LEVEL_BRIEF
	var level_brief_screen: Node = scene.instantiate()
	
	
	for child in level_brief_screen.get_children():
		if child.name == "FullBrief":
			for grandchild in child.get_children():
				if grandchild.name == "Background":
					for baby in grandchild.get_children():
						if baby.name == "BeginButton":
							baby.pressed.connect(LevelManager.go_to_level.bind(level_num))
						elif baby.name == "BackButton":
							if from == "menu":
								baby.pressed.connect(go_to_title)
							elif from == "level_select":
								baby.pressed.connect(go_to_level_select)
	
	LevelManager.cleanup_main()
	var level_data: LevelData = LevelManager.LEVEL_LIST.levels[level_num]
	main_canvas.add_child(level_brief_screen)
	level_brief_screen.populate_brief(level_data)
	
	await TransitionManager.end_transition()

func get_canvas_layer() -> void:
	main_canvas = LevelManager.main.get_child(0)
