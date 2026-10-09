extends Button

#UI SFX
const UI_CLICK = preload("uid://dyptwuywo2c45")
const UI_HOVER = preload("uid://euimh6envyw6")
var hover_played = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_hovered():
		if !hover_played:
			AudioManager.play_sfx(UI_HOVER)
			hover_played = true
	else:
		hover_played = false

func _pressed() -> void:
	AudioManager.play_sfx(UI_CLICK)
