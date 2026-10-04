extends Control
@onready var level_report: Control = $LevelReport
@onready var finish_time: Label = $FinishTime

func _ready() -> void:
	populate_finish.call_deferred()

func _on_level_report_free_ui() -> void:
	queue_free()

func populate_finish() -> void:
	level_report.populate_report()
	finish_time.text = "%.2f" %LevelManager.player_time
