extends Control

## BUTTON TWEENING VARS
@onready var level_select: Button = $LevelSelect
@onready var main_menu: Button = $MainMenu
@onready var retry_button: Button = $RetryButton

@onready var level_select_size: Vector2 = level_select.size
@onready var main_menu_size: Vector2 = main_menu.size
@onready var retry_button_size: Vector2 = retry_button.size

const HOVER_WIDTH_EXTENSION: float = 100.0
const TWEEN_DURATION: float = 0.2

func _ready() -> void:
	level_select.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	main_menu.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	retry_button.grow_horizontal = Control.GROW_DIRECTION_BEGIN

## RETRY LEVEL
func _on_retry_button_pressed() -> void:
	LevelManager.restart_level()
	#free_ui.emit()

func _on_retry_button_mouse_entered() -> void:
	expand_button(retry_button)

func _on_retry_button_mouse_exited() -> void:
	close_button(retry_button)

## LEVEL SELECT
func _on_level_select_pressed() -> void:
	UiManager.go_to_level_select()
	#free_ui.emit()

func _on_level_select_mouse_entered() -> void:
	expand_button(level_select)

func _on_level_select_mouse_exited() -> void:
	close_button(level_select)

## MAIN MENU
func _on_main_menu_pressed() -> void:
	UiManager.go_to_title()
	#free_ui.emit()

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
	if button.name == "LevelSelect":
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
	if button.name == "LevelSelect":
		target_size_x = level_select_size.x
	elif button.name == "MainMenu":
		target_size_x = main_menu_size.x
	elif button.name == "RetryButton":
		target_size_x = retry_button_size.x
	
	new_tween.tween_property(button, "size:x", target_size_x, TWEEN_DURATION)
