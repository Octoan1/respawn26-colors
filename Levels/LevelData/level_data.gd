class_name LevelData
extends Resource

@export_group("Level Info")
@export var scene: PackedScene
@export var name: String
@export var color: String
@export var target_info: String
@export var target_image: Texture2D = preload("uid://dxn0y7y5uoji8")
@export var level_num: int = 0
@export var has_green: bool = false
@export var has_blue: bool = false
@export var has_red: bool = false


@export_group("Rank Times")
@export var s_rank_time: float
@export var a_rank_time: float
@export var b_rank_time: float
@export var c_rank_time: float
@export var d_rank_time: float

@export_group("Saved Data")
@export var best_time: float = 99999.0
@export var is_complete: bool = false
@export var rank: String = "F"

var rank_times: Array[float]:
	get:
		return [s_rank_time, a_rank_time, b_rank_time, c_rank_time, d_rank_time]
