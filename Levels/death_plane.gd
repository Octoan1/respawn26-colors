extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		#LevelManager.complete_level()
		UiManager.show_level_fail()
		LevelManager.level_fail()
		LevelManager.stopwatch_on = false
		LevelManager.player_time = 0.0
