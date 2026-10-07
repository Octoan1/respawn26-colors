shader_type spatial;
render_mode unshaded, cull_front; // cull_front flips the mesh inside out for the outline pass

// 'source_color' prevents colors like orange from turning muddy red
uniform vec4 outline_color : source_color = vec4(0.109, 0.109, 0.109, 1.0); // #1c1c1c black color code
uniform float outline_thickness : hint_range(0.0, 10.0, 0.1) = 2.0;   // Measured in screen pixels

void vertex() {
	// 1. Project the standard 3D mesh points into 2D camera screen coordinates
	vec4 clip_position = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	
	// 2. Transform the surfaces normals into camera view coordinates
	vec3 clip_normal = mat3(PROJECTION_MATRIX) * mat3(MODELVIEW_MATRIX) * NORMAL;
	
	// 3. Offset the vertices flat against the screen size to prevent line gaps or distance blurring
	vec2 screen_pixel_offset = normalize(clip_normal.xy) / VIEWPORT_SIZE * outline_thickness * clip_position.w * 2.0;
	
	clip_position.xy += screen_pixel_offset;
	POSITION = clip_position;
}

void fragment() {
	ALBEDO = outline_color.rgb;
}
