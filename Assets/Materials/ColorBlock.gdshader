shader_type spatial;
render_mode unshaded;

uniform vec4 base_color : source_color = vec4(0.108, 0.108, 0.108, 1.0);

void fragment() {
	ALBEDO = base_color.rgb;
}
