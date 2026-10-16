extends Control
@onready var mouse_sens_slider: HSlider = $VBoxContainer/HBoxContainer4/MouseSensSlider
@onready var master_volume_slider: HSlider = $VBoxContainer/HBoxContainer/MasterVolumeSlider
@onready var fullscreen_check_box: CheckBox = $VBoxContainer/HBoxContainer5/Control/FullscreenCheckBox
@onready var delete_data_label: Label = $DeleteDataLabel

func _ready() -> void:
	reset_ui_appearance()


func _on_master_volume_slider_value_changed(value: float) -> void:
	SaveManager.master_volume = value
	AudioManager.set_master_volume(value)
	SaveManager.save_game()


func _on_back_button_pressed() -> void:
	UiManager.go_to_title()

func _on_delete_save_button_pressed() -> void:
	SaveManager.clear_save_data()
	SaveManager.load_game()
	delete_data_label.visible = true


func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioManager.set_music_volume(value)


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)


func _on_mouse_sens_slider_value_changed(value: float) -> void:
	SaveManager.mouse_sensitivity = value
	SaveManager.save_game()


func _on_fullscreen_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		get_window().mode = Window.MODE_FULLSCREEN
		SaveManager.fullscreen_on = true
	else:
		get_window().mode = Window.MODE_WINDOWED
		SaveManager.fullscreen_on = false
	SaveManager.save_game()

func reset_settings() -> void:
	# reset the save data for the settings
	SaveManager.reset_settings()
	SaveManager.load_game()
	
	# reset the actual settings
	if SaveManager.fullscreen_on == true:
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED
	
	AudioManager.set_master_volume(SaveManager.master_volume)
	
	# reset the ui appearances
	reset_ui_appearance()

func reset_ui_appearance() -> void:
	mouse_sens_slider.value = SaveManager.mouse_sensitivity
	master_volume_slider.value = SaveManager.master_volume
	fullscreen_check_box.button_pressed = SaveManager.fullscreen_on
