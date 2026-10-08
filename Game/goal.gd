extends Area3D
@onready var target_sprite: Sprite3D = $TargetSprite
var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not player:
		return
	
	var target_pos: Vector3 = player.global_transform.origin
	target_pos.y = target_sprite.global_transform.origin.y
	
	target_sprite.look_at(target_pos, Vector3.UP)


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		var curr_state: PlayerState = player.state_machine.current_state
		curr_state.Transitioned.emit(curr_state, "IDLE")
		LevelManager.complete_level()

func give_player(ref: Player) -> void:
	player = ref
