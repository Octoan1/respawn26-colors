shader_type spatial;
render_mode unshaded;

uniform vec4 base_color : source_color = vec4(0.11, 0.11, 0.11, 1.0);

void fragment() {
	ALBEDO = base_color.rgb;
}
