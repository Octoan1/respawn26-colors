shader_type spatial;
render_mode unshaded;

uniform sampler2D DEPTH_TEXTURE: hint_depth_texture, filter_linear_mipmap;
uniform float threshold: hint_range(4, 5, 0.01) = 4.24;
uniform vec3 line_color: source_color = vec3(1.0);
uniform vec3 background_color: source_color = vec3(0.0);
uniform vec3 texture_color: source_color = vec3(0.12);
uniform float noise_scale: hint_range(0.1, 20.0) = 2.5;
uniform float noise_strength: hint_range(0.0, 1.0) = 0.35;
uniform float noise_contrast: hint_range(0.25, 4.0) = 1.5;
uniform mat4 player_inverse_transform;

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

float hash_noise(vec3 position) {
	return fract(sin(dot(position, vec3(127.1, 311.7, 74.7))) * 43758.5453);
}

float value_noise(vec3 position) {
	vec3 cell = floor(position);
	vec3 local_position = fract(position);
	local_position = local_position * local_position * (3.0 - 2.0 * local_position);

	float n000 = hash_noise(cell + vec3(0.0, 0.0, 0.0));
	float n100 = hash_noise(cell + vec3(1.0, 0.0, 0.0));
	float n010 = hash_noise(cell + vec3(0.0, 1.0, 0.0));
	float n110 = hash_noise(cell + vec3(1.0, 1.0, 0.0));
	float n001 = hash_noise(cell + vec3(0.0, 0.0, 1.0));
	float n101 = hash_noise(cell + vec3(1.0, 0.0, 1.0));
	float n011 = hash_noise(cell + vec3(0.0, 1.0, 1.0));
	float n111 = hash_noise(cell + vec3(1.0, 1.0, 1.0));

	float x00 = mix(n000, n100, local_position.x);
	float x10 = mix(n010, n110, local_position.x);
	float x01 = mix(n001, n101, local_position.x);
	float x11 = mix(n011, n111, local_position.x);
	float y0 = mix(x00, x10, local_position.y);
	float y1 = mix(x01, x11, local_position.y);
	return mix(y0, y1, local_position.z);
}

float fractal_noise(vec3 position) {
	float result = 0.0;
	float amplitude = 0.5;

	for (int octave = 0; octave < 3; octave++) {
		result += value_noise(position) * amplitude;
		position *= 2.0;
		amplitude *= 0.5;
	}

	return result / 0.875;
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
	vec3 player_local_position = (player_inverse_transform * vec4(center_world_position, 1.0)).xyz;
	float texture_pattern = fractal_noise(player_local_position * noise_scale);
	texture_pattern = pow(texture_pattern, noise_contrast);
	float object_mask = 1.0 - step(0.9999, center_depth);
	vec3 textured_background = mix(
		background_color,
		texture_color,
		texture_pattern * noise_strength * object_mask
	);

	ALBEDO = bend < threshold ? line_color : textured_background;
}