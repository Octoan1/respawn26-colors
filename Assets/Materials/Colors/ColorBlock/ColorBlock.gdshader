shader_type spatial;
render_mode unshaded;

uniform vec4 base_color : source_color = vec4(0.11, 0.11, 0.11, 1.0);
uniform float texture_scale : hint_range(0.1, 20.0) = 3.0;
uniform float texture_strength : hint_range(0.0, 1.0) = 0.08;

varying vec3 local_position;

float hash_noise(vec3 position) {
	return fract(sin(dot(position, vec3(127.1, 311.7, 74.7))) * 43758.5453);
}

float value_noise(vec3 position) {
	vec3 cell = floor(position);
	vec3 local = fract(position);
	local = local * local * (3.0 - 2.0 * local);

	float n000 = hash_noise(cell + vec3(0.0, 0.0, 0.0));
	float n100 = hash_noise(cell + vec3(1.0, 0.0, 0.0));
	float n010 = hash_noise(cell + vec3(0.0, 1.0, 0.0));
	float n110 = hash_noise(cell + vec3(1.0, 1.0, 0.0));
	float n001 = hash_noise(cell + vec3(0.0, 0.0, 1.0));
	float n101 = hash_noise(cell + vec3(1.0, 0.0, 1.0));
	float n011 = hash_noise(cell + vec3(0.0, 1.0, 1.0));
	float n111 = hash_noise(cell + vec3(1.0, 1.0, 1.0));

	float x00 = mix(n000, n100, local.x);
	float x10 = mix(n010, n110, local.x);
	float x01 = mix(n001, n101, local.x);
	float x11 = mix(n011, n111, local.x);
	return mix(mix(x00, x10, local.y), mix(x01, x11, local.y), local.z);
}

void vertex() {
	local_position = VERTEX;
}

void fragment() {
	float texture = value_noise(local_position * texture_scale);
	float variation = mix(1.0 - texture_strength, 1.0 + texture_strength, texture);
	ALBEDO = base_color.rgb * variation;
}
