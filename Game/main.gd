extends Node
const TITLE = preload("uid://cad2mj4oauw32")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var title_screen: Node = TITLE.instantiate()
	add_child(title_screen)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	pass
