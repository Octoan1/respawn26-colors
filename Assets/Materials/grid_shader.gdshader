shader_type spatial;
render_mode unshaded; // Keeps the clean, vibrant cartoon aesthetic untouched

uniform vec4 object_color : source_color = vec4(1.0, 0.5, 0.0, 1.0); // Base Color
uniform vec4 pattern_color : source_color = vec4(1.0, 1.0, 1.0, 0.15); // Grid overlay color (light tint)

uniform float grid_scale : hint_range(1.0, 100.0, 1.0) = 20.0;       // Grid frequency density
uniform float line_thickness : hint_range(0.01, 0.2, 0.01) = 0.03;   // How thick the grid wires look

void fragment() {
	// 1. Calculate a perfect repeating UV grid coordinate layout across the mesh faces
	vec2 grid_uv = fract(UV * grid_scale);
	
	// 2. Generate sharp grid boundaries along the U and V spatial planes
	float line_u = step(grid_uv.x, line_thickness) + step(1.0 - line_thickness, grid_uv.x);
	float line_v = step(grid_uv.y, line_thickness) + step(1.0 - line_thickness, grid_uv.y);
	
	// 3. Combine horizontal and vertical coordinates to map a mask
	float grid_mask = clamp(line_u + line_v, 0.0, 1.0);
	
	// 4. Mix your base selection color with the grid pattern lines
	vec3 final_output = mix(object_color.rgb, pattern_color.rgb, grid_mask * pattern_color.a);
	
	ALBEDO = final_output;
}
