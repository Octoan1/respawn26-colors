shader_type spatial;
render_mode unshaded; 

uniform vec4 albedo : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap;

// Ambient Depth Controls
uniform float shading_contrast : hint_range(0.1, 4.0) = 1.5; 
uniform float rim_influence : hint_range(0.0, 2.0) = 1.0;     

// Floor & Distance Visibility Tweaks
uniform float distance_shadow_scale : hint_range(0.0, 0.2) = 0.01; // Increases dot size into the distance
uniform float floor_dot_boost : hint_range(0.0, 1.0) = 0.3;        // Directly scales up dots on flat horizontal surfaces

// Halftone Controls
uniform float dot_scale : hint_range(10.0, 1000.0) = 300.0;
uniform float dot_sharpness : hint_range(1.0, 50.0) = 20.0;
uniform vec4 dot_color : source_color = vec4(0.109, 0.109, 0.109, 1.0);

vec2 rotate_uv(vec2 uv, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return vec2(c * uv.x - s * uv.y, s * uv.x + c * uv.y);
}

void fragment() {
    vec4 tex_color = texture(texture_albedo, UV);
    vec3 base_color = albedo.rgb * tex_color.rgb;
    
    // 1. Core Omnidirectional Fake Shading
    float fresnel = 1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0);
    float vertical_ambient = clamp(NORMAL.y * 0.5 + 0.5, 0.0, 1.0);
    float fake_light_intensity = mix(vertical_ambient, 1.0, fresnel * rim_influence);
    fake_light_intensity = pow(fake_light_intensity, shading_contrast);
    
    // 2. Tweak: Measure distance from camera lens to the surface fragment
    float dist_from_camera = length(VERTEX);
    
    // 3. Tweak: Detect if the surface is a flat floor (Normal pointing straight up)
    // If it's a floor, we artificially lower the light intensity to force bigger, more visible dots
    float floor_mask = clamp(NORMAL.y, 0.0, 1.0);
    fake_light_intensity -= (floor_mask * floor_dot_boost);
    
    // 4. Create uniform screen-space grid for the comic dots
    vec2 screen_uv = FRAGCOORD.xy / VIEWPORT_SIZE.xy;
    screen_uv.x *= (VIEWPORT_SIZE.x / VIEWPORT_SIZE.y); 
    
    vec2 rotated_uv = rotate_uv(screen_uv * dot_scale, 0.785398); 
    vec2 grid_uv = fract(rotated_uv) - 0.5;
    
    float dist_from_center = length(grid_uv);
    
    // 5. Map intensity to dot size, appending our camera distance factor
    // This scales the dots up slightly in the distance so perspective doesn't completely erase them
    float target_dot_size = (1.0 - fake_light_intensity) * 0.7;
    target_dot_size += (dist_from_camera * distance_shadow_scale);
    target_dot_size = clamp(target_dot_size, 0.0, 0.7); // Cap it to prevent massive overlapping boxes
    
    float dot_mask = smoothstep(target_dot_size, target_dot_size - (1.0 / dot_sharpness), dist_from_center);
    
    ALBEDO = mix(base_color, dot_color.rgb, dot_mask);
}
