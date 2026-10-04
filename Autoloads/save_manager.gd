extends Node

#TO BE IMPLEMENTED...

# for every level_data resource in the level_list resource (which contains an array of level_data resources)
# save info from each level:
# level time
# level rank
# is complete

func save_game() -> void:
	for level_data in LevelManager.LEVEL_LIST.levels:
		#save level 1's data, then level 2, etc...
		level_data.best_time
		level_data.is_complete
		level_data.rank
