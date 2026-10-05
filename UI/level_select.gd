extends Control
@onready var level_columns: Control = $ScrollContainer/LevelColumns
@export var buttons_per_row: int = 4
const WHITE_TEXT_THEME = preload("uid://biqu4o348eq17")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	populate_button_data()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func populate_button_data() -> void:
	for level_num in range(LevelManager.LEVEL_LIST.levels.size()):
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
		button.add_theme_font_size_override("font_size", 20)
		button.theme = WHITE_TEXT_THEME
		button.custom_minimum_size = Vector2(200, 80)
		
		if level_num != 0:
			if LevelManager.LEVEL_LIST.levels[level_num-1].is_complete == false:
				button.disabled = true
		
		
		
		# add the button to the most recent hbox
		var hbox_index: int = level_columns.get_children().size()-1
		level_columns.get_child(hbox_index).add_child(button)
		



func go_to_level(level_num: int) -> void:
	UiManager.go_to_level_brief(level_num)
	#LevelManager.go_to_level(level_num)
	queue_free()


func _on_menu_button_pressed() -> void:
	UiManager.go_to_title()
