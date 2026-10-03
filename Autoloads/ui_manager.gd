extends Node
const TITLE = preload("uid://cad2mj4oauw32")

## Instantiates the title scene
func go_to_title() -> void:
	var scene: PackedScene = TITLE
	var title_screen: Node = scene.instantiate()
	
	var main: Node
	for child in get_tree().root.get_children():
		if child.name == "Main":
			main = child
			break
	
	main.add_child(title_screen)
