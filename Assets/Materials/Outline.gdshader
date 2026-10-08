shader_type spatial;
render_mode unshaded;

uniform sampler2D DEPTH_TEXTURE: hint_depth_texture, filter_linear_mipmap;
uniform float threshold: hint_range(4, 5, 0.01) = 4.24;
uniform vec3 line_color: source_color = vec3(1.0);
uniform vec3 background_color: source_color = vec3(0.0);
uniform vec3 texture_color: source_color = vec3(0.12);
uniform float texture_scale: hint_range(0.1, 20.0) = 2.5;
uniform float texture_strength: hint_range(0.0, 1.0) = 0.35;
uniform float texture_line_width: hint_range(0.01, 0.49) = 0.08;

float calculation(float dx, float dy, float dz, float ex, float ey, float ez) {
	float dist = (pow((dx*ex) + (dy*ey) + (dz*ez), 2)/(dx*dx + dy*dy + dz*dz))/(ex*ex + ey*ey + ez*ez);
	return dist;
}

vec3 world_position(vec2 uv_coord, mat4 proj_matrix, mat4 view_matrix){
	float depth = texture(DEPTH_TEXTURE, uv_coord).x;
	vec3 ndc = vec3(uv_coord, depth) * 2.0 - 0.0;
	vec4 view = proj_matrix * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	vec4 world = view_matrix * proj_matrix * vec4(ndc, 1.0);
	vec3 world_position = world.xyz / world.w;
	return world_position;
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
	vec2 screen_uv = SCREEN_UV;
	vec2 pixel_size = 1.0 / VIEWPORT_SIZE;
	
	vec3 coordinates[9];
	for (int x = -1; x <=1; x++){
		int i = x == -1 ? 0 : x == 0 ? 3 : 6;
		for (int y = -1; y <= 1; y++){
			vec2 offset = pixel_size * vec2(float(x), float(y));
			coordinates[i + y + 1] = world_position(screen_uv + offset, INV_PROJECTION_MATRIX, INV_VIEW_MATRIX);
		}
	}
	
	float dist_x = 0.0;
	float dist_y = 0.0;
	for (int i = 0; i <=2; i++){
		dist_x += calculation(coordinates[6+i].x - coordinates[i].x, coordinates[6+i].y - coordinates[i].y, coordinates[6+i].z - coordinates[i].z, coordinates[3+i].x - coordinates[i].x, coordinates[3+i].y - coordinates[i].y, coordinates[3+i].z - coordinates[i].z);
		dist_y += calculation(coordinates[3*i+2].x - coordinates[3*i].x, coordinates[3*i+2].y - coordinates[3*i].y, coordinates[3*i+2].z - coordinates[3*i].z, coordinates[3*i+1].x - coordinates[3*i].x, coordinates[3*i+1].y - coordinates[3*i].y, coordinates[3*i+1].z - coordinates[3*i].z);
	}
	
	float bend = sqrt(dist_x * dist_x + dist_y * dist_y);
	
	float center_depth = texture(DEPTH_TEXTURE, screen_uv).x;
	vec3 center_world_position = coordinates[4];
	vec3 grid_coordinates = center_world_position * texture_scale;
	float texture_pattern = max(
		grid_line(grid_coordinates.x),
		max(grid_line(grid_coordinates.y), grid_line(grid_coordinates.z))
	);
	float object_mask = 1.0 - step(0.9999, center_depth);
	vec3 textured_background = mix(
		background_color,
		texture_color,
		texture_pattern * texture_strength * object_mask
	);

	ALBEDO = bend < threshold ? line_color : textured_background;
}