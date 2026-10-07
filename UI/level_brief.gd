extends Control
## UI POPULATION VARS

@onready var level_name: Label = $FullBrief/LevelName
@onready var target_info: Label = $FullBrief/TargetInfo
@onready var rank_text: Label = $FullBrief/RankText
@onready var best_time_text: Label = $FullBrief/BestTimeText
@onready var death_x: Label = $FullBrief/DeathX
@onready var target_image = $FullBrief/TargetImage


## BUTTON TWEENING VARS
@onready var begin_button: Button = $FullBrief/Background/BeginButton
@onready var back_button: Button = $FullBrief/Background/BackButton

@onready var begin_size: Vector2 = begin_button.size
@onready var back_size: Vector2 = back_button.size

const HOVER_WIDTH_EXTENSION: float = 100.0
const TWEEN_DURATION: float = 0.2

func _ready() -> void:
	begin_button.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	back_button.grow_horizontal = Control.GROW_DIRECTION_BEGIN

func populate_brief(level: LevelData) -> void:
	level_name.text = level.name
	target_info.text = level.target_info
	print(level.rank)
	print(level.best_time)
	if level.rank != "F":
		rank_text.text = level.rank
	if level.best_time != 99999.0:
		best_time_text.text = "%.2fs" %level.best_time
	if level.is_complete:
		#death_x.visible = true
		pass
	target_image.texture = level.target_image
	

func _on_begin_button_mouse_entered() -> void:
	expand_button(begin_button)


func _on_begin_button_mouse_exited() -> void:
	close_button(begin_button)


func _on_back_button_mouse_entered() -> void:
	expand_button(back_button)

func _on_back_button_mouse_exited() -> void:
	close_button(back_button)

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
	if button.name == "BeginButton":
		target_size_x = begin_size.x + HOVER_WIDTH_EXTENSION
	elif button.name == "BackButton":
		target_size_x = back_size.x + HOVER_WIDTH_EXTENSION
	
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
	if button.name == "BeginButton":
		target_size_x = begin_size.x
	elif button.name == "BackButton":
		target_size_x = back_size.x
	
	new_tween.tween_property(button, "size:x", target_size_x, TWEEN_DURATION)
