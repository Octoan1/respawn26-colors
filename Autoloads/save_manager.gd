extends Node

# Path to save the file on the player's device
const SAVE_PATH = "user://savegame.tres"
var levels_complete: int = 0

# for every level_data resource in the level_list resource (which contains an array of level_data resources)
# save info from each level:
# level time
# level rank
# is complete

func _ready() -> void:
	load_game()

func save_game() -> void:
	var levels_beaten: int = 0
	
	#print("saving game")
	# Create a temporary container for the data we want to save
	var save_data: SaveData = SaveData.new()
	
	# Loop through each level in your main list and extract the progress
	for level_data in LevelManager.LEVEL_LIST.levels:
		var progress: LevelProgress = LevelProgress.new()
		progress.best_time = level_data.best_time
		progress.is_complete = level_data.is_complete
		progress.rank = level_data.rank
		
		save_data.level_progress_list.append(progress)
		
		if level_data.is_complete:
			levels_beaten += 1
		
	
	levels_complete = levels_beaten
	save_data.levels_complete = levels_complete
	# Write the data to the user's disk
	ResourceSaver.save(save_data, SAVE_PATH)

func load_game() -> void:
	# Check if a save file actually exists before trying to load it
	if not ResourceLoader.exists(SAVE_PATH):
		print("No save game found. Starting fresh.")
		return
		
	var save_data: SaveData = ResourceLoader.load(SAVE_PATH) as SaveData
	if not save_data:
		print("Failed to load or cast save data.")
		return
		
	# Distribute the saved data back into LevelManager resources
	for i in range(save_data.level_progress_list.size()):
		if i >= LevelManager.LEVEL_LIST.levels.size():
			break
			
		var progress: LevelProgress = save_data.level_progress_list[i]
		var level_data: LevelData = LevelManager.LEVEL_LIST.levels[i]
		
		level_data.best_time = progress.best_time
		level_data.is_complete = progress.is_complete
		level_data.rank = progress.rank
		
		#print(level_data)
		#print(level_data.best_time)
		#print(level_data.is_complete)
		#print(level_data.rank)
	
	levels_complete = save_data.levels_complete

func clear_save_data() -> void:
	# Create a temporary container for the data we want to save
	var save_data: SaveData = SaveData.new()
	
	# Loop through each level and reset values to their defaults
	for level_data in LevelManager.LEVEL_LIST.levels:
		var progress: LevelProgress = LevelProgress.new()
		progress.best_time = 99999.0
		progress.is_complete = false
		progress.rank = "F"
		
		save_data.level_progress_list.append(progress)
	
	levels_complete = 0
	
	save_data.levels_complete = levels_complete
	# Write the data to the user's disk
	ResourceSaver.save(save_data, SAVE_PATH)
