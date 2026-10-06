extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_start_game_pressed() -> void:
	UiManager.go_to_level_brief(0, "menu")
	#LevelManager.start_game()
	#queue_free()


func _on_level_select_pressed() -> void:
	UiManager.go_to_level_select()
	#queue_free()
