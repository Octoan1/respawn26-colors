shader_type spatial;
render_mode unshaded;

uniform sampler2D DEPTH_TEXTURE: hint_depth_texture, filter_linear_mipmap;
uniform float threshold: hint_range(4, 5, 0.01) = 4.24;
uniform vec3 line_color: source_color = vec3(0.4);
uniform vec3 background_color: source_color = vec3(0.9);

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
	
	ALBEDO = bend < threshold ? line_color : background_color;
}