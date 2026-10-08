extends Control
@onready var rich_text_label: RichTextLabel = $RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_title_text()

func _on_start_game_pressed() -> void:
	UiManager.go_to_level_brief(0, "menu")
	#LevelManager.start_game()
	#queue_free()


func _on_level_select_pressed() -> void:
	UiManager.go_to_level_select()
	#queue_free()

func update_title_text() -> void:
	rich_text_label.text = "Operation ROYGBIV"
	
	# green ability unlocked
	if SaveManager.levels_complete >= 3:
		rich_text_label.text = "Operation ROY[color=2dea01]G[/color]BIV"
	
	# orange world complete
	if SaveManager.levels_complete >= 5:
		rich_text_label.text = "Operation R[color=orange]O[/color]Y[color=2dea01]G[/color]BIV"
	# blue ability unlocked
	if SaveManager.levels_complete >= 6:
		rich_text_label.text = "Operation R[color=orange]O[/color]Y[color=2dea01]G[/color][color=2000da]B[/color]IV"
	# indigo world complete
	if SaveManager.levels_complete >= 8:
		rich_text_label.text = "Operation R[color=orange]O[/color]Y[color=2dea01]G[/color][color=2000da]B[/color][color=indigo]I[/color]V"
	# red ability unlocked
	if SaveManager.levels_complete >= 9:
		rich_text_label.text = "Operation [color=da0100]R[/color][color=orange]O[/color]Y[color=2dea01]G[/color][color=2000da]B[/color][color=indigo]I[/color]V"
	# yellow world complete
	if SaveManager.levels_complete >= 12:
		rich_text_label.text = "Operation [color=da0100]R[/color][color=orange]O[/color][color=yellow]Y[/color][color=2dea01]G[/color][color=2000da]B[/color][color=indigo]I[/color]V"
	# violet world complete
	if SaveManager.levels_complete >= 16:
		rich_text_label.text = "Operation [color=da0100]R[/color][color=orange]O[/color][color=yellow]Y[/color][color=2dea01]G[/color][color=2000da]B[/color][color=indigo]I[/color][color=violet]V[/color]"
