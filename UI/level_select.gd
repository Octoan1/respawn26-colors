extends Control
@onready var level_columns: Control = $ScrollContainer/LevelColumns
@export var buttons_per_row: int = 4

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
			level_columns.add_child(hbox)
		
		# create a button for each level
		var button: Button = Button.new()
		button.pressed.connect(go_to_level.bind(level_num))
		button.text = "Level " + str(level_num+1)
		
		if level_num != 0:
			if LevelManager.LEVEL_LIST.levels[level_num-1].is_complete == false:
				button.disabled = true
		
		
		
		# add the button to the most recent hbox
		var hbox_index: int = level_columns.get_children().size()-1
		level_columns.get_child(hbox_index).add_child(button)
		

func go_to_level(level_num: int) -> void:
	LevelManager.go_to_level(level_num)
	queue_free()
