shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, depth_test_disabled;

uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear;

uniform float threshold : hint_range(0.0, 10.0, 0.01) = 4.24;
uniform vec3 line_color : source_color = vec3(0.04);
uniform float line_strength : hint_range(0.0, 1.0) = 0.9;

// Distant surfaces are gently darkened instead of being flattened to black.
uniform vec3 near_tint : source_color = vec3(1.0);
uniform vec3 far_tint : source_color = vec3(0.45);
uniform float depth_fade_start : hint_range(0.0, 100.0) = 8.0;
uniform float depth_fade_end : hint_range(0.0, 200.0) = 45.0;

// Subtle world-space lines provide orientation and scale cues.
uniform vec3 texture_color : source_color = vec3(0.05);
uniform float texture_scale : hint_range(0.1, 20.0) = 2.5;
uniform float texture_strength : hint_range(0.0, 1.0) = 0.12;
uniform float texture_line_width : hint_range(0.01, 0.49) = 0.08;

float calculation(float dx, float dy, float dz, float ex, float ey, float ez) {
	vec3 direction = vec3(dx, dy, dz);
	vec3 edge = vec3(ex, ey, ez);
	float direction_length = dot(direction, direction);
	float edge_length = dot(edge, edge);

	if (direction_length <= 0.00001 || edge_length <= 0.00001) {
		return 0.0;
	}

	float projection = dot(direction, edge);
	return (projection * projection / direction_length) / edge_length;
}

float grid_line(float coordinate) {
	float distance_to_line = abs(fract(coordinate) - 0.5);
	return 1.0 - smoothstep(
		texture_line_width,
		texture_line_width + 0.02,
		distance_to_line
	);
}

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec2 pixel_size = 1.0 / VIEWPORT_SIZE;
	float depths[9];

	for (int x = -1; x <= 1; x++) {
		int index = x == -1 ? 0 : x == 0 ? 3 : 6;
		for (int y = -1; y <= 1; y++) {
			vec2 offset = pixel_size * vec2(float(x), float(y));
			depths[index + y + 1] = texture(depth_texture, SCREEN_UV + offset).r;
		}
	}

	float dist_x = 0.0;
	float dist_y = 0.0;

	for (int i = 0; i <= 2; i++) {
		dist_x += abs(depths[6 + i] - depths[i]);
		dist_y += abs(depths[3 * i + 2] - depths[3 * i]);
	}

	float depth_edge = sqrt(dist_x * dist_x + dist_y * dist_y);
	vec3 scene_color = texture(screen_texture, SCREEN_UV).rgb;

	float center_depth = depths[4];
	float depth_amount = smoothstep(depth_fade_start / 100.0, depth_fade_end / 100.0, center_depth);
	vec3 depth_color = mix(near_tint, far_tint, depth_amount);

	vec2 texture_coordinates = SCREEN_UV * VIEWPORT_SIZE / max(texture_scale, 0.1);
	float grid_x = grid_line(texture_coordinates.x);
	float grid_z = grid_line(texture_coordinates.y);
	float grid = max(grid_x, grid_z);
	vec3 textured_color = mix(
		scene_color,
		texture_color,
		grid * texture_strength
	);

	// Keep the original scene visible and use the depth pass as an overlay.
	vec3 result = textured_color * depth_color;
	float line_mask = 1.0 - smoothstep(
		threshold - 0.5,
		threshold + 0.5,
		depth_edge * 100.0
	);
	ALBEDO = mix(result, line_color, line_mask * line_strength);
}
