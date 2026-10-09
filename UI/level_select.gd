extends Control
@onready var level_columns: Control = $ScrollContainer/LevelColumns
@export var buttons_per_row: int = 4
const WHITE_TEXT_THEME = preload("uid://biqu4o348eq17")
const BLACK_TEXT_THEME = preload("uid://cm882kskewj27")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	populate_button_data()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func populate_button_data() -> void:
	for level_num in range(LevelManager.LEVEL_LIST.levels.size()):
		var level_data: LevelData = LevelManager.LEVEL_LIST.levels[level_num]
		
		# create a new hbox every 4 levels
		var hbox: HBoxContainer 
		if level_num % buttons_per_row == 0:
			hbox = HBoxContainer.new()
			#hbox.size.y = 400
			hbox.add_theme_constant_override("separation", 66)
			level_columns.add_child(hbox)
			
		
		# create a button for each level
		var button: Button = Button.new()
		button.pressed.connect(go_to_level.bind(level_num))
		
		
		button.text = "Mission " + str(level_num+1)
		button.add_theme_font_size_override("font_size", 52)
		button.theme = WHITE_TEXT_THEME
		button.custom_minimum_size = Vector2(200, 80)
		
		if level_data.is_complete:
			var style: StyleBoxFlat = StyleBoxFlat.new()
			if level_data.color == "c4c4c4":
				button.theme = BLACK_TEXT_THEME
			
			style.bg_color = Color(level_data.color)
			
			button.add_theme_stylebox_override("normal", style)
			button.add_theme_color_override("font_color", Color("1c1c1c"))
		
		if level_num != 0:
			if LevelManager.LEVEL_LIST.levels[level_num-1].is_complete == false:
				button.disabled = true
		
		
		
		# add the button to the most recent hbox
		var hbox_index: int = level_columns.get_children().size()-1
		level_columns.get_child(hbox_index).add_child(button)
		
		await get_tree().process_frame
		
		# create labels
		var button_labels: Array[Label] = populate_level_info(level_data, button.global_position)
		
		button.mouse_entered.connect(show_level_info.bind(button_labels[0], button_labels[1]))
		button.mouse_exited.connect(hide_level_info.bind(button_labels[0], button_labels[1]))
		add_child(button_labels[0])
		add_child(button_labels[1])

func show_level_info(rank_label: Label, time_label: Label) -> void:
	rank_label.visible = true
	time_label.visible = true

func hide_level_info(rank_label: Label, time_label: Label) -> void:
	rank_label.visible = false
	time_label.visible = false

func populate_level_info(level_data: LevelData, pos: Vector2) -> Array[Label]:
	print(pos)
	# create a label for the level's rank
	var rank_label: Label = Label.new()
	rank_label.text = "Rank " + level_data.rank
	rank_label.add_theme_font_size_override("font_size", 24)
	rank_label.theme = WHITE_TEXT_THEME
	rank_label.global_position = pos + Vector2(0, -20)
	rank_label.visible = false
	
	
	# create a lebel for the level's time
	var time_label: Label = Label.new()
	time_label.text = "Time %.2f" %level_data.best_time
	time_label.add_theme_font_size_override("font_size", 24)
	time_label.theme = WHITE_TEXT_THEME
	time_label.global_position = pos + Vector2(60, -20)
	time_label.visible = false
	
	return [rank_label, time_label]
	

func go_to_level(level_num: int) -> void:
	UiManager.go_to_level_brief(level_num, "level_select")
	#LevelManager.go_to_level(level_num)
	#queue_free()


func _on_menu_button_pressed() -> void:
	UiManager.go_to_title()
