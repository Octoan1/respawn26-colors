extends Control
@onready var mouse_sens_slider: HSlider = $VBoxContainer/HBoxContainer4/MouseSensSlider


func _ready() -> void:
	mouse_sens_slider.value = SaveManager.mouse_sensitivity


func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioManager.set_master_volume(value)


func _on_back_button_pressed() -> void:
	UiManager.go_to_title()

func _on_delete_save_button_pressed() -> void:
	SaveManager.clear_save_data()
	SaveManager.load_game()


func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioManager.set_music_volume(value)


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)


func _on_mouse_sens_slider_value_changed(value: float) -> void:
	SaveManager.mouse_sensitivity = value
	SaveManager.save_game()
