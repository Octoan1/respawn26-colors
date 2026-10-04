class_name LevelData
extends Resource

@export var scene: PackedScene
@export var name: String
@export var color: String

@export_group("Rank Times")
@export var s_rank_time: float
@export var a_rank_time: float
@export var b_rank_time: float
@export var c_rank_time: float
@export var d_rank_time: float

var rank_times: Array[float]:
	get:
		return [s_rank_time, a_rank_time, b_rank_time, c_rank_time, d_rank_time]
