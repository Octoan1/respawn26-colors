extends CanvasLayer

const SLASH_TRANSITION = preload("uid://cdcud4y52s70y")
const SQUARE_TRANSITION = preload("uid://bwkgvp5v6n53")


@onready var color_rect: ColorRect = $ColorRect

func play_transition(duration: float = 0.5) -> void:
	var material: ShaderMaterial = color_rect.material
	
	# TRANSITION OPEN
	
	color_rect.visible = true
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	# set shader vars
	material.shader = SLASH_TRANSITION
	material.set_shader_parameter("t", 0.0)
	material.set_shader_parameter("mask_color", Color(1, 1, 1))
	material.set_shader_parameter("background_color", Color(0, 0, 0, 0))
	
	var tween_in: Tween = create_tween()
	tween_in.set_trans(Tween.TRANS_QUART)
	tween_in.set_ease(Tween.EASE_OUT)
	
	# if transition doesnt cover full screen;
	# increase this from 1 to 2 or 3 or whatever
	tween_in.tween_property(material, "shader_parameter/t", 1.0, duration)
	
	await tween_in.finished
	
	

func end_transition(duration: float = 0.5) -> void:
	var material: ShaderMaterial = color_rect.material
	
	# TRANSITION CLOSE
	
	# set shader vars
	material.shader = SQUARE_TRANSITION
	material.set_shader_parameter("t", 0.0)
	material.set_shader_parameter("mask_color", Color(1, 1, 1))
	material.set_shader_parameter("background_color", Color(0, 0, 0, 0))
	
	var tween_out: Tween = create_tween()
	tween_out.set_trans(Tween.TRANS_QUART)
	tween_out.set_ease(Tween.EASE_IN)
	
	# if transition doesnt cover full screen;
	# increase this from 1 to 2 or 3 or whatever
	tween_out.tween_property(material, "shader_parameter/t", 1.0, duration)
	
	await tween_out.finished
	
	color_rect.visible = false
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
