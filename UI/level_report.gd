extends Control

signal free_ui
signal new_best

## UI POPULATION VARS
@onready var level_name: Label = $LevelName
@onready var flavor_text: Label = $FlavorText
@onready var rank_text: Label = $RankText
@onready var threshold_text: Label = $ThresholdText
@onready var next_rank: Label = $NextRank

## BUTTON TWEENING VARS
@onready var next_level: Button = $NextLevel
@onready var level_select: Button = $LevelSelect
@onready var main_menu: Button = $MainMenu
@onready var retry_button: Button = $RetryButton


@onready var next_level_size: Vector2 = next_level.size
@onready var level_select_size: Vector2 = level_select.size
@onready var main_menu_size: Vector2 = main_menu.size
@onready var retry_button_size: Vector2 = retry_button.size

const HOVER_WIDTH_EXTENSION: float = 100.0
const TWEEN_DURATION: float = 0.2

func _ready() -> void:
	next_level.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	level_select.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	main_menu.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	retry_button.grow_horizontal = Control.GROW_DIRECTION_BEGIN

## NEXT LEVEL
func _on_next_level_pressed() -> void:
	LevelManager.next_level()
	free_ui.emit()

func _on_next_level_mouse_entered() -> void:
	expand_button(next_level)

func _on_next_level_mouse_exited() -> void:
	close_button(next_level)

## RETRY LEVEL
func _on_retry_button_pressed() -> void:
	LevelManager.restart_level()
	free_ui.emit()

func _on_retry_button_mouse_entered() -> void:
	expand_button(retry_button)

func _on_retry_button_mouse_exited() -> void:
	close_button(retry_button)

## LEVEL SELECT
func _on_level_select_pressed() -> void:
	UiManager.go_to_level_select()
	free_ui.emit()

func _on_level_select_mouse_entered() -> void:
	expand_button(level_select)

func _on_level_select_mouse_exited() -> void:
	close_button(level_select)

## MAIN MENU
func _on_main_menu_pressed() -> void:
	UiManager.go_to_title()
	free_ui.emit()

func _on_main_menu_mouse_entered() -> void:
	expand_button(main_menu)

func _on_main_menu_mouse_exited() -> void:
	close_button(main_menu)

func expand_button(button: Button) -> void:
	# cancel tween early if there is one
	if button.has_meta("active_tween"):
		var old_tween: Tween = button.get_meta("active_tween") as Tween
		if old_tween and old_tween.is_valid():
			old_tween.kill()
	
	var new_tween: Tween = create_tween()
	new_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	button.set_meta("active_tween", new_tween)
	
	var target_size_x: float
	if button.name == "NextLevel":
		target_size_x = next_level_size.x + HOVER_WIDTH_EXTENSION
	elif button.name == "LevelSelect":
		target_size_x = level_select_size.x + HOVER_WIDTH_EXTENSION
	elif button.name == "MainMenu":
		target_size_x = main_menu_size.x + HOVER_WIDTH_EXTENSION
	elif button.name == "RetryButton":
		target_size_x = retry_button_size.x + HOVER_WIDTH_EXTENSION
	
	new_tween.tween_property(button, "size:x", target_size_x, TWEEN_DURATION)

func close_button(button: Button) -> void:
	# cancel tween early if there is one
	if button.has_meta("active_tween"):
		var old_tween: Tween = button.get_meta("active_tween") as Tween
		if old_tween and old_tween.is_valid():
			old_tween.kill()
	
	var new_tween: Tween = create_tween()
	new_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	button.set_meta("active_tween", new_tween)
	
	var target_size_x: float
	if button.name == "NextLevel":
		target_size_x = next_level_size.x
	elif button.name == "LevelSelect":
		target_size_x = level_select_size.x
	elif button.name == "MainMenu":
		target_size_x = main_menu_size.x
	elif button.name == "RetryButton":
		target_size_x = retry_button_size.x
	
	new_tween.tween_property(button, "size:x", target_size_x, TWEEN_DURATION)

func populate_report() -> void:
	var level_data: LevelData = LevelManager.LEVEL_LIST.levels[LevelManager.current_index]
	print(level_data.rank_times)
	
	# update level name
	level_name.text = level_data.name
	
	# update rank text + threshold text + next rank text
	var rank_index: int = 0
	var ranks: Array[String] = ["S", "A", "B", "C", "D", "F"]
	
	# traverse the level data, rank_times ordered from S -> D.
	# So, index 0 = rank S, index 1 = rank A, and so on.
	for time in level_data.rank_times:
		if LevelManager.player_time < time:
			# if player did NOT get an S rank (the max)
			# show the time requirment for the next rank
			if rank_index != 0:
				next_rank.show()
				next_rank.text = "Next time to beat: " + str(level_data.rank_times[rank_index-1])
			
			rank_text.text = ranks[rank_index]
			threshold_text.text = "%.2f" %time
			
			# check if this rank is an improvement, and update the level data
			var original_rank: int = ranks.find(level_data.rank)
			if rank_index < original_rank:
				level_data.rank = ranks[rank_index]
			
			# check if this new time is better than the old time
			if LevelManager.player_time < level_data.best_time:
				level_data.best_time = LevelManager.player_time
				new_best.emit()
			
			break
		rank_index += 1
	
	SaveManager.save_game()
